// ============================================================
//  SONIQ — pigeons/audio_scanner.dart
//  Pigeon 27.x schema | June 2026
//
//  SOURCE ONLY — never edit the generated files directly.
//  After any change here, regenerate by running:
//
//    dart run pigeon \
//      --input pigeons/audio_scanner.dart \
//      --dart_out lib/src/pigeon/audio_scanner.g.dart \
//      --kotlin_out android/app/src/main/kotlin/com/example/soniq/AudioScannerApi.kt \
//      --kotlin_package com.example.soniq
//
// ============================================================
 
import 'package:pigeon/pigeon.dart';

// ─── Data Class ──────────────────────────────────────────────
class RawSongData {
  int? id;
  String? path;
  int? albumId;
  int? dateAdded;
  String? title;
  String? artist;
  String? album;
  String? albumArtist;
  String? genre;
  int? durationMs;
  int? trackNumber;
  int? discNumber;
  int? year;
}
// ─── Host API ────────────────────────────────────────────────
@HostApi()
abstract class AudioScannerApi {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  List<RawSongData?>? querySongs(); // Added ? marks here

  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  List<RawSongData?>? querySongsSince(int timestamp); // Added ? marks here

  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  Uint8List? queryAlbumArt(int albumId, int songId);
}