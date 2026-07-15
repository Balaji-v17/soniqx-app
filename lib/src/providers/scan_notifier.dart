import '../../providers.dart'; // <-- Add this!
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soniq/src/pigeon/audio_scanner.g.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/src/database/sync_worker.dart';

// ─── State Class ─────────────────────────────────────────────
class ScanState {
  final bool isScanning;
  final int songsFound;
  final String? error;

  ScanState({
    this.isScanning = false, 
    this.songsFound = 0, 
    this.error
  });
}

// ─── The Notifier ────────────────────────────────────────────
class ScanNotifier extends StateNotifier<ScanState> {
  final AppDatabase db;
  final AudioScannerApi _api = AudioScannerApi();

  ScanNotifier(this.db) : super(ScanState());

  Future<void> startFullScan() async {
    if (state.isScanning) return;
    
    // 1. Check and request permissions first!
    PermissionStatus audioStatus = await Permission.audio.request();
    
    // Fallback for Android 12 and below
    if (audioStatus.isPermanentlyDenied || audioStatus.isDenied) {
      PermissionStatus storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        state = ScanState(isScanning: false, error: 'Storage permission is required to find music.');
        return;
      }
    }

    // 2. Start the scan UI
    state = ScanState(isScanning: true, songsFound: 0);

    try {
      // 3. Fetch from Kotlin
      final rawSongs = await _api.querySongs();
      final cleanSongs = rawSongs?.whereType<RawSongData>().toList() ?? [];
      
      // 4. Insert into Drift
      await SyncWorker.syncSongsToDatabase(db, cleanSongs);

      // 5. Verify and update UI
      final count = await db.select(db.songs).get().then((list) => list.length);
      state = ScanState(isScanning: false, songsFound: count);
      
    } catch (e, stack) {
      // 1. Grab the exact line of code where the crash originated
      final exactCrashLocation = stack.toString().split('\n').first;
      
      // 2. Print it using standard Dart print
      print('🚨 SONIQ CRASH: $e');
      print('🚨 LOCATION: $exactCrashLocation');
      
      // 3. Force it onto the phone screen
      state = ScanState(
        isScanning: false, 
        error: 'Bug hiding at: $exactCrashLocation',
      ); // 🎯 THE FIX: This correctly closes the ScanState object!
    }
  }
}

// ─── Global Providers ────────────────────────────────────────
final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  final db = ref.watch(databaseProvider); // This now reads from providers.dart!
  return ScanNotifier(db);
});