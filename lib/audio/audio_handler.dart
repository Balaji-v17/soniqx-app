// ============================================================
//  SONIQ — lib/audio/audio_handler.dart
//  Core playback engine & background lockscreen sync.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:soniq/audio/artwork_extractor.dart';
import 'package:soniq/database/database.dart'; 
import 'package:soniq/fallback_art_manager.dart';

enum SoniqRepeatMode {
  none,   
  once,   
  all,    
}

class SoniqAudioHandler extends BaseAudioHandler with SeekHandler {
  final AppDatabase _db;
  
  late final AudioPlayer _player;
  final AndroidEqualizer _equalizer = AndroidEqualizer();
  
  AudioPlayer get player => _player;
  AndroidEqualizer get equalizer => _equalizer;
  
  String? _lastRecordedMediaId;

  SoniqRepeatMode _repeatMode = SoniqRepeatMode.none;
  bool _songRepeatedOnce = false;
  Duration _prevPosition = Duration.zero;

  static const _closeControl = MediaControl(
    androidIcon: 'drawable/ic_close',
    label: 'Close',
    action: MediaAction.stop,
  );

  SoniqAudioHandler(this._db) {
    final pipeline = AudioPipeline(
      androidAudioEffects: [_equalizer],
    );
    _player = AudioPlayer(
      audioPipeline: pipeline,
      handleInterruptions: true,
      handleAudioSessionActivation: true,
    );
    
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    session.interruptionEventStream.listen((AudioInterruptionEvent event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            pause(); 
            break;
        }
      }
    });

    session.becomingNoisyEventStream.listen((_) {
      pause(); 
    });

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious, 
        MediaControl.play, 
        MediaControl.skipToNext,
        _closeControl,
      ],
      systemActions: const {MediaAction.seek},
      processingState: AudioProcessingState.idle,
    ));

    // Updated listener to catch missing files (ghost songs)
    _player.playbackEventStream.listen(
      _broadcastState,
      onError: (Object error, StackTrace stackTrace) async {
        debugPrint('Playback error (File likely missing): $error');
        
        final currentIndex = _player.currentIndex;
        if (currentIndex != null && currentIndex < queue.value.length) {
          final failedSong = queue.value[currentIndex];
          
          // Use the MediaItem ID to purge the missing file from the database
          final songId = int.tryParse(failedSong.id);
          if (songId != null) {
             await (_db.delete(_db.songs)..where((s) => s.id.equals(songId))).go();
          }
          
          // Automatically skip to the next valid song to prevent stalling
          await skipToNext();
        }
      },
    );

    _player.sequenceStateStream.listen((sequenceState) async {
      if (sequenceState == null) return;

      final effectiveQueue = sequenceState.effectiveSequence
          .map((source) => source.tag as MediaItem)
          .toList();
      queue.add(effectiveQueue);

      final currentSource = sequenceState.currentSource;
      if (currentSource != null) {
        var item = currentSource.tag as MediaItem;
        
        mediaItem.add(item);

        if (item.artUri == null) {
          final path = item.extras?['path'] as String?;
          if (path != null && path.isNotEmpty) {
            final artUri = await ArtworkExtractor.getArtUriFromPath(path);
            mediaItem.add(item.copyWith(artUri: artUri ?? FallbackArtManager.uri));
          } else {
            mediaItem.add(item.copyWith(artUri: FallbackArtManager.uri));
          }
        }

        if (_lastRecordedMediaId != item.id) {
          _lastRecordedMediaId = item.id;
          
          final songId = int.tryParse(item.id);
          if (songId != null) {
            Future.delayed(const Duration(seconds: 2), () {
              if (_lastRecordedMediaId == item.id) {
                final durationMs = item.duration?.inMilliseconds ?? 180000;
                
                _db.historyDao.recordPlay(
                  songId: songId,
                  listenedMs: durationMs,
                  counted: true,
                  skippedEarly: false,
                ).catchError((_) {}); 
              }
            });
          }
        }
      }
    });

    _player.durationStream.listen((Duration? duration) {
      if (duration != null && duration.inMilliseconds > 0) {
        final currentSource = _player.sequenceState?.currentSource;
        if (currentSource != null) {
          final item = currentSource.tag as MediaItem?;
          if (item != null) {
            final songId = int.tryParse(item.id);
            if (songId != null) {
              _db.songsDao.healMissingDuration(songId, duration.inMilliseconds);
            }
          }
        }
      }
    });

    _player.positionStream.listen(_handleRepeatOncePosition);
  }

  Future<void> _handleRepeatOncePosition(Duration position) async {
    if (_repeatMode != SoniqRepeatMode.once || _songRepeatedOnce) {
      _prevPosition = position;
      return;
    }

    final duration = _player.duration;
    if (duration == null || duration.inMilliseconds < 3000) {
      _prevPosition = position;
      return;
    }

    final nearEndThreshold = duration * 0.90;
    final wasNearEnd  = _prevPosition > nearEndThreshold;
    final isNearStart = position.inMilliseconds < 3000;

    if (wasNearEnd && isNearStart) {
      _songRepeatedOnce = true;
      _repeatMode       = SoniqRepeatMode.none;
      await _player.setLoopMode(LoopMode.off);
      
      _broadcastState(_player.playbackEvent);
    }
    
    _prevPosition = position;
  }

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    queue.add(newQueue);
    
    final audioSources = <AudioSource>[];
    for (final item in newQueue) {
      final path = item.extras?['path'] as String?;
      if (path != null && path.isNotEmpty) {
        audioSources.add(AudioSource.file(path, tag: item));
      }
    }

    final freshPlaylist = ConcatenatingAudioSource(children: audioSources);
    await _player.setAudioSource(freshPlaylist);
    
    if (_player.loopMode != LoopMode.all && _repeatMode != SoniqRepeatMode.once) {
      await _player.setLoopMode(LoopMode.all);
      _repeatMode = SoniqRepeatMode.all;
      _broadcastState(_player.playbackEvent);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    
    final targetItem = queue.value[index];
    final originalSequence = _player.sequence ?? [];
    final originalIndex = originalSequence.indexWhere(
        (source) => (source.tag as MediaItem).id == targetItem.id);
        
    if (originalIndex != -1) {
      await _player.seek(Duration.zero, index: originalIndex);
      play();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_repeatMode == SoniqRepeatMode.once) {
      _repeatMode       = SoniqRepeatMode.none;
      _songRepeatedOnce = false;
      await _player.setLoopMode(LoopMode.off);
    }
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_repeatMode == SoniqRepeatMode.once) {
      _repeatMode       = SoniqRepeatMode.none;
      _songRepeatedOnce = false;
      await _player.setLoopMode(LoopMode.off);
    }
    await _player.seekToPrevious();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enable = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enable);

    playbackState.add(playbackState.value.copyWith(
      shuffleMode: shuffleMode,
    ));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (_repeatMode) {
      case SoniqRepeatMode.none:
        _repeatMode       = SoniqRepeatMode.once;
        _songRepeatedOnce = false;
        _prevPosition     = _player.position; 
        await _player.setLoopMode(LoopMode.one);
        break;
      case SoniqRepeatMode.once:
        _repeatMode       = SoniqRepeatMode.all;
        _songRepeatedOnce = false;
        await _player.setLoopMode(LoopMode.all);
        break;
      case SoniqRepeatMode.all:
        _repeatMode       = SoniqRepeatMode.none;
        _songRepeatedOnce = false;
        await _player.setLoopMode(LoopMode.off);
        break;
    }
    _broadcastState(_player.playbackEvent);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final currentItem = mediaItem.value;
    
    final activeQueueIndex = currentItem != null 
        ? queue.value.indexWhere((item) => item.id == currentItem.id)
        : event.currentIndex;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        _closeControl,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2], // Prev, Play/Pause, Next
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: activeQueueIndex != -1 ? activeQueueIndex : event.currentIndex,
      repeatMode: switch (_repeatMode) {
        SoniqRepeatMode.none => AudioServiceRepeatMode.none,
        SoniqRepeatMode.once => AudioServiceRepeatMode.one,
        SoniqRepeatMode.all  => AudioServiceRepeatMode.all,
      },
    ));
  }
}