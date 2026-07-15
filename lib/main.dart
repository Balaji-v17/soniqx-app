// ============================================================
//   SONIQ — lib/main.dart
//   Entry point | July 2026
//
//   Initialization order (strict — do not reorder):
//     1. Flutter engine binding
//     2. Soniq Classifier Initialization
//     3. Firebase
//     4. AppDatabase  ← db declared here, used everywhere below
//     5. OTA Seed Database Check
//     6. AudioService.init with SoniqAudioHandler(db)
//     7. ProviderScope overrides + runApp
// ============================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import 'firebase_options.dart';
import 'database/database.dart';
import 'audio/soniq_audio_handler.dart';
import 'providers.dart';
import 'ui/root_screen.dart';
import 'ui/screens/settings_screen.dart'; 
import 'package:soniq/classifier/ota_service.dart'; // 🎯 OTA Service imported

Future<void> main() async {
  // Step 1 — Flutter engine binding
  WidgetsFlutterBinding.ensureInitialized();

  // Step 2 — Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  // Step 3 — Database
  final db = AppDatabase();

  // Step 3.5 — FIRE AND FORGET: Trigger the OTA check in the background!
  OtaService.checkSeedDbUpdate(db);

  // Step 4 — Audio service
  final audioHandler = await AudioService.init(
    builder: () => SoniqAudioHandler(db),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.soniq.music.channel.audio',
      androidNotificationChannelName: 'SONIQ Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidShowNotificationBadge: false,
    ),
  );

  // Step 5 — Run app with provider overrides
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
       audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const SoniqApp(),
    ),
  );
}

// ─── App widget ───────────────────────────────────────────────

// 🎯 Changed to ConsumerWidget so it can actively listen to theme updates
class SoniqApp extends ConsumerWidget {
  const SoniqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 Actively watch the theme mode state provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SONIQ',
      debugShowCheckedModeBanner: false,
      // 💡 Setup a crisp Light Theme definition
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        cardColor: const Color(0xFFFFFFFF),
      ),
      // 💡 Keeping your standard Dark Theme setup
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        cardColor: const Color(0xFF1A1A1A),
      ),
      // 🎯 Bind themeMode dynamically to your state provider
      themeMode: themeMode,
      home: const RootScreen(),
    );
  }
}