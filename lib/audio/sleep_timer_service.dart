// ============================================================
//  SONIQ — lib/audio/sleep_timer_service.dart
//  Background sleep timer logic.
// ============================================================

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart';

final sleepTimerProvider = StateNotifierProvider<SleepTimerService, Duration?>((ref) {
  return SleepTimerService(ref);
});

class SleepTimerService extends StateNotifier<Duration?> {
  final Ref _ref;
  Timer? _timer;

  SleepTimerService(this._ref) : super(null);

  void startTimer(Duration duration) {
    _timer?.cancel();
    state = duration;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }

      final remaining = state! - const Duration(seconds: 1);
      
      if (remaining.inSeconds <= 0) {
        _stopPlayback();
        cancelTimer();
      } else {
        state = remaining;
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    state = null;
  }

  Future<void> _stopPlayback() async {
    final handler = _ref.read(audioHandlerProvider);
    await handler.pause();
  }
}