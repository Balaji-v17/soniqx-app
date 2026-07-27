// ============================================================
//  SONIQ — lib/audio/audio_handler.dart
//  Core playback engine & background lockscreen sync.
// ============================================================

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:soniq/audio/artwork_extractor.dart';
import 'package:soniq/database/database.dart'; 

// ─── CUSTOM REPEAT MODE ENUM ─────────────────────────────────
enum SoniqRepeatMode {
  none,   // no repeat         — icon: repeat (grey/inactive)
  once,   // repeat song once  — icon: repeat with "1" badge (blue/active)
  all,    // repeat all songs  — icon: repeat (blue/active)
}

class SoniqAudioHandler extends BaseAudioHandler with SeekHandler {
  final AppDatabase _db;
  
  late final AudioPlayer _player;
  final AndroidEqualizer _equalizer = AndroidEqualizer();
  
  // 🎯 PUBLIC GETTERS FOR YOUR UI SCREENS
  AudioPlayer get player => _player;
  AndroidEqualizer get equalizer => _equalizer;
  
  // 🎯 HISTORY TRACKER
  String? _lastRecordedMediaId;

  // 🎯 REPEAT ONCE TRACKERS
  SoniqRepeatMode _repeatMode = SoniqRepeatMode.none;
  bool _songRepeatedOnce = false;
  Duration _prevPosition = Duration.zero;

  SoniqAudioHandler(this._db) {
    final pipeline = AudioPipeline(
      androidAudioEffects: [_equalizer],
    );
    _player = AudioPlayer(audioPipeline: pipeline);
    
    _init();
  }

  Future<void> _init() async {
    // 1. Tell Android what controls we support right away
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.skipToPrevious, MediaControl.play, MediaControl.skipToNext],
      systemActions: const {MediaAction.seek},
      processingState: AudioProcessingState.idle,
    ));

    // 2. Listen to the internal audio player and sync it to the lockscreen
    _player.playbackEventStream.listen(_broadcastState);

    // 3. Listen to sequenceStateStream for dynamic queue updates & lazy artwork extraction
    _player.sequenceStateStream.listen((sequenceState) async {
      if (sequenceState == null) return;

      // Automatically updates the visual queue to match the Shuffled order
      final effectiveQueue = sequenceState.effectiveSequence
          .map((source) => source.tag as MediaItem)
          .toList();
      queue.add(effectiveQueue);

      // Keep the currently playing track metadata synced
      final currentSource = sequenceState.currentSource;
      if (currentSource != null) {
        var item = currentSource.tag as MediaItem;
        
        // Push metadata immediately so title/artist render with 0 latency
        mediaItem.add(item);

        // LAZY ARTWORK EXTRACTION
        if (item.artUri == null) {
          final path = item.extras?['path'] as String?;
          if (path != null && path.isNotEmpty) {
            final artUri = await ArtworkExtractor.getArtUriFromPath(path);
            if (artUri != null) {
              mediaItem.add(item.copyWith(artUri: artUri));
            }
          }
        }

        // Centralized Auto-Play History Tracking
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

    // 4. The Self-Healing Duration Trigger
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

    // 5. The Repeat Once Position Tracker
    _player.positionStream.listen(_handleRepeatOncePosition);
  }

  // ─── REPEAT ONCE LOGIC ───────────────────────────────────────

  Future<void> _handleRepeatOncePosition(Duration position) async {
    // Only run when repeat-once is active and not yet triggered
    if (_repeatMode != SoniqRepeatMode.once || _songRepeatedOnce) {
      _prevPosition = position;
      return;
    }

    final duration = _player.duration;
    if (duration == null || duration.inMilliseconds < 3000) {
      _prevPosition = position;
      return;
    }

    // "Near end"  = player has played more than 90% of the song
    // "Near start" = position is within the first 3 seconds
    final nearEndThreshold = duration * 0.90;
    final wasNearEnd  = _prevPosition > nearEndThreshold;
    final isNearStart = position.inMilliseconds < 3000;

    if (wasNearEnd && isNearStart) {
      // ── Song has completed its FIRST play and just auto-restarted ──
      _songRepeatedOnce = true;
      _repeatMode       = SoniqRepeatMode.none;
      await _player.setLoopMode(LoopMode.off);
      
      // Notify audio_service so the UI updates the repeat icon
      _broadcastState(_player.playbackEvent);
    }
    
    _prevPosition = position;
  }

  // ─── QUEUE MANAGEMENT ────────────────────────────────────────

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
    
    // Default fallback to keep standard queue active
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

  // ─── PLAYBACK CONTROLS ───────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    // Reset repeat-once state on manual skip
    if (_repeatMode == SoniqRepeatMode.once) {
      _repeatMode       = SoniqRepeatMode.none;
      _songRepeatedOnce = false;
      await _player.setLoopMode(LoopMode.off);
    }
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    // Reset repeat-once state on manual skip
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
    // Cycle through custom modes: none → once → all → none
    switch (_repeatMode) {
      case SoniqRepeatMode.none:
        _repeatMode       = SoniqRepeatMode.once;
        _songRepeatedOnce = false;
        _prevPosition     = _player.position; // reset position tracking
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

  // ─── SYSTEM SYNC ─────────────────────────────────────────────

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
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 3],
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
      // Map our internal _repeatMode to AudioServiceRepeatMode for the UI
      repeatMode: switch (_repeatMode) {
        SoniqRepeatMode.none => AudioServiceRepeatMode.none,
        SoniqRepeatMode.once => AudioServiceRepeatMode.one,
        SoniqRepeatMode.all  => AudioServiceRepeatMode.all,
      },
    ));
  }
}