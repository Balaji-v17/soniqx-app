import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database/database.dart';
import '../classifier/language_service.dart';

class AudioScannerService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AppDatabase _db;
  final LanguageService _languageService;

  AudioScannerService(this._db, this._languageService);

  /// Main execution method: Scans, Classifies, and Hydrates DB
  Future<void> runFullScan() async {
    // 1. Request Runtime Permissions
    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      debugPrint('🚨 Storage permissions denied by user.');
      return;
    }

    debugPrint('🔍 Starting local audio scan...');

    // 2. Query the native Android MediaStore
    final List<SongModel> songs = await _audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: null,
      uriType: UriType.EXTERNAL,
    );

    if (songs.isEmpty) {
      debugPrint('⚠️ No audio files found on device.');
      return;
    }

    debugPrint('💿 Found ${songs.length} audio files. Hydrating database...');

    // 3. Database Hydration (Strictly NO Classification Here)
    List<Map<String, dynamic>> insertionBatch = [];
    
for (var song in songs) {
      insertionBatch.add({
        'id': song.id.toString(),
        'title': song.title,
        'artist': song.artist ?? 'Unknown',
        'data_uri': song.data, 
        
        // 🎯 THE FINAL FIX: Insert true SQL null so getUnclassifiedSongs() catches it!
        'language_tag': null, 
        'confidence': 0.0,
      });

      // Batch insert every 50 songs
      if (insertionBatch.length >= 50) {
        await _db.insertSongsBatch(insertionBatch); 
        debugPrint('✅ Saved 50 unclassified tracks to database...');
        insertionBatch.clear();
      }
    }

    // Insert any remaining songs in the final partial batch
    if (insertionBatch.isNotEmpty) {
      await _db.insertSongsBatch(insertionBatch); 
    }

    debugPrint('🎉 File scan complete! Handing over to Multi-Tier AI Pipeline...');
    
    // 4. Hand off to the proper, multi-tiered background orchestrator
    await _languageService.runClassificationPass();
  }

  /// Handles Android 13+ (API 33) and Legacy Storage Permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ uses specific media permissions
      final audioStatus = await Permission.audio.status;
      if (audioStatus.isGranted) return true;

      // Legacy Android relies on general storage
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) return true;

      // Request both just in case
      final statuses = await [
        Permission.audio,
        Permission.storage,
      ].request();

      return statuses[Permission.audio]!.isGranted || statuses[Permission.storage]!.isGranted;
    }
    return false;
  }
}