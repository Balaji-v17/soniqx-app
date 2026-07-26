// ============================================================
//  SONIQ — lib/providers/search_provider.dart
//  Real-time, reactive search engine.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';

// 1. Holds the current text typed into the search bar
final searchQueryProvider = StateProvider<String>((ref) => '');

// 2. Automatically filters the main database list whenever the query changes
final searchResultsProvider = Provider<AsyncValue<List<Song>>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final allSongsAsync = ref.watch(allSongsStreamProvider);

  return allSongsAsync.whenData((allSongs) {
    if (query.isEmpty) {
      return []; // Return empty if there's no search term
    }

    // Filter tracks where the title, artist, or album matches the query
    return allSongs.where((song) {
      final titleMatch = song.title?.toLowerCase().contains(query) ?? false;
      final artistMatch = song.artist?.toLowerCase().contains(query) ?? false;
      final albumMatch = song.album?.toLowerCase().contains(query) ?? false;
      
      return titleMatch || artistMatch || albumMatch;
    }).toList();
  });
});