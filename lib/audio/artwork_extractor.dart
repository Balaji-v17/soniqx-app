import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_media_metadata_plus/flutter_media_metadata_plus.dart';

class ArtworkExtractor {
  /// Reads the MP3 file, extracts the embedded cover art using OS-native 
  /// 16KB-compliant tools, caches it, and returns the URI.
  static Future<Uri?> getArtUriFromPath(String path) async {
    try {
      // 1. Read metadata using Android's native MediaMetadataRetriever (Safe from 16KB errors)
      final metadata = await MetadataRetriever.fromFile(File(path));
      final pictureBytes = metadata.albumArt;
      
      if (pictureBytes != null && pictureBytes.isNotEmpty) {
        // 2. Hash the file path to create a unique, safe filename
        final hash = md5.convert(utf8.encode(path)).toString();
        final tempDir = await getTemporaryDirectory();
        final artFile = File('${tempDir.path}/$hash.jpg');

        // 3. Write the image to the device cache ONLY if we haven't already saved it
        if (!await artFile.exists()) {
          await artFile.writeAsBytes(pictureBytes);
        }
        
        // 4. Return the local file URI so our UI can render it instantly
        return artFile.uri;
      }
    } catch (e) {
      debugPrint('Could not extract artwork for $path: $e');
      return null;
    }
    return null;
  }
}