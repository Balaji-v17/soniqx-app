// ============================================================
//  SONIQ — lib/audio/music_scanner.dart
// ============================================================

import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:soniq/src/pigeon/audio_scanner.g.dart';
import '../database/database.dart';
import '../classifier/language_service.dart';
import '../utils/audio_header_reader.dart';

enum ScanPhase { requestingPermission, fetchingMetadata, indexing, markingRemovals, complete, error }

class ScanProgress {
  final ScanPhase phase;
  final int processed;
  final int total;
  final String? currentTitle;
  final String? errorMessage;

  const ScanProgress({required this.phase, this.processed = 0, this.total = 0, this.currentTitle, this.errorMessage});
  double get fraction => total > 0 ? processed / total : 0.0;
  bool get isComplete => phase == ScanPhase.complete;
  bool get isError    => phase == ScanPhase.error;
}

enum ScanResult { success, permissionDenied, alreadyRunning, error }

class MusicScanner {
  final AudioScannerApi _api = AudioScannerApi();
  final AppDatabase _db;
  final _progressCtrl = StreamController<ScanProgress>.broadcast();

  bool _isScanning = false;
  bool get isScanning => _isScanning;
  Stream<ScanProgress> get progress => _progressCtrl.stream;

  MusicScanner(this._db);

  Future<ScanResult> scanAndSync({bool computeHashes = false}) async {
    if (_isScanning) return ScanResult.alreadyRunning;
    _isScanning = true;

    try {
      _emit(ScanPhase.requestingPermission);
      final granted = await _requestPermission();
      if (!granted) return ScanResult.permissionDenied;

      _emit(ScanPhase.fetchingMetadata);
      final raw = await _api.querySongs();
      final cleanRaw = raw?.whereType<RawSongData>().toList() ?? [];
      final incomingBatch = cleanRaw.where(_isValidMusic).toList();

      final existingSongsList = await _db.select(_db.songs).get();
      
      final byFingerprint = <String, Song>{};
      final byCanonicalPath = <String, Song>{};
      final byMediaId = <int, Song>{};

      for (final song in existingSongsList) {
        byFingerprint[_generateFingerprint(song.size, song.title ?? '')] = song;
        byCanonicalPath[song.canonicalPath] = song;
        byMediaId[song.id] = song;
      }

      final scanBaseTime = DateTime.now().microsecondsSinceEpoch;
      int sequenceOffset = 0;
      
      final scannedIds  = <int>{};
      final upsertBatch  = <SongsCompanion>[];
      int processed = 0;

      for (final incoming in incomingBatch) {
        if (incoming.id == null || incoming.path == null) continue;

        processed++;
        if (processed % 10 == 0) {
          _emit(ScanPhase.indexing, processed: processed, total: incomingBatch.length, title: incoming.title);
          await Future.delayed(const Duration(milliseconds: 5));
        }

        final canonicalPath = _canonicalizePath(incoming.path!);
        
        int fileSize = 0;
        try {
          fileSize = File(incoming.path!).lengthSync();
        } catch (_) {}

        final fingerprint = _generateFingerprint(fileSize, incoming.title ?? '');

        final existing = byFingerprint[fingerprint] ?? 
                         byCanonicalPath[canonicalPath] ?? 
                         byMediaId[incoming.id];

        final int incomingDuration = incoming.durationMs ?? 0;
        int mergedDuration = (incomingDuration > 0) 
            ? incomingDuration 
            : (existing != null && existing.durationMs != null && existing.durationMs! > 0) 
                ? existing.durationMs! 
                : 0;

        // Instant Dart header fallback during scan
        if (mergedDuration <= 0 && incoming.path!.isNotEmpty) {
          try {
            final parsedMs = await AudioHeaderReader.getDurationMs(incoming.path!);
            if (parsedMs != null && parsedMs > 0) {
              mergedDuration = parsedMs;
            }
          } catch (_) {}
        }

        final int mergedFirstSeen = (existing != null && existing.firstSeen > 0) 
            ? existing.firstSeen 
            : (scanBaseTime + sequenceOffset++);

        scannedIds.add(incoming.id!);

        final safeTitle = (incoming.title?.trim().isNotEmpty == true) ? incoming.title!.trim() : 'Unknown Track';
        final safeArtist = _cleanString(incoming.artist) ?? 'Unknown Artist';

        upsertBatch.add(
          SongsCompanion.insert(
            id: Value(incoming.id!),
            path: incoming.path!,
            canonicalPath: Value(canonicalPath),
            title: Value(safeTitle),
            artist: Value(safeArtist),
            album: Value(_cleanString(incoming.album) ?? 'Unknown Album'),
            size: Value(fileSize),
            durationMs: Value(mergedDuration),
            dateAdded: Value(incoming.dateAdded), 
            firstSeen: Value(mergedFirstSeen), 
            
            // 🎯 THE FIX: Pass the nanosecond Linux Kernel timestamp into SQLite
            ctimeNs: Value(incoming.ctimeNs), 
            
            languageTag: Value(existing?.languageTag),
            classifierConfidence: Value(existing?.classifierConfidence ?? 0.0),
            wasManuallyTagged: Value(existing?.wasManuallyTagged ?? false),
            dateScanned: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        );
      }

      _emit(ScanPhase.indexing, processed: incomingBatch.length, total: incomingBatch.length);
      
      await _db.batch((batch) {
        batch.insertAll(_db.songs, upsertBatch, mode: InsertMode.insertOrReplace);
      });

      _emit(ScanPhase.markingRemovals);
      final removedIds = existingSongsList.map((s) => s.id).where((id) => !scannedIds.contains(id)).toList();
      if (removedIds.isNotEmpty) {
        await _db.songsDao.markUnavailable(removedIds);
      }

      await LanguageService(_db).runClassificationPass();

      _emit(ScanPhase.complete, processed: incomingBatch.length, total: incomingBatch.length);
      return ScanResult.success;

    } catch (e) {
      _emitError(e.toString());
      return ScanResult.error;
    } finally {
      _isScanning = false;
    }
  }

  Future<ScanResult> incrementalSync() async => scanAndSync(computeHashes: false);
  void dispose() => _progressCtrl.close();

  String _canonicalizePath(String rawPath) {
    return rawPath.replaceAll(RegExp(r'^/sdcard/'), '/storage/emulated/0/').toLowerCase();
  }

  String _generateFingerprint(int size, String title) {
    return '${size}_${title.toLowerCase()}';
  }

  String? _cleanString(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    if ({'<unknown>', 'unknown', 'unknown artist', 'unknown album'}.contains(trimmed.toLowerCase())) return null;
    return trimmed;
  }

  bool _isValidMusic(RawSongData song) {
    final path = song.path;
    if (path == null || path.trim().isEmpty || song.id == null) return false;
    const validExtensions = {'.mp3', '.flac', '.m4a', '.aac', '.ogg', '.opus', '.wav', '.wma'};
    final ext = path.contains('.') ? '.${path.split('.').last.toLowerCase()}' : '';
    return validExtensions.contains(ext);
  }

  Future<bool> _requestPermission() async {
    if (!Platform.isAndroid) return true;
    final sdk = await _getAndroidSdk();
    if (sdk >= 33) {
      if (await Permission.audio.isGranted) return true;
      return (await Permission.audio.request()).isGranted;
    } else {
      if (await Permission.storage.isGranted) return true;
      return (await Permission.storage.request()).isGranted;
    }
  }

  Future<int> _getAndroidSdk() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      return info.version.sdkInt;
    } catch (_) { return 33; }
  }

  void _emit(ScanPhase phase, {int processed = 0, int total = 0, String? title}) {
    if (!_progressCtrl.isClosed) _progressCtrl.add(ScanProgress(phase: phase, processed: processed, total: total, currentTitle: title));
  }

  void _emitError(String message) {
    if (!_progressCtrl.isClosed) _progressCtrl.add(ScanProgress(phase: ScanPhase.error, errorMessage: message));
  }
}