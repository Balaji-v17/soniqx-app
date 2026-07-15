import 'package:drift/drift.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/src/pigeon/audio_scanner.g.dart';

class SyncWorker {
  static Future<void> syncSongsToDatabase(AppDatabase db, List<RawSongData> nativeSongs) async {
    await db.batch((batch) {
      for (final raw in nativeSongs) {
        
        // Filter out any corrupted files missing critical system data
        if (raw.id == null || raw.path == null) {
          continue; 
        }

        batch.insert(
          db.songs,
          SongsCompanion.insert(
            id: Value(raw.id!), 
            path: raw.path!,    
            title: Value(raw.title ?? 'Unknown Track'),
            artist: Value(raw.artist ?? 'Unknown Artist'),
            album: Value(raw.album ?? 'Unknown Album'),
            albumId: raw.albumId ?? 0, // 🎯 FIXED: Wrapped in Value() for nullable support
            albumArtist: Value(raw.albumArtist),
            genre: Value(raw.genre),
            durationMs: Value(raw.durationMs ?? 0),
            trackNumber: Value(raw.trackNumber ?? 0),
            discNumber: Value(raw.discNumber ?? 1),
            year: Value(raw.year),
         dateAdded: raw.dateAdded ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }
}