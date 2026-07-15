// ============================================================
//  SONIQ — lib/providers.dart
//  Global Dependency Injection Hub
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/audio/soniq_audio_handler.dart';

/// Provides global access to the Drift AppDatabase.
/// 
/// This throws an UnimplementedError by default to enforce safe initialization.
/// It is explicitly overridden with a live instance in main.dart's ProviderScope
/// BEFORE the app renders, guaranteeing synchronous, null-safe access everywhere.
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('databaseProvider must be overridden in ProviderScope');
});

/// Provides global access to the SoniqAudioHandler.
/// 
/// Like the databaseProvider, this is overridden in main.dart.
/// Use this provider inside your UI widgets to call play(), pause(), skipToNext(),
/// or to listen to playback streams.
final audioHandlerProvider = Provider<SoniqAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider must be overridden in ProviderScope');
});