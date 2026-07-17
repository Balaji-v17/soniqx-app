// ============================================================
//  SONIQ — lib/classifier/language_seed_db.dart
//  Priority-safe, OTA-Aware static cache layer.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:soniq/database/database.dart';
import 'seed_updater.dart';

class LanguageSeedDb {
  static Map<String, Map<String, double>>? _cachedDb;

  static Map<String, Map<String, double>> get rawCache {
    if (_cachedDb == null) {
      throw StateError('🧠 LanguageSeedDb was accessed before ensureLoaded() resolved.');
    }
    return _cachedDb!;
  }

  /// Evaluates and hydrates the highest-priority database instance available.
  static Future<void> ensureLoaded(AppDatabase db) async {
    if (_cachedDb != null) return; // Cache hit, skip filesystem I/O

    try {
      final updater = SeedUpdater(db);
      
      // 🎯 Dynamic evaluation priority: local OTA document -> bundled asset file
      final Map<String, dynamic> rawJsonData = await updater.loadSeedDatabase();
      
      // 🎯 THE FIX: Smart parsing that handles both nested and flat JSON structures
      final Map<String, dynamic> artistsMap = rawJsonData.containsKey('artists') 
          ? rawJsonData['artists'] as Map<String, dynamic>
          : rawJsonData; 

      final Map<String, Map<String, double>> parsedDb = {};

      artistsMap.forEach((artistKey, langMap) {
        if (langMap is Map) {
          final Map<String, double> weights = {};
          langMap.forEach((langKey, weightValue) {
            weights[langKey.toString()] = double.tryParse(weightValue.toString()) ?? 0.0;
          });
          parsedDb[artistKey.toString()] = weights;
        }
      });

      _cachedDb = parsedDb;
      debugPrint('🧠 Hydrated seed database containing ${parsedDb.length} parsed profiles.');
    } catch (e) {
      debugPrint('🚨 Failed to parse seed payload safely: $e');
      _cachedDb = {}; // Prevent cascade lockups on zero data bounds
    }
  }
}