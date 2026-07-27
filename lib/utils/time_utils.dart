String formatSongDuration(int? rawMs) {
  // 🎯 CHANGE: Return '--:--' so the user knows it's uncalculated, not a 0-second file.
  if (rawMs == null || rawMs <= 0) return '--:--';

  final int safeMs = (rawMs < 10000) ? rawMs * 1000 : rawMs;
  // ... rest of the code remains the same
  final duration = Duration(milliseconds: safeMs);
  final minutes = duration.inMinutes;
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  if (duration.inHours > 0) {
    final hours = duration.inHours;
    final remainingMins = (minutes % 60).toString().padLeft(2, '0');
    return '$hours:$remainingMins:$seconds';
  }

  return '$minutes:$seconds';
}
