// ============================================================
//  SONIQ — lib/audio/soniq_audio_handler.dart
//  just_audio 0.9.46 | audio_service 0.18.17 | June 2026
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'artwork_extractor.dart';

import '../database/database.dart';

class SoniqAudioHandler extends BaseAudioHandler with SeekHandler, QueueHandler {
 // ─── PHASE 7: Advanced Audio Pipeline & Equalizer ──────────
  
  // 1. Initialize the native Android Equalizer
  final AndroidEqualizer equalizer = AndroidEqualizer();

  // 2. Audio Pipeline activated for Equalizer processing
  late final AudioPlayer _player = AudioPlayer(
    audioPipeline: AudioPipeline(
      androidAudioEffects: [equalizer], // 🎯 FIXED: Removed the unsupported DSPs
    ),
  );

  // 3. Expose a public getter so the UI and Effects Service can read the state
  AudioPlayer get player => _player;
  final AppDatabase _db;

  bool _wasPlayingBeforeInterruption = false;
  Timer? _saveTimer;
  final List<StreamSubscription> _subs = [];

  double _playbackSpeed = 1.0;
  bool   _currentSongCounted = false;
  int?   _currentSongId;
  Duration? _lastPosition; // 🎯 ADDED: Tracks position to detect Repeat-One loops

  // ConcatenatingAudioSource is bound to _player once in _init().
  // All queue mutations go through this object — never replace it.
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

  SoniqAudioHandler(this._db) {
    Future.microtask(_init);
  }

  // ─── Initialization ────────────────────────────────────────

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      print("Audio Session Active: ${await session.setActive(true)}");
      await _player.setAudioSource(_playlist);

      _subs.addAll([
        session.interruptionEventStream.listen(_handleInterruption),
        session.becomingNoisyEventStream.listen((_) => pause()),
        // 🎯 FIXED: Added onError callback to prevent stream crashes from blocking the engine
        _player.playbackEventStream
            .map((event) => _transformEvent(event))
            .listen(
              (state) => playbackState.add(state),
              onError: (Object e, StackTrace st) {
                print("🚨 Playback Stream Error: $e");
              },
            ),
        _player.currentIndexStream.listen(_onSongIndexChanged),
        _player.positionStream.listen(_onPositionChanged),
      ]);

      _saveTimer = Timer.periodic(
        const Duration(seconds: 5),
        (_) => _saveQueueState(),
      );

      await _restoreQueueState();
    } catch (e) {
      print("🚨 Error during SoniqAudioHandler init: $e");
    }
  }

  // ─── Core Controls ─────────────────────────────────────────

  @override
  Future<void> play() async {
    try {
      // just_audio's play() Future completes when the song ends, not starts.
      _player.play(); 
    } catch (e) {
      print("🚨 Playback failed: $e");
    }
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    await _saveQueueState();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _saveQueueState();
    await _player.stop();
    mediaItem.add(null);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    try {
      await _player.seek(Duration.zero, index: index);
      await play();
    } catch (e) {
      print("🚨 Skip failed: $e");
    }
  }

  @override
  Future<void> playMediaItem(MediaItem item) async {
    final index = queue.value.indexWhere((q) => q.id == item.id);
    if (index != -1) {
      await skipToQueueItem(index);
    } else {
      await addQueueItem(item);
      await skipToQueueItem(queue.value.length - 1);
    }
  }

  // ─── PROPER ENUM-BASED SHUFFLE & REPEAT ────────────────────

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    LoopMode loopMode;
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        loopMode = LoopMode.off;
        break;
      case AudioServiceRepeatMode.one:
        loopMode = LoopMode.one;
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        loopMode = LoopMode.all;
        break;
    }
    await _player.setLoopMode(loopMode);
    playbackState.add(playbackState.value.copyWith(repeatMode: repeatMode));
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enabled);
    playbackState.add(playbackState.value.copyWith(shuffleMode: shuffleMode));
  }

  // ─── Skip Previous / Next ──────────────────────────────────

  @override
  Future<void> skipToNext() async {
    // 🎯 FIXED: Let just_audio handle the bounds. This allows wrap-around for LoopMode.all.
    await _player.seekToNext();
    _updateCurrentMediaItem();
  }

  @override
  Future<void> skipToPrevious() async {
    // 🎯 FIXED: Allow just_audio to handle backward wrapping if LoopMode.all is active.
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seekToPrevious();
    }
    _updateCurrentMediaItem();
  }

  // ─── Queue Management ──────────────────────────────────────

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    final valid = newQueue.where((item) => _pathFor(item).isNotEmpty).toList();
    queue.add(valid);

    final sources = valid.map((item) => AudioSource.file(_pathFor(item), tag: item)).toList();
    await _playlist.clear();
    if (sources.isNotEmpty) {
      await _playlist.addAll(sources);
    }
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    final path = _pathFor(item);
    if (path.isEmpty) return;

    queue.add([...queue.value, item]);
    await _playlist.add(AudioSource.file(path, tag: item));
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    final updated = List<MediaItem>.from(queue.value)..removeAt(index);
    queue.add(updated);
    await _playlist.removeAt(index);
  }

  @override
  Future<void> moveQueueItem(int fromIndex, int toIndex) async {
    if (fromIndex == toIndex) return;
    if (fromIndex < 0 || fromIndex >= queue.value.length) return;
    if (toIndex < 0 || toIndex >= queue.value.length) return;

    final updated = List<MediaItem>.from(queue.value);
    final item = updated.removeAt(fromIndex);
    updated.insert(toIndex, item);
    queue.add(updated);

    await _playlist.move(fromIndex, toIndex);
  }

  // ─── Queue Persistence ─────────────────────────────────────

  Future<void> _saveQueueState() async {
    final index = _player.currentIndex;
    if (index == null || queue.value.isEmpty || index >= queue.value.length) return;

    await _db.settingsDao.saveQueueState(
      songIdsJson: _serializeQueue(queue.value),
      currentIndex: index,
      positionMs: _player.position.inMilliseconds,
      repeatMode: _player.loopMode.name,
      shuffleMode: _player.shuffleModeEnabled,
    );
  }

  Future<void> _restoreQueueState() async {
    try {
      final state = await _db.settingsDao.loadQueueState();
      if (state == null || state.songIdsJson.isEmpty) return;

      final items = _deserializeQueue(state.songIdsJson);
      if (items.isEmpty) return;

      final valid = items.where((item) => _pathFor(item).isNotEmpty).toList();
      if (valid.isEmpty) return;

      await updateQueue(valid);

      final index = state.currentIndex.clamp(0, valid.length - 1).toInt();
      final position = Duration(milliseconds: state.positionMs);
      await _player.seek(position, index: index);

      switch (state.repeatMode) {
        case 'one': await _player.setLoopMode(LoopMode.one); break;
        case 'all': await _player.setLoopMode(LoopMode.all); break;
        default:    await _player.setLoopMode(LoopMode.off); break;
      }
      await _player.setShuffleModeEnabled(state.shuffleMode);

      if (index < valid.length) {
        mediaItem.add(valid[index]);
      }
    } catch (e) {
      // Corrupted state — start fresh gracefully
    }
  }

  // ─── Audio Session Interruptions ───────────────────────────

  void _handleInterruption(AudioInterruptionEvent event) {
    if (event.begin) {
      switch (event.type) {
        case AudioInterruptionType.duck:
          _player.setVolume(0.3);
          break;
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          _wasPlayingBeforeInterruption = _player.playing;
          _player.pause();
          break;
      }
    } else {
      switch (event.type) {
        case AudioInterruptionType.duck:
          _player.setVolume(1.0);
          break;
        case AudioInterruptionType.pause:
        case AudioInterruptionType.unknown:
          if (_wasPlayingBeforeInterruption) {
            play();
            _wasPlayingBeforeInterruption = false;
          }
          break;
      }
    }
  }

  Future<void> _onSongIndexChanged(int? index) async {
    if (index == null || index >= queue.value.length) return;

    _currentSongCounted = false;
    _currentSongId = null;
    _lastPosition = null; // 🎯 FIXED: Reset position tracker for new song

    var item = queue.value[index];
    _currentSongId = int.tryParse(item.id);

    // 🎯 DYNAMIC ARTWORK INJECTION
    if (item.artUri == null && item.extras?['path'] != null) {
      final extractedUri = await ArtworkExtractor.getArtUriFromPath(item.extras!['path']!);
      if (extractedUri != null) {
        item = item.copyWith(artUri: extractedUri);
        
        final updatedQueue = List<MediaItem>.from(queue.value);
        updatedQueue[index] = item;
        queue.add(updatedQueue);
      }
    }

    mediaItem.add(item);
  }

  Future<void> _onPositionChanged(Duration position) async {
    if (_currentSongId == null) return;

    // 🎯 FIXED: Detect if a song on Repeat-One has restarted and reset the history counter
    if (_lastPosition != null && position.inMilliseconds < _lastPosition!.inMilliseconds && position.inSeconds < 1) {
      _currentSongCounted = false;
    }
    _lastPosition = position;

    if (_currentSongCounted) return;

    final tag = _player.sequenceState?.currentSource?.tag;
    final duration = (tag is MediaItem) ? tag.duration : null;
    if (duration == null || duration.inMilliseconds <= 0) return;

    final thresholdMs = min(30000, duration.inMilliseconds ~/ 2);
    if (position.inMilliseconds < thresholdMs) return;

    _currentSongCounted = true;

    try {
      await _db.historyDao.recordPlay(
        songId: _currentSongId!,
        listenedMs: position.inMilliseconds,
        counted: true,
        skippedEarly: false,
      );
    } catch (_) {}
  }

  // ─── Audio Effects ─────────────────────────────────────────

  @override
  Future<void> setSpeed(double speed) async { 
    _playbackSpeed = speed;
    await _player.setSpeed(speed);
  }

  Future<void> setVolume(double volume) => _player.setVolume(volume.clamp(0.0, 1.0));

  // ─── OS Playback State Mapping ─────────────────────────────

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle:      AudioProcessingState.idle,
        ProcessingState.loading:   AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready:     AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState] ?? AudioProcessingState.idle,
      playing:           _player.playing,
      updatePosition:    _player.position,
      bufferedPosition:  _player.bufferedPosition,
      speed:             _player.speed,
      queueIndex:        event.currentIndex,
      repeatMode: const {
        LoopMode.off: AudioServiceRepeatMode.none,
        LoopMode.one: AudioServiceRepeatMode.one,
        LoopMode.all: AudioServiceRepeatMode.all,
      }[_player.loopMode] ?? AudioServiceRepeatMode.none,
      shuffleMode: _player.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────

  void _updateCurrentMediaItem() {
    final index = _player.currentIndex;
    if (index != null && index < queue.value.length) {
      mediaItem.add(queue.value[index]);
    }
  }

  String _pathFor(MediaItem item) => item.extras?['path']?.toString() ?? '';

  String _serializeQueue(List<MediaItem> items) {
    return jsonEncode(items.map((item) => {
      'id':       item.id,
      'title':    item.title,
      'artist':   item.artist,
      'album':    item.album,
      'duration': item.duration?.inMilliseconds,
      'artUri':   item.artUri?.toString(),
      'extras':   item.extras,
    }).toList());
  }

  List<MediaItem> _deserializeQueue(String json) {
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((map) => MediaItem(
        id:        map['id']?.toString() ?? '',
        title:     map['title']?.toString() ?? 'Unknown',
        artist:    map['artist']?.toString(),
        album:     map['album']?.toString(),
        duration: map['duration'] != null
            ? Duration(milliseconds: map['duration'] as int)
            : null,
        artUri: map['artUri'] != null
            ? Uri.tryParse(map['artUri'].toString())
            : null,
        extras: (map['extras'] as Map?)
            ?.map((k, v) => MapEntry(k.toString(), v)),
      )).toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Cleanup ───────────────────────────────────────────────

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  @override
  Future<void> onNotificationDeleted() async {
    await stop();
  }

  Future<void> dispose() async {
    await _saveQueueState();
    _saveTimer?.cancel();
    for (final sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
    await _player.dispose();
  }
}