import 'package:audio_service/audio_service.dart';

/// A pure Dart stream that ticks every 200ms to calculate smooth playback position.
Stream<Duration> createPositionStream(AudioHandler audioHandler) {
  return Stream.periodic(const Duration(milliseconds: 200)).map((_) {
    final state = audioHandler.playbackState.value;
    
    if (state.playing) {
      // Calculate how much time has passed since the native engine last updated us
      final timeSinceLastUpdate = DateTime.now().difference(state.updateTime);
      
      // Calculate the exact current position by adding the elapsed time (factoring in playback speed)
      final positionDelta = (timeSinceLastUpdate.inMilliseconds * state.speed).round();
      return Duration(milliseconds: state.position.inMilliseconds + positionDelta);
    }
    
    // If paused, just return the frozen snapshot position
    return state.position;
  }).distinct(); // Only trigger UI rebuilds if the calculated time actually changes
}