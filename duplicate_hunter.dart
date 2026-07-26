import 'dart:io';
import 'package:crypto/crypto.dart';

void main() async {
  // 🎯 UPDATE THIS: Put the path to the directory you want to scan here.
  // Use '.' to scan the current directory.
  final targetDirectory = Directory('.'); 

  if (!targetDirectory.existsSync()) {
    print('🚨 Directory does not exist: ${targetDirectory.path}');
    return;
  }

  print('🔍 Scanning for duplicate files recursively...');
  
  // This map keeps track of the file hashes we have already seen.
  // Format: { 'hash_string': 'path/to/original/file' }
  final seenHashes = <String, String>{};
  
  int deletedCount = 0;
  int savedBytes = 0;

  // Walk through the directory and all of its subdirectories
  await for (final entity in targetDirectory.list(recursive: true, followLinks: false)) {
    if (entity is File) {
      try {
        final hash = await _calculateFileHash(entity);

        if (seenHashes.containsKey(hash)) {
          final original = seenHashes[hash];
          final size = await entity.length();
          
          print('🗑️ Deleting duplicate: ${entity.path}');
          print('   (Duplicate of: $original)');
          
          // Delete the duplicate file
          await entity.delete();
          deletedCount++;
          savedBytes += size;
        } else {
          // Record this unique file's hash and path so we can check future files against it
          seenHashes[hash] = entity.path;
        }
      } catch (e) {
        print('⚠️ Could not process file ${entity.path}: $e');
      }
    }
  }

  // Calculate the megabytes saved
  final savedMb = (savedBytes / (1024 * 1024)).toStringAsFixed(2);
  print('✅ Done! Deleted $deletedCount duplicate files, freeing up $savedMb MB.');
}

/// Helper function to generate a SHA-256 hash from a file stream.
/// Using a stream prevents loading massive files entirely into RAM.
Future<String> _calculateFileHash(File file) async {
  final stream = file.openRead();
  final digest = await sha256.bind(stream).single;
  return digest.toString();
}