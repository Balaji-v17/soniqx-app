import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class SongDeletionService {
  static const MethodChannel _channel = MethodChannel('com.soniq.music/deletion');

  /// Permanently deletes a song from device storage.
  /// On Android 11+ (API 30+), this forces a system confirmation dialog.
  static Future<bool> permanentDelete(int songId) async {
    try {
      final bool? success = await _channel.invokeMethod('permanentDelete', {
        'songId': songId,
      });
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('Permanent delete error: ${e.message}');
      return false;
    }
  }

  /// Permanently deletes multiple songs with a single Android 11+ system dialog.
  static Future<bool> permanentDeleteBatch(List<int> songIds) async {
    try {
      final bool? success = await _channel.invokeMethod('permanentDeleteBatch', {
        'songIds': songIds,
      });
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('Batch delete error: ${e.message}');
      return false;
    }
  }

  /// Moves a song to Android system trash (Android 12+ / API 31+).
  /// Returns `false` on older devices so you can fall back to normal delete.
  static Future<bool> moveToTrash(int songId) async {
    try {
      final bool? success = await _channel.invokeMethod('moveToTrash', {
        'songId': songId,
      });
      return success ?? false;
    } on PlatformException catch (e) {
      debugPrint('Move to trash error: ${e.message}');
      return false;
    }
  }
}