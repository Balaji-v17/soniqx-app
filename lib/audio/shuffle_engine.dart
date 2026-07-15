// ============================================================
//  SONIQ — lib/audio/shuffle_engine.dart
//  Production shuffle engine | July 2026
// ============================================================

import 'dart:math';
import '../database/database.dart';

class ShuffleResult {
  final List<Song> queue;
  final int seed;
  final ShuffleStats stats;

  const ShuffleResult({
    required this.queue,
    required this.seed,
    required this.stats,
  });
}

class ShuffleStats {
  final int totalSongs;
  final int artistGroups;
  final int languageGroups;
  final int recencyPenalised;
  final Duration computeTime;

  const ShuffleStats({
    required this.totalSongs,
    required this.artistGroups,
    required this.languageGroups,
    required this.recencyPenalised,
    required this.computeTime,
  });

  @override
  String toString() =>
      'ShuffleStats('
      'songs=$totalSongs, '
      'artists=$artistGroups, '
      'languages=$languageGroups, '
      'penalised=$recencyPenalised, '
      'time=${computeTime.inMilliseconds}ms'
      ')';
}

class _PositionedSong {
  final Song song;
  final double position;
  const _PositionedSong({required this.song, required this.position});
}

class SoniqShuffleEngine {
  static const Duration recencyWindow = Duration(hours: 12);
  static const double recencyZoneStart = 0.75;
  static const double minArtistGapFraction = 0.10;

  ShuffleResult generateQueue(
    List<Song> songs, {
    Set<int> recentlyPlayedIds = const {},
    int? previousFirstSongId,
    int? seed,
  }) {
    final stopwatch = Stopwatch()..start();

    if (songs.isEmpty) {
      return ShuffleResult(
        queue: [],
        seed: seed ?? 0,
        stats: ShuffleStats(
          totalSongs: 0,
          artistGroups: 0,
          languageGroups: 0,
          recencyPenalised: 0,
          computeTime: Duration.zero,
        ),
      );
    }

    if (songs.length <= 4) {
      final usedSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
      final rng = Random(usedSeed);
      final result = List<Song>.from(songs);
      _fisherYates(result, rng);
      stopwatch.stop();
      return ShuffleResult(
        queue: result,
        seed: usedSeed,
        stats: ShuffleStats(
          totalSongs: result.length,
          artistGroups: 1,
          languageGroups: 1,
          recencyPenalised: 0,
          computeTime: stopwatch.elapsed,
        ),
      );
    }

    final usedSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    final rng = Random(usedSeed);

    // Phase 1: Group by artist
    final artistGroups = _groupBy<Song, String>(
      songs,
      (s) => _normalizeGroupKey(s.artist),
    );

    // Phase 2: Shuffle within each artist group
    for (final group in artistGroups.values) {
      _fisherYates(group, rng);
    }

    // Phase 3: Proportional interleaving
    final positioned = _interleave(artistGroups, songs.length, rng);

    // Phase 4: Language secondary interleaving
    final languageBalanced = _balanceLanguages(positioned, rng);

    final languageGroupCount = _groupBy<Song, String>(
      songs,
      (s) => s.genre ?? 'unknown',
    ).length;

    // Phase 5: Recency penalty
    int penalisedCount = 0;
    List<Song> finalQueue;
    if (recentlyPlayedIds.isEmpty) {
      finalQueue = languageBalanced;
    } else {
      final result = _applyRecencyPenalty(
        languageBalanced,
        recentlyPlayedIds,
        rng,
      );
      finalQueue = result.queue;
      penalisedCount = result.penalisedCount;
    }

    // Phase 6: Session memory
    if (previousFirstSongId != null &&
        finalQueue.isNotEmpty &&
        finalQueue.first.id == previousFirstSongId) {
      final swapRange = max(1, (finalQueue.length * 0.20).floor());
      final swapIndex = 1 + rng.nextInt(swapRange);
      if (swapIndex < finalQueue.length) {
        final temp = finalQueue[0];
        finalQueue[0] = finalQueue[swapIndex];
        finalQueue[swapIndex] = temp;
      }
    }

    stopwatch.stop();
    return ShuffleResult(
      queue: finalQueue,
      seed: usedSeed,
      stats: ShuffleStats(
        totalSongs: finalQueue.length,
        artistGroups: artistGroups.length,
        languageGroups: languageGroupCount,
        recencyPenalised: penalisedCount,
        computeTime: stopwatch.elapsed,
      ),
    );
  }

  ShuffleResult reshuffleRemaining(
    List<Song> currentQueue,
    int currentIndex, {
    int? seed,
  }) {
    if (currentIndex >= currentQueue.length - 1) {
      return ShuffleResult(
        queue: currentQueue,
        seed: seed ?? 0,
        stats: ShuffleStats(
          totalSongs: currentQueue.length,
          artistGroups: 0,
          languageGroups: 0,
          recencyPenalised: 0,
          computeTime: Duration.zero,
        ),
      );
    }
    final played = currentQueue.sublist(0, currentIndex + 1);
    final remaining = currentQueue.sublist(currentIndex + 1);
    final reshuffled = generateQueue(remaining, seed: seed);
    return ShuffleResult(
      queue: [...played, ...reshuffled.queue],
      seed: reshuffled.seed,
      stats: reshuffled.stats,
    );
  }

  void _fisherYates<T>(List<T> list, Random rng) {
    for (int i = list.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  List<Song> _interleave(
    Map<String, List<Song>> groups,
    int total,
    Random rng,
  ) {
    final positioned = <_PositionedSong>[];
    for (final entry in groups.entries) {
      final songs = entry.value;
      final count = songs.length;
      final spread = total / count;
      final offset = rng.nextDouble() * spread;
      for (int i = 0; i < count; i++) {
        positioned.add(_PositionedSong(
          song: songs[i],
          position: offset + i * spread,
        ));
      }
    }
    positioned.sort((a, b) => a.position.compareTo(b.position));
    return positioned.map((p) => p.song).toList();
  }

  List<Song> _balanceLanguages(List<Song> queue, Random rng) {
    if (queue.length < 6) return queue;
    final result = List<Song>.from(queue);
    const maxRun = 3;
    for (int i = maxRun; i < result.length; i++) {
      final currentLang = result[i].genre;
      if (currentLang == null) continue;
      int run = 0;
      for (int j = i - 1; j >= 0 && run < maxRun; j--) {
        if (result[j].genre == currentLang) run++;
        else break;
      }
      if (run >= maxRun) {
        final searchEnd = min(result.length, i + (result.length ~/ 4));
        for (int k = i + 1; k < searchEnd; k++) {
          if (result[k].genre != currentLang) {
            final temp = result[i];
            result[i] = result[k];
            result[k] = temp;
            break;
          }
        }
      }
    }
    return result;
  }

  _RecencyResult _applyRecencyPenalty(
    List<Song> queue,
    Set<int> recentIds,
    Random rng,
  ) {
    final normal = <Song>[];
    final penalty = <Song>[];
    for (final song in queue) {
      if (recentIds.contains(song.id)) {
        penalty.add(song);
      } else {
        normal.add(song);
      }
    }
    _fisherYates(penalty, rng);
    return _RecencyResult(
      queue: [...normal, ...penalty],
      penalisedCount: penalty.length,
    );
  }

  Map<K, List<T>> _groupBy<T, K>(List<T> items, K Function(T) keyOf) {
    final map = <K, List<T>>{};
    for (final item in items) {
      final key = keyOf(item);
      (map[key] ??= []).add(item);
    }
    return map;
  }

  String _normalizeGroupKey(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '__unknown__';
    return raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _RecencyResult {
  final List<Song> queue;
  final int penalisedCount;
  const _RecencyResult({required this.queue, required this.penalisedCount});
}