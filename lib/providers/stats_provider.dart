// ============================================================
//  SONIQ — lib/providers/stats_provider.dart
//  Analytics queries for the Stats Dashboard.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';

// Provides the total number of songs played
final totalPlaysProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(databaseProvider);
  final history = await db.select(db.playHistory).get();
  return history.length;
});

// Provides the top 5 most played songs
final topSongsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.watch(databaseProvider);
  
  // Custom SQL to group history by song and count occurrences
  final query = db.customSelect(
    '''
    SELECT s.title, s.artist, COUNT(h.id) as play_count 
    FROM play_history h
    INNER JOIN songs s ON h.song_id = s.id
    GROUP BY h.song_id
    ORDER BY play_count DESC
    LIMIT 5
    '''
  );

  final results = await query.get();
  return results.map((row) => {
    'title': row.read<String>('title'),
    'artist': row.read<String>('artist'),
    'count': row.read<int>('play_count'),
  }).toList();
});