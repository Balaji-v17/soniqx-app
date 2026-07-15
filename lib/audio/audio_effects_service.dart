// ============================================================
//  SONIQ — lib/audio/audio_effects_service.dart
//  Hardware DSP, Equalizer, and Pitch/Speed Controllers.
// ============================================================

import 'dart:async'; // 🎯 Added for TimeoutException
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart'; 
import 'package:soniq/audio/soniq_audio_handler.dart';

final audioEffectsProvider = Provider<AudioEffectsService>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return AudioEffectsService(handler as SoniqAudioHandler); 
});

class AudioEffectsService {
  final SoniqAudioHandler _handler;
  final bool _isHardwareSupported = true; // Assumed true if pipeline mounts

  AudioEffectsService(this._handler);

  bool get isHardwareSupported => _isHardwareSupported;

  Future<void> setPlaybackSpeed(double speed) async {
    final clampedSpeed = speed.clamp(0.5, 2.0);
    await _handler.player.setSpeed(clampedSpeed);
  }

  Future<void> setEqualizerEnabled(bool enabled) async {
    await _handler.equalizer.setEnabled(enabled);
  }
  
  Future<AndroidEqualizerParameters?> getEqualizerParams() async {
    try {
      // 🎯 FIXED: Android DSP hangs if no song is playing. Enforce a 1s timeout!
      return await _handler.equalizer.parameters.timeout(const Duration(seconds: 1));
    } on TimeoutException {
      print('⚠️ EQ Parameters timed out. A song must be playing first.');
      return null;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> setBandGain(int bandIndex, double gain) async {
    try {
      final parameters = await _handler.equalizer.parameters.timeout(const Duration(seconds: 1));
      final bands = parameters.bands;
      if (bandIndex >= 0 && bandIndex < bands.length) {
        await bands[bandIndex].setGain(gain);
      }
    } catch (e) {
      print('⚠️ Cannot set gain: $e');
    }
  }
}