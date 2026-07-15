// ============================================================
//  SONIQ — lib/classifier/seed_updater.dart
//  OTA Seed Database Updater
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database.dart';

const _manifestUrl = 'https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/soniq-data/main/manifest.json';
const _checkIntervalMs = 7 * 24 * 60 * 60 * 1000; 
const _localFileName = 'seed_db_current.json';
const _settingVersion = 'seed_db_version';
const _settingLastCheck = 'last_seed_check_ms';

enum SeedUpdateResult {
  updated, alreadyCurrent, skippedNoWifi, skippedTooSoon, failedNetwork, failedValidation, failedWrite
}

class SeedUpdateStatus {
  final SeedUpdateResult result;
  final int? newVersion;
  final String? errorMessage;
  const SeedUpdateStatus({required this.result, this.newVersion, this.errorMessage});
  bool get wasUpdated => result == SeedUpdateResult.updated;
  @override
  String toString() => 'SeedUpdateStatus(${result.name})';
}

class SeedUpdater {
  final AppDatabase _db;
  final http.Client _client;

  SeedUpdater(this._db, {http.Client? client}) : _client = client ?? http.Client();

  Future<SeedUpdateStatus> checkAndUpdate() async {
    try {
      final lastCheckStr = await _db.settingsDao.getSetting(_settingLastCheck);
      final lastCheckMs = int.tryParse(lastCheckStr ?? '0') ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      if (nowMs - lastCheckMs < _checkIntervalMs) {
        return const SeedUpdateStatus(result: SeedUpdateResult.skippedTooSoon);
      }

      final isWifi = await _isOnWifi();
      if (!isWifi) return const SeedUpdateStatus(result: SeedUpdateResult.skippedNoWifi);

      final manifest = await _fetchManifest();
      if (manifest == null) return const SeedUpdateStatus(result: SeedUpdateResult.failedNetwork);

      final remoteVersion = manifest['version'] as int;
      final localVersionStr = await _db.settingsDao.getSetting(_settingVersion);
      final localVersion = int.tryParse(localVersionStr ?? '1') ?? 1;

      await _db.settingsDao.setSetting(_settingLastCheck, nowMs.toString());

      if (remoteVersion <= localVersion) {
        return const SeedUpdateStatus(result: SeedUpdateResult.alreadyCurrent);
      }

      final downloadUrl = manifest['url'] as String;
      final rawBytes = await _downloadFile(downloadUrl);
      if (rawBytes == null) return const SeedUpdateStatus(result: SeedUpdateResult.failedNetwork);

      final expectedChecksum = manifest['checksum_sha256'] as String?;
      if (expectedChecksum != null && expectedChecksum.isNotEmpty) {
        final actualChecksum = sha256.convert(rawBytes).toString();
        if (actualChecksum != expectedChecksum) {
          return const SeedUpdateStatus(result: SeedUpdateResult.failedValidation);
        }
      }

      final written = await _writeToLocal(rawBytes);
      if (!written) return const SeedUpdateStatus(result: SeedUpdateResult.failedWrite);

      await _db.settingsDao.setSetting(_settingVersion, remoteVersion.toString());
      return SeedUpdateStatus(result: SeedUpdateResult.updated, newVersion: remoteVersion);

    } catch (e) {
      return SeedUpdateStatus(result: SeedUpdateResult.failedNetwork, errorMessage: e.toString());
    }
  }

  Future<Map<String, dynamic>> loadSeedDatabase() async {
    final localFile = await _getLocalFile();
    if (await localFile.exists()) {
      try {
        final content = await localFile.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      } catch (e) {
        await localFile.delete();
      }
    }
    final assetString = await rootBundle.loadString('assets/seed_db_v1.json');
    return jsonDecode(assetString) as Map<String, dynamic>;
  }

  void dispose() => _client.close();

  Future<bool> _isOnWifi() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.contains(ConnectivityResult.wifi);
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> _fetchManifest() async {
    try {
      final response = await _client.get(Uri.parse(_manifestUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}
    return null;
  }

  Future<Uint8List?> _downloadFile(String url) async {
    try {
      final response = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) return response.bodyBytes;
    } catch (_) {}
    return null;
  }

  Future<bool> _writeToLocal(Uint8List bytes) async {
    try {
      final file = await _getLocalFile();
      await file.writeAsBytes(bytes, flush: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_localFileName');
  }
}