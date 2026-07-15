// ============================================================
//  SONIQ — lib/ui/sheets/sleep_timer_sheet.dart
//  Sleep Timer configuration UI.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/audio/sleep_timer_service.dart';

class SleepTimerSheet extends ConsumerWidget {
  const SleepTimerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeRemaining = ref.watch(sleepTimerProvider);
    final isTimerActive = timeRemaining != null;

    return Container(
      height: 380,
      decoration: const BoxDecoration(
        color: Color(0xFF13141F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sleep Timer',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (isTimerActive)
                Text(
                  _formatDuration(timeRemaining),
                  style: const TextStyle(color: Color(0xFF6366F1), fontSize: 20, fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Automatically pause playback after a set amount of time.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTimerTile(context, ref, '15 Minutes', const Duration(minutes: 15)),
                _buildTimerTile(context, ref, '30 Minutes', const Duration(minutes: 30)),
                _buildTimerTile(context, ref, '45 Minutes', const Duration(minutes: 45)),
                _buildTimerTile(context, ref, '60 Minutes', const Duration(minutes: 60)),
              ],
            ),
          ),

          if (isTimerActive)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => ref.read(sleepTimerProvider.notifier).cancelTimer(),
                  child: const Text('Cancel Timer', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimerTile(BuildContext context, WidgetRef ref, String title, Duration duration) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: () {
        ref.read(sleepTimerProvider.notifier).startTimer(duration);
        Navigator.pop(context);
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}