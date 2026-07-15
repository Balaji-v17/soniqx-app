// ============================================================
//  SONIQ — lib/providers/library_filter_provider.dart
//  State management for Library language filtering.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart'; 
import 'package:soniq/database/database.dart';

// 1. Holds the currently selected language filter. Defaults to showing everything.
final libraryFilterProvider = StateProvider<String>((ref) => 'All Tracks');

// 2. Watches the database and applies the filter in real-time.
final filteredLibraryProvider = StreamProvider<List<Song>>((ref) {
  final db = ref.watch(databaseProvider);
  final currentFilter = ref.watch(libraryFilterProvider);

  return db.songsDao.watchAllAvailable().map((songs) {
    if (currentFilter == 'All Tracks') {
      return songs;
    }
    
    // Filter the list to only include songs that match the tapped chip
    return songs.where((song) {
      // 🎯 FIXED: Updated to use song.genre to match your Drift schema
      final tag = song.genre?.toLowerCase() ?? 'untagged';
      return tag == currentFilter.toLowerCase();
    }).toList();
  });
});