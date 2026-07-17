// ============================================================
//  SONIQ — lib/providers.dart
//  Global Dependency Injection Hub
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/audio/soniq_audio_handler.dart';
import 'package:soniq/providers/library_filter_provider.dart';

/// Provides global access to the Drift AppDatabase.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in ProviderScope');
});

/// Provides global access to the SoniqAudioHandler.
final audioHandlerProvider = Provider<SoniqAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in ProviderScope');
});

/// Stream provider for all available songs — the single source of truth for the list.
final allSongsStreamProvider = StreamProvider<List<Song>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.songsDao.watchAllAvailable();
});

/// 🎯 OPTIMIZED & ROBUST: Filters by checking both full words (legacy/manual tags) 
/// and 3-letter ISO codes (new AI tags).
final filteredSongsProvider = Provider<AsyncValue<List<Song>>>((ref) {
  final allSongsAsync = ref.watch(allSongsStreamProvider);
  final activeFilter = ref.watch(libraryFilterProvider);

  return allSongsAsync.whenData((allSongs) {
    if (activeFilter == 'All Tracks') return allSongs;
    
    return allSongs.where((s) {
      final manualTag = s.languageTag?.toLowerCase().trim() ?? '';
      final autoTag = s.genre?.toLowerCase().trim() ?? '';
      
      // Handle the fallback state for broken/stripped files
      if (activeFilter == 'Unclassified') {
        return (manualTag.isEmpty && autoTag.isEmpty) || 
               manualTag == 'und' || 
               autoTag == 'und';
      }
      
      final targetFull = activeFilter.toLowerCase().trim();
      
      // Map to the short AI codes
      String targetShort = '';
      switch (targetFull) {
        case 'hindi': targetShort = 'hin'; break;
        case 'tamil': targetShort = 'tam'; break;
        case 'kannada': targetShort = 'kan'; break;
        case 'telugu': targetShort = 'tel'; break;
        case 'malayalam': targetShort = 'mal'; break;
        case 'english': targetShort = 'eng'; break;
      }
      
      // Match if the database holds the full word OR the short code
      final manualMatch = manualTag == targetFull || (targetShort.isNotEmpty && manualTag == targetShort);
      final autoMatch = autoTag == targetFull || (targetShort.isNotEmpty && autoTag == targetShort);
      
      return manualMatch || autoMatch;
    }).toList();
  });
});