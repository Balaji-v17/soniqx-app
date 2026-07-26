// ============================================================
//  SONIQ — lib/audio/audio_handler.dart
//  Core playback engine & background lockscreen sync.
// ============================================================

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:soniq/database/database.dart'; 

class SoniqAudioHandler extends BaseAudioHandler with SeekHandler {
  final AppDatabase _db;
  
  late final AudioPlayer _player;
  final AndroidEqualizer _equalizer = AndroidEqualizer();
  
  // 🎯 PUBLIC GETTERS FOR YOUR UI SCREENS
  AudioPlayer get player => _player;
  AndroidEqualizer get equalizer => _equalizer;
  
  // A concatenated playlist allows for gapless playback
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);

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

    // 🎯 3. FIXED: Listen to the true sequence state to magically reorder your UI Queue!
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState == null) return;

      // Automatically updates the visual queue to match the Shuffled order
      final effectiveQueue = sequenceState.effectiveSequence
          .map((source) => source.tag as MediaItem)
          .toList();
      queue.add(effectiveQueue);

      // Keep the currently playing track metadata synced
      final currentSource = sequenceState.currentSource;
      if (currentSource != null) {
        mediaItem.add(currentSource.tag as MediaItem);
      }
    });
  }

  // ─── QUEUE MANAGEMENT ────────────────────────────────────────

  @override
  Future<void> updateQueue(List<MediaItem> newQueue) async {
    // Optimistic UI update
    queue.add(newQueue);
    
    final audioSources = newQueue.map((item) {
      final path = item.extras?['path'] as String?;
      if (path != null && path.isNotEmpty) {
        return AudioSource.file(path, tag: item);
      }
      return AudioSource.uri(Uri.parse(''), tag: item);
    }).toList();

    await _playlist.clear();
    await _playlist.addAll(audioSources);
    await _player.setAudioSource(_playlist);
  }

  // 🎯 FIXED: Maps your tapped UI item back to the original JustAudio index
  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    
    // Grab the item the user tapped from the Shuffled UI list
    final targetItem = queue.value[index];
    
    // Find where it actually lives in the player's true backend playlist
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
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enable = shuffleMode == AudioServiceShuffleMode.all;
    
    if (enable) {
      await _player.shuffle(); 
    }
    await _player.setShuffleModeEnabled(enable);

    playbackState.add(playbackState.value.copyWith(
      shuffleMode: shuffleMode,
    ));
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    LoopMode loopMode;
    switch (repeatMode) {
      case AudioServiceRepeatMode.all:
        loopMode = LoopMode.all; 
        break;
      case AudioServiceRepeatMode.one:
        loopMode = LoopMode.one; 
        break;
      default:
        loopMode = LoopMode.off; 
        break;
    }
    
    await _player.setLoopMode(loopMode);

    playbackState.add(playbackState.value.copyWith(
      repeatMode: repeatMode,
    ));
  }

  // ─── SYSTEM SYNC ─────────────────────────────────────────────

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final currentItem = mediaItem.value;
    
    // 🎯 FIXED: Ensures the system lockscreen queue index matches our Shuffled UI index
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
    ));
  }
}