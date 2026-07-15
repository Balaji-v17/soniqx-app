import 'dart:io';
import 'dart:convert';
import 'package:audiotags/audiotags.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class ArtworkExtractor {
  /// Reads the MP3 file, extracts the embedded cover art, caches it, and returns the URI.
  static Future<Uri?> getArtUriFromPath(String path) async {
    try {
      // 1. Read the ID3 tags directly from the physical file
      final tag = await AudioTags.read(path);
debugPrint('--- ARTWORK DEBUG ---');
debugPrint('File: $path');
debugPrint('Has Tags: ${tag != null}');
debugPrint('Picture Count: ${tag?.pictures.length ?? 0}');
      
      if (tag != null && tag.pictures.isNotEmpty) {
        final pictureBytes = tag.pictures.first.bytes;
        
        // 2. Hash the file path to create a unique, safe filename (e.g., d41d8cd98f.jpg)
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