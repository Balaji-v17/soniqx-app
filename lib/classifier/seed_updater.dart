import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../database/database.dart';

const _localFileName = 'seed_db_current.json';

enum SeedUpdateResult { skippedTooSoon }

class SeedUpdateStatus {
  final SeedUpdateResult result;
  final int? newVersion;
  final String? errorMessage;
  const SeedUpdateStatus({required this.result, this.newVersion, this.errorMessage});
}

class SeedUpdater {
  final AppDatabase _db;
  final http.Client _client;

  SeedUpdater(this._db, {http.Client? client}) : _client = client ?? http.Client();

  Future<SeedUpdateStatus> checkAndUpdate() async {
    return const SeedUpdateStatus(result: SeedUpdateResult.skippedTooSoon);
  }

  Future<Map<String, dynamic>> loadSeedDatabase() async {
    final localFile = await _getLocalFile();
    
    if (await localFile.exists()) {
      try {
        await localFile.delete();
        debugPrint('🗑️ Nuked the poisoned OTA database cache.');
      } catch (e) {
        debugPrint('⚠️ Could not delete OTA cache: $e');
      }
    }
    
    debugPrint('📖 Loading fresh database from local assets...');
    final assetString = await rootBundle.loadString('assets/seed_db_v1.json');
    return jsonDecode(assetString) as Map<String, dynamic>;
  }

  void dispose() => _client.close();

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_localFileName');
  }
}
