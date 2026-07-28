import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers.dart';

class DurationHealerService {
  static const _channel = MethodChannel('com.soniq.music/healer');
  final AppDatabase _db;
  bool _isHealing = false;

  DurationHealerService(this._db);

  Future<void> runHealerPass() async {
    if (_isHealing) return; // Prevent overlapping runs
    _isHealing = true;

    try {
      final brokenSongs = await (_db.select(_db.songs)
        ..where((s) => s.durationMs.equals(0) | s.durationMs.isNull()))
        .get();

      if (brokenSongs.isEmpty) return;
      
      final idsToHeal = brokenSongs.map((s) => s.id).toList();

      // 🎯 THE FIX: Process in chunks of 25 so Android doesn't kill the native thread!
      const chunkSize = 25; 
      for (var i = 0; i < idsToHeal.length; i += chunkSize) {
        final end = (i + chunkSize < idsToHeal.length) ? i + chunkSize : idsToHeal.length;
        final chunk = idsToHeal.sublist(i, end);

        try {
          final Map<dynamic, dynamic>? rawResults = await _channel.invokeMethod(
            'healDurations', {'ids': chunk},
          );

          if (rawResults != null && rawResults.isNotEmpty) {
            await _db.batch((batch) {
              rawResults.forEach((id, durationMs) {
                batch.update(
                  _db.songs,
                  SongsCompanion(durationMs: Value(durationMs as int)),
                  where: (t) => t.id.equals(id as int), 
                );
              });
            });
          }
        } catch (e) {
          print("Healer chunk failed: $e");
        }
        
        // 🎯 Give the UI and Garbage Collector 500ms to breathe before the next chunk
        await Future.delayed(const Duration(milliseconds: 500)); 
      }
    } finally {
      _isHealing = false;
    }
  }
}

final durationHealerServiceProvider = Provider<DurationHealerService>((ref) {
  final db = ref.watch(databaseProvider);
  return DurationHealerService(db);
});