// ============================================================
//  SONIQ — lib/classifier/ota_service.dart
//  Over-The-Air (OTA) update manager for the AI Seed Database.
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:soniq/database/database.dart';

class OtaService {
  // 🎯 Replace these with your actual GitHub raw URLs later!
  static const String manifestUrl = 'https://raw.githubusercontent.com/yourusername/soniq-data/main/manifest.json';
  static const String dbBaseUrl = 'https://raw.githubusercontent.com/yourusername/soniq-data/main/';

  /// Checks for a new Seed Database version and downloads it if available.
  static Future<void> checkSeedDbUpdate(AppDatabase db) async {
    try {
      // 1. Check if 7 days have passed since the last check
      final lastCheckStr = await db.settingsDao.getSetting('last_seed_check');
      final lastCheck = lastCheckStr != null ? int.tryParse(lastCheckStr) ?? 0 : 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now - lastCheck < 7 * 24 * 60 * 60 * 1000) {
        print('📡 OTA: Checked recently. Skipping update.');
        return; 
      }

      // 2. Fetch the manifest from GitHub
      final manifestRes = await http.get(Uri.parse(manifestUrl));
      if (manifestRes.statusCode != 200) return;

      final manifest = jsonDecode(manifestRes.body);
      final remoteVersion = manifest['version'] as int;
      final remoteFileName = manifest['url'] as String;

      // 3. Get local version
      final localVersionStr = await db.settingsDao.getSetting('seed_db_version');
      final localVersion = localVersionStr != null ? int.tryParse(localVersionStr) ?? 1 : 1;

      // 4. Download if the remote version is higher
      if (remoteVersion > localVersion) {
        print('📡 OTA: New database found! Version $remoteVersion. Downloading...');
        
        final dbRes = await http.get(Uri.parse('$dbBaseUrl$remoteFileName'));
        if (dbRes.statusCode == 200) {
          // Save to App Documents directory
          final docsDir = await getApplicationDocumentsDirectory();
          final file = File('${docsDir.path}/seed_db_ota.json');
          
          await file.writeAsString(dbRes.body);
          
          // Update Settings
          await db.settingsDao.setSetting('seed_db_version', remoteVersion.toString());
          print('✅ OTA: Successfully updated to Version $remoteVersion.');
        }
      } else {
        print('📡 OTA: Database is up to date (Version $localVersion).');
      }

      // Record the time of this check so we don't spam GitHub
      await db.settingsDao.setSetting('last_seed_check', now.toString());

    } catch (e) {
      print('🚨 OTA Failed: $e');
    }
  }
}