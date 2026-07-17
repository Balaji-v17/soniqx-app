// ============================================================
//  SONIQ — lib/classifier/language_service.dart
//  Batch orchestrator & AI Feedback Loop.
// ============================================================

import 'dart:isolate';
import 'package:path/path.dart' as p; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';
import 'language_seed_db.dart';
import 'language_classifier.dart';
import 'seed_updater.dart'; 
import 'package:soniq/classifier/fallback_classifier.dart'; // 🎯 NEW: Imported the Signal Cascade!

final languageServiceProvider = Provider((ref) {
  return LanguageService(ref.watch(databaseProvider));
});

class LanguageService {
  final AppDatabase _db;
  bool _isClassifying = false;

  LanguageService(this._db);

  /// Scans the DB for untagged songs and runs the AI classifier in the background.
  Future<void> runClassificationPass() async {
    if (_isClassifying) return;
    _isClassifying = true;

    try {
      await LanguageSeedDb.ensureLoaded(_db);
      final databasePayload = LanguageSeedDb.rawCache;

      final unclassified = await _db.songsDao.getUnclassifiedSongs();
      if (unclassified.isEmpty) {
        print('🤖 All songs classified. Nothing to do.');
        return;
      }

      print('🤖 Found ${unclassified.length} unclassified songs. Starting isolated AI batch...');

      const chunkSize = 50;
      for (var i = 0; i < unclassified.length; i += chunkSize) {
        final end = (i + chunkSize < unclassified.length) ? i + chunkSize : unclassified.length;
        final chunk = unclassified.sublist(i, end);

        final requests = chunk.map((s) => {
          'id': s.id,
          'title': s.title ?? '',
          'artist': s.artist ?? '',
          'album': s.album ?? '',
          'path': s.path, 
        }).toList();

        final isolateBundle = {
          'db': databasePayload,
          'tracks': requests,
        };

        final results = await Isolate.run(() => _processChunkInIsolate(isolateBundle));

        for (final result in results) {
          final songId = result['id'] as int;
          final conf = result['confidence'] as double;
          final lang = result['language'] as String?;
          final needsManual = result['needsManual'] as bool;

          print('🎯 [DEBUG] Batch Result -> ID: $songId | Score: $conf | Lang: $lang | Manual: $needsManual');

          // Only auto-classify if it confidently passed the primary cascade OR the heuristic fallback
          if (!needsManual && lang != null && lang != 'und') {
            await _db.songsDao.autoClassify(songId, lang, conf);
            print('✅ Auto-Tagged: $lang ($conf) -> Song ID: $songId');
          }
        }
      }
      
      // 🎯 STRATEGY 4: Run the post-processing directory consensus check!
      print('📂 AI: Initial batch completed. Running Directory Sibling Consensus sweep...');
      await _applyDirectoryConsensus();
      
      print('🤖 AI Classification batch complete cleanly!');
    } catch (e) {
      print('🚨 AI Classification error: $e');
    } finally {
      _isClassifying = false;
    }
  }

  /// 🎯 Strategy 4 Post-Scan Consensus Logic
  Future<void> _applyDirectoryConsensus() async {
    final remainingUntagged = await _db.songsDao.getUnclassifiedSongs();
    
    for (final song in remainingUntagged) {
      try {
        final directory = p.dirname(song.path);
        final folderName = p.basename(directory).toLowerCase();

        // 🚫 THE FIX: Stop Contagion! Do not run consensus on massive root dump folders.
        const blacklistedFolders = {
          '0', 'emulated', 'download', 'downloads', 'music', 'audio',
          'com.video.fun.app', 'vidmate', 'telegram' // 🎯 ADDED: App-specific dump folders
        };
        
        if (blacklistedFolders.contains(folderName)) {
          print('🚫 Skipping consensus check for root dump folder: $folderName');
          continue; 
        }

        final siblings = await _db.songsDao.getSongsInDirectory(directory);

        // Filter to find neighbors that have already been confidently classified
        final classifiedSiblings = siblings
            .where((s) => s.id != song.id && s.languageTag != null && s.languageTag != 'und')
            .toList();

        if (classifiedSiblings.length < 3) continue; // Skip if there isn't enough context

        // Count language votes among neighbors
        final tally = <String, int>{};
        for (final s in classifiedSiblings) {
          tally[s.languageTag!] = (tally[s.languageTag!] ?? 0) + 1;
        }

        // Determine the dominant language in this folder
        final topEntry = tally.entries.reduce((a, b) => a.value > b.value ? a : b);
        final topLanguage = topEntry.key;
        final topCount = topEntry.value;
        final consensus = topCount / classifiedSiblings.length;

        // Override and auto-classify if folder consensus is >= 65%
        if (consensus >= 0.65) {
          await _db.songsDao.autoClassify(
            song.id,
            topLanguage,
            consensus * 0.80, // Apply slightly discounted confidence
          );
          print('✨ Consensus Match: Tagged ID ${song.id} as $topLanguage via ${ (consensus * 100).toStringAsFixed(0) }% folder agreement.');
        }
      } catch (e) {
        print('⚠️ Failed to calculate neighbor consensus for song ID ${song.id}: $e');
      }
    }
  }

  /// Runs periodically to learn from user tagging and check for OTA updates.
  Future<void> runWeeklyMaintenance() async {
    print('🛠️ Starting AI Maintenance Cycle...');
    try {
      await _db.languageDao.applyPendingCorrections();
      print('🧠 AI successfully learned from recent manual tags!');
      
      print('📡 Contacting GitHub infrastructure for database updates...');
      final updater = SeedUpdater(_db);
      final status = await updater.checkAndUpdate();
      print('📡 OTA Check Complete: $status');
    } catch (e) {
      print('🚨 Maintenance error: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> _processChunkInIsolate(Map<String, dynamic> bundle) async {
    final Map<String, Map<String, double>> localDb = Map<String, Map<String, double>>.from(bundle['db']);
    final List<Map<String, dynamic>> tracks = List<Map<String, dynamic>>.from(bundle['tracks']);
    final List<Map<String, dynamic>> results = [];
    
    // 🎯 INITIALIZE FALLBACK CLASSIFIER ONCE PER CHUNK
    final fallbackClassifier = FallbackClassifier(
      seedDb: localDb,
      albumPatterns: {
        'mungaru male': 'Kannada',
        'kgf': 'Kannada',
        'kantara': 'Kannada',
        'pushpa': 'Telugu',
        'rrr': 'Telugu',
        'bahubali': 'Telugu',
        'vikram': 'Tamil',
        'leo': 'Tamil',
        'jailer': 'Tamil',
        'aashiqui': 'Hindi',
        'jawan': 'Hindi',
        'pathaan': 'Hindi',
        'animal': 'Hindi',
      },
    );

    for (final req in tracks) {
      // 1. Attempt Primary Metadata NLP Classification
      final res = LanguageClassifier.classify(
        title: req['title'],
        artist: req['artist'],
        album: req['album'],
        localDb: localDb,
      );
      
      String? finalLang = res.language;
      bool manualNeeded = res.needsManual;
      double finalConf = res.confidence;

      // 2. 🎯 HEURISTIC FALLBACK: Triggered if metadata is completely stripped/useless
      if (finalLang == null || finalLang == 'und' || manualNeeded) {
        
        final fallbackResult = fallbackClassifier.classify(req['path']);

        if (fallbackResult.language != null && fallbackResult.language != 'und') {
          finalLang = fallbackResult.language;
          manualNeeded = !fallbackResult.shouldAutoTag; 
          finalConf = fallbackResult.confidence;
        } else {
          finalLang = 'und';
          manualNeeded = true;
        }
      }
      
      results.add({
        'id': req['id'],
        'language': finalLang,
        'confidence': finalConf,
        'needsManual': manualNeeded,
      });
    }
    
    return results;
  }
}