// ============================================================
//  SONIQ — lib/providers.dart
//  Global Dependency Injection Hub
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/audio/audio_handler.dart'; 
import 'package:soniq/providers/library_filter_provider.dart';
import 'package:soniq/audio/music_scanner.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in ProviderScope');
});

final audioHandlerProvider = Provider<SoniqAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in ProviderScope');
});

final allSongsStreamProvider = StreamProvider<List<Song>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.songsDao.watchAllAvailable();
});

// ─── Sort Order State ─────────────────────────────────────────

enum SortOrder { newestFirst, oldestFirst, aToZ, zToA, artist }
final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.newestFirst);

// ─── Filter & Sort Logic ──────────────────────────────────────

final filteredSongsProvider = Provider<AsyncValue<List<Song>>>((ref) {
  final allSongsAsync = ref.watch(allSongsStreamProvider);
  final activeFilter = ref.watch(libraryFilterProvider);
  final sortOrder = ref.watch(sortOrderProvider); 

  return allSongsAsync.whenData((allSongs) {
    Iterable<Song> filtered = allSongs;
    
    if (activeFilter != 'All Tracks') {
      filtered = allSongs.where((s) {
        final manualTag = s.languageTag?.toLowerCase().trim() ?? '';
        final autoTag = s.genre?.toLowerCase().trim() ?? '';
        
        if (activeFilter == 'Unclassified') {
          return (manualTag.isEmpty && autoTag.isEmpty) || 
                 manualTag == 'und' || 
                 autoTag == 'und';
        }
        
        final targetFull = activeFilter.toLowerCase().trim();
        String targetShort = '';
        switch (targetFull) {
          case 'hindi': targetShort = 'hin'; break;
          case 'tamil': targetShort = 'tam'; break;
          case 'kannada': targetShort = 'kan'; break;
          case 'telugu': targetShort = 'tel'; break;
          case 'malayalam': targetShort = 'mal'; break;
          case 'english': targetShort = 'eng'; break;
        }
        
        final manualMatch = manualTag == targetFull || (targetShort.isNotEmpty && manualTag == targetShort);
        final autoMatch = autoTag == targetFull || (targetShort.isNotEmpty && autoTag == targetShort);
        
        return manualMatch || autoMatch;
      });
    }
    
    final resultList = filtered.toList();
    
    resultList.sort((a, b) {
      switch (sortOrder) {
        case SortOrder.newestFirst:
          // 🎯 FIXED: Updated to ctimeNs with null safety fallback
          int cmp = (b.ctimeNs ?? 0).compareTo(a.ctimeNs ?? 0);
          if (cmp == 0) cmp = b.firstSeen.compareTo(a.firstSeen);
          if (cmp == 0) cmp = b.id.compareTo(a.id);
          return cmp;

        case SortOrder.oldestFirst:
          // 🎯 FIXED: Updated to ctimeNs with null safety fallback
          int cmp = (a.ctimeNs ?? 0).compareTo(b.ctimeNs ?? 0);
          if (cmp == 0) cmp = a.firstSeen.compareTo(b.firstSeen);
          if (cmp == 0) cmp = a.id.compareTo(b.id);
          return cmp;

        case SortOrder.aToZ:
          final cmp = (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase());
          if (cmp == 0) return a.id.compareTo(b.id);
          return cmp;

        case SortOrder.zToA:
          final cmp = (b.title ?? '').toLowerCase().compareTo((a.title ?? '').toLowerCase());
          if (cmp == 0) return b.id.compareTo(a.id);
          return cmp;

        case SortOrder.artist:
          final cmp = (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase());
          if (cmp == 0) return (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase());
          return cmp;
      }
    });

    return resultList;
  });
});

// ─── Scan Progress State ───────────────────────────────────────

class ScanStateNotifier extends StateNotifier<ScanProgress> {
  final MusicScanner _scanner;
  
  ScanStateNotifier(this._scanner) : super(const ScanProgress(phase: ScanPhase.complete));

  Future<void> startScan({bool computeHashes = false}) async {
    if (state.phase != ScanPhase.complete && state.phase != ScanPhase.error) return;
    
    final subscription = _scanner.progress.listen((progress) {
      if (mounted) state = progress;
    });
    
    await _scanner.scanAndSync(computeHashes: computeHashes);
    await subscription.cancel();
  }
}

final scanProvider = StateNotifierProvider<ScanStateNotifier, ScanProgress>((ref) {
  final db = ref.watch(databaseProvider);
  final scanner = MusicScanner(db);
  return ScanStateNotifier(scanner);
});