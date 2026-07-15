// ============================================================
//  SONIQ — lib/scanner/music_scanner.dart
//
//  Uses the native Pigeon AudioScannerApi for lightning-fast
//  MediaProvider querying. Handles SQLite indexing and 
//  background MD5 hashing for robust file-move detection.
// ============================================================

import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:soniq/src/pigeon/audio_scanner.g.dart';
import '../database/database.dart';
import '../classifier/language_service.dart'; // 🎯 We need this for the AI trigger!

// ─── Progress Model ───────────────────────────────────────────

enum ScanPhase {
  requestingPermission,
  fetchingMetadata,
  indexing,
  markingRemovals,
  computingHashes,
  complete,
  error,
}

class ScanProgress {
  final ScanPhase phase;
  final int processed;
  final int total;
  final String? currentTitle;
  final String? errorMessage;

  const ScanProgress({
    required this.phase,
    this.processed = 0,
    this.total = 0,
    this.currentTitle,
    this.errorMessage,
  });

  double get fraction => total > 0 ? processed / total : 0.0;
  bool get isComplete => phase == ScanPhase.complete;
  bool get isError    => phase == ScanPhase.error;

  @override
  String toString() =>
      'ScanProgress(${phase.name} $processed/$total "$currentTitle")';
}

enum ScanResult { success, permissionDenied, alreadyRunning, error }

// ─── MusicScanner ─────────────────────────────────────────────

class MusicScanner {
  final AudioScannerApi _api = AudioScannerApi();
  final AppDatabase _db;
  final _progressCtrl = StreamController<ScanProgress>.broadcast();

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  // Public stream — attach to this in your UI widget
  Stream<ScanProgress> get progress => _progressCtrl.stream;

  MusicScanner(this._db);

  // ─── Public API ─────────────────────────────────────────────

  /// Full scan + sync with the device library.
  Future<ScanResult> scanAndSync({bool computeHashes = false}) async {
    if (_isScanning) return ScanResult.alreadyRunning;
    _isScanning = true;

    try {
      // ── Phase 1: Permission ──────────────────────────────────
      _emit(ScanPhase.requestingPermission);
      final granted = await _requestPermission();
      if (!granted) return ScanResult.permissionDenied;

      // ── Phase 2: Fetch raw metadata from MediaStore ──────────
      _emit(ScanPhase.fetchingMetadata);
      final raw = await _api.querySongs();

      // Strip out the null list and any null items so Dart knows it is safe!
      final cleanRaw = raw?.whereType<RawSongData>().toList() ?? [];

      // Filter out files that might have slipped through with empty paths
      final songs = cleanRaw.where(_isValidMusic).toList();

      // ── Phase 3: Incremental indexing ────────────────────────
      final existingIds = await _loadExistingIds();
      final scannedIds  = <int>{};
      final companions  = <SongsCompanion>[];
      int processed = 0;

      for (final song in songs) {
        // GHOST FILE FILTER: Double check just in case!
        if (song.id == null || song.path == null) continue;

        processed++;

        // Yield to event loop every 50 songs to keep UI responsive
        if (processed % 50 == 0) {
          _emit(ScanPhase.indexing,
              processed: processed,
              total: songs.length,
              title: song.title);
          await Future.delayed(Duration.zero);
        }

        // We know id is not null because of the filter above, so we can use !
        scannedIds.add(song.id!); 
        companions.add(_mapToCompanion(song));
      }

      // Final progress tick for indexing phase
      _emit(ScanPhase.indexing, processed: songs.length, total: songs.length);

      // Batch upsert — Drift's own background isolate handles I/O
      await _db.songsDao.upsertSongs(companions);

      // ── Phase 4: Mark removed songs as unavailable ───────────
      _emit(ScanPhase.markingRemovals);
      final removedIds = existingIds
          .where((id) => !scannedIds.contains(id))
          .toList();
      if (removedIds.isNotEmpty) {
        await _db.songsDao.markUnavailable(removedIds);
      }

      // ── Phase 5 (optional): Background file hashing ──────────
      if (computeHashes) {
        _emit(ScanPhase.computingHashes);
        await _computeFileHashesInBackground(songs);
      }

      // 🎯 THE FIX: Run the AI Classification Sweep right before completion!
      await LanguageService(_db).runClassificationPass();

      _emit(ScanPhase.complete, processed: songs.length, total: songs.length);
      return ScanResult.success;

    } catch (e, stack) {
      debugPrint('MusicScanner error: $e\n$stack');
      _emitError(e.toString());
      return ScanResult.error;
    } finally {
      _isScanning = false;
    }
  }

  /// Lightweight incremental check — call this on app resume.
  Future<ScanResult> incrementalSync() async {
    return scanAndSync(computeHashes: false);
  }

  void dispose() {
    _progressCtrl.close();
  }

  // ─── Permission Handling ─────────────────────────────────────
  
  Future<bool> _requestPermission() async {
    if (!Platform.isAndroid) return true;

    final sdk = await _getAndroidSdk();

    if (sdk >= 33) {
      if (await Permission.audio.isGranted) return true;
      final result = await Permission.audio.request();
      return result.isGranted;
    } else {
      if (await Permission.storage.isGranted) return true;
      final result = await Permission.storage.request();
      return result.isGranted;
    }
  }

  Future<int> _getAndroidSdk() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    } catch (_) {
      return 33; 
    }
  }

  // ─── Music Validation Filter ─────────────────────────────────
  
  bool _isValidMusic(RawSongData song) {
    // Extract path and safely check for null
    final path = song.path;
    if (path == null || path.trim().isEmpty) return false;
    if (song.id == null) return false;
    
    // Must have a recognised audio extension
    const validExtensions = {
      '.mp3', '.flac', '.m4a', '.aac', '.ogg', '.opus',
      '.wav', '.wma', '.ape', '.aiff', '.alac',
    };
    final ext = path.contains('.')
        ? '.${path.split('.').last.toLowerCase()}'
        : '';
    if (!validExtensions.contains(ext)) return false;

  return true;
}

  // ─── Column Mapping ──────────────────────────────────────────
  
  SongsCompanion _mapToCompanion(RawSongData song) {
    // Safely handles title in case Pigeon generated it as nullable
    final String? rawTitle = song.title;
    final String? safeTitle = (rawTitle != null && rawTitle.trim().isNotEmpty) ? rawTitle.trim() : null;

    final String pathForEngine = song.path ?? '';
    
    return SongsCompanion(
      id:          Value(song.id ?? 0),
      title:       Value(safeTitle),
      artist:      Value(_cleanString(song.artist)),
      album:       Value(_cleanString(song.album)),
      albumArtist: Value(_cleanString(song.albumArtist)),
      trackNumber: Value(song.trackNumber == 0 ? null : song.trackNumber),
      discNumber:  Value(song.discNumber == 0 ? null : song.discNumber),
      year:        Value(song.year == 0 ? null : song.year),
      genre:       Value(_cleanString(song.genre)),
      durationMs:  Value(song.durationMs ?? 0),
      path:        Value(pathForEngine),
      albumId:     Value(song.albumId ?? 0),
      dateAdded:   Value(song.dateAdded ?? 0),
      fileHash:    const Value(null),
      isAvailable: const Value(true),
      
      // 🎯 THE FIX: These must default to null/0 so the AI engine catches them post-insert!
      languageTag:          const Value(null), 
      classifierConfidence: const Value(0.0),  
      wasManuallyTagged:    const Value(false),
      
      dateScanned: Value(DateTime.now().millisecondsSinceEpoch),
    );
  }

  String? _cleanString(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    const unknowns = {'<unknown>', 'unknown', 'unknown artist', 'unknown album'};
    if (unknowns.contains(trimmed.toLowerCase())) return null;
    return trimmed;
  }

  // ─── Incremental Support ─────────────────────────────────────

  Future<Set<int>> _loadExistingIds() async {
    final songs = await _db.songsDao.watchAllAvailable().first;
    return songs.map((s) => s.id).toSet();
  }

  // ─── Background File Hashing (Phase 5) ───────────────────────
  
  Future<void> _computeFileHashesInBackground(List<RawSongData> songs) async {
    int processed = 0;
    final total = songs.length;

    for (final song in songs) {
      if (song.id == null || song.path == null) continue; // Safety net

      processed++;

      if (processed % 20 == 0) {
        _emit(ScanPhase.computingHashes,
            processed: processed, total: total, title: song.title);
      }

      try {
        final hash = await compute(_computeMd5, song.path!);
        if (hash != null) {
          await _db.customUpdate(
            'UPDATE songs SET file_hash = ? WHERE id = ?',
            variables: [Variable<String>(hash), Variable<int>(song.id!)],
            updates: {_db.songs},
          );
        }
      } catch (_) {}

      if (processed % 50 == 0) {
        await Future.delayed(Duration.zero);
      }
    }
  }

  // ─── Progress Helpers ────────────────────────────────────────

  void _emit(
    ScanPhase phase, {
    int processed = 0,
    int total = 0,
    String? title,
  }) {
    if (_progressCtrl.isClosed) return;
    _progressCtrl.add(ScanProgress(
      phase: phase,
      processed: processed,
      total: total,
      currentTitle: title,
    ));
  }

  void _emitError(String message) {
    if (_progressCtrl.isClosed) return;
    _progressCtrl.add(ScanProgress(
      phase: ScanPhase.error,
      errorMessage: message,
    ));
  }
} // 🎯 This correctly closes the MusicScanner class now!

// ─── Isolate-safe MD5 helper ─────────────────────────────────
Future<String?> _computeMd5(String path) async {
  try {
    final file = File(path);
    if (!file.existsSync()) return null;

    final sink   = AccumulatorSink<Digest>();
    final output = md5.startChunkedConversion(sink);

    const chunkSize  = 65536;    
    const maxBytes   = 524288;   
    int   totalRead  = 0;
    bool  done       = false;

    final raf = await file.open();
    try {
      while (!done && totalRead < maxBytes) {
        final toRead = chunkSize.clamp(0, maxBytes - totalRead);
        final chunk  = await raf.read(toRead);
        if (chunk.isEmpty) break;
        output.add(chunk);
        totalRead += chunk.length;
        if (chunk.length < toRead) done = true;
      }
    } finally {
      await raf.close();
    }

    output.close();
    return sink.events.single.toString();
  } catch (_) {
    return null;
  }
}