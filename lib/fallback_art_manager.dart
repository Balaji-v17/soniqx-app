import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class FallbackArtManager {
  static File? _fallbackImageFile;

  /// Extract the asset image into local storage on startup
  static Future<void> initialize() async {
    try {
      // 1. Read the image from assets
      final byteData = await rootBundle.load('assets/images/fallback_art.png');
      
      // 2. Get the device's temporary folder path
      final tempDir = await getTemporaryDirectory();
      
      // 3. Create the physical file
      _fallbackImageFile = File('${tempDir.path}/notification_fallback.png');
      
      // 4. Write the binary image data to the file
      await _fallbackImageFile!.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes, 
          byteData.lengthInBytes,
        ),
      );
    } catch (e) {
      print("Error extracting fallback art: $e");
    }
  }

  /// Returns the Uri (file://...) that Android notification needs
  static Uri? get uri => _fallbackImageFile?.uri;
}