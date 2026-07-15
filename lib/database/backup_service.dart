// ============================================================
//  SONIQ — lib/database/backup_service.dart
//  JSON Export/Import Engine for User Data.
// ============================================================

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';
import 'package:drift/drift.dart' as drift;

final backupServiceProvider = Provider((ref) => BackupService(ref.watch(databaseProvider)));

class BackupService {
  final AppDatabase _db;
  BackupService(this._db);

  /// 🎯 EXPORT: Serializes the database to a JSON string
  Future<String> exportBackup() async {
    final history = await _db.select(_db.playHistory).get();
    
    // Convert Drift data to standard Maps
    final historyList = history.map((h) => {
      'songId': h.songId,
      'playedAt': h.playedAt.toIso8601String(),
    }).toList();

    // In a full implementation, you would add Playlists and AppSettings here too.
    final backupData = {
      'version': 1,
      'exportDate': DateTime.now().toIso8601String(),
      'playHistory': historyList,
    };

    return jsonEncode(backupData);
  }

  /// 🎯 IMPORT: Parses JSON and safely restores data
  Future<void> importBackup(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      
      // Version check (crucial for future schema changes)
      if (data['version'] == null || data['version'] > 1) {
        throw Exception('Unsupported backup version.');
      }

      final List historyList = data['playHistory'] ?? [];

      // Run everything in a batch for high performance and safety
      await _db.batch((batch) {
        // Clear old history to prevent duplicates
        batch.deleteAll(_db.playHistory);
        
        // Insert restored history
        final restoredHistory = historyList.map((h) => PlayHistoryCompanion.insert(
          songId: h['songId'],
          playedAt: drift.Value(DateTime.parse(h['playedAt'])),
        )).toList();
        
        batch.insertAll(_db.playHistory, restoredHistory);
      });
      
      print('✅ Backup restored successfully!');
    } catch (e) {
      print('⚠️ Failed to restore backup: $e');
      rethrow;
    }
  }
}