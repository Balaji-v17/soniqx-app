// ============================================================
//  SONIQ — lib/classifier/language_seed_db.dart
//  Priority-safe, OTA-Aware static cache layer.
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:soniq/database/database.dart';
import 'seed_updater.dart';

class LanguageSeedDb {
  static Map<String, Map<String, double>>? _cachedDb;

  // 🎯 THE FIX: Hardcoded Emergency Overrides
  // This bypasses the JSON file entirely. No matter how broken the JSON is,
  // these artists will ALWAYS be correctly tagged.
static const Map<String, Map<String, double>> _hardcodedOverrides = {
    // Tamil & Telugu
    'dhanush': {'Tamil': 0.9},
    'dhee': {'Tamil': 0.9},
    'anirudh ravichander': {'Tamil': 0.9, 'Telugu': 0.1},
    'g.v. prakash': {'Tamil': 0.9},
    'ken karunaas': {'Tamil': 1.0},
    'vishal chandrashekhar': {'Telugu': 0.9, 'Tamil': 0.1},
    'chinmayi sripada': {'Telugu': 0.8, 'Tamil': 0.2},
    
    // Kannada
    'v sridhar': {'Kannada': 1.0},
    'v. sridhar': {'Kannada': 1.0},
    'b. ajaneesh loknath': {'Kannada': 1.0},
    'b ajaneesh': {'Kannada': 1.0},
    'yogaraj bhat': {'Kannada': 1.0},
    'chintan vikas': {'Kannada': 1.0},
    'sanjith hegde': {'Kannada': 1.0},
    'kailash kher': {'Kannada': 0.8, 'Hindi': 0.2},
    'shankar mahadevan': {'Kannada': 0.6, 'Hindi': 0.4},
    'varun ramachandra': {'Kannada': 1.0},

    // Hindi (Bollywood Additions)
    'pritam': {'Hindi': 1.0},
    'atif aslam': {'Hindi': 1.0},
    'irshad kamil': {'Hindi': 1.0},
    'shashwat sachdev': {'Hindi': 1.0},
    
    // Malayalam (Mollywood Additions)
    'sushin shyam': {'Malayalam': 1.0},
  };
  static Map<String, Map<String, double>> get rawCache {
    if (_cachedDb == null) {
      throw StateError('🧠 LanguageSeedDb was accessed before ensureLoaded() resolved.');
    }
    return _cachedDb!;
  }

  static Future<void> ensureLoaded(AppDatabase db) async {
    if (_cachedDb != null) return;

    final Map<String, Map<String, double>> parsedDb = {};

    try {
      final updater = SeedUpdater(db);
      final Map<String, dynamic> rawJsonData = await updater.loadSeedDatabase();

      final Map<String, dynamic> artistsMap = rawJsonData.containsKey('artists') 
          ? rawJsonData['artists'] as Map<String, dynamic>
          : rawJsonData; 

      artistsMap.forEach((artistKey, artistData) {
        if (artistData is Map) {
          final Map<String, double> weights = {};
          
          if (artistData.containsKey('scores') && artistData['scores'] is Map) {
            final Map scoresMap = artistData['scores'] as Map;
            scoresMap.forEach((langKey, weightValue) {
              weights[langKey.toString()] = double.tryParse(weightValue.toString()) ?? 0.0;
            });
          } else {
            artistData.forEach((langKey, weightValue) {
              if (weightValue is num || double.tryParse(weightValue.toString()) != null) {
                weights[langKey.toString()] = double.tryParse(weightValue.toString()) ?? 0.0;
              }
            });
          }

          if (weights.isNotEmpty) {
            parsedDb[artistKey.toString().toLowerCase().trim()] = weights;
          }
        }
      });
      debugPrint('🧠 Hydrated JSON database with ${parsedDb.length} artists.');
    } catch (e) {
      // If the JSON has a missing comma, it falls here safely without crashing the app.
      debugPrint('🚨 JSON Syntax Error: $e. Using empty base DB.');
    }

    // 🎯 THE MERGE: Inject the hardcoded overrides INTO the parsed DB.
    // This runs even if the JSON parsing completely failed.
    _hardcodedOverrides.forEach((artist, weights) {
      parsedDb[artist] = weights;
    });

    _cachedDb = parsedDb;
    debugPrint('🛡️ Injected ${_hardcodedOverrides.length} hardcoded override rules.');
  }
}