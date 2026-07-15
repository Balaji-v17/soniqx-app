// ============================================================
//  SONIQ — lib/ui/sheets/playback_speed_sheet.dart
//  Playback Speed & Pitch Control UI.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/audio/audio_effects_service.dart';
import 'package:soniq/providers.dart';

class PlaybackSpeedSheet extends ConsumerStatefulWidget {
  const PlaybackSpeedSheet({super.key});

  @override
  ConsumerState<PlaybackSpeedSheet> createState() => _PlaybackSpeedSheetState();
}

class _PlaybackSpeedSheetState extends ConsumerState<PlaybackSpeedSheet> {
  double _currentSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentSpeed();
  }

  void _loadCurrentSpeed() {
    final handler = ref.read(audioHandlerProvider);
    setState(() {
      _currentSpeed = handler.player.speed;
    });
  }

  Future<void> _setSpeed(double newSpeed) async {
    setState(() => _currentSpeed = newSpeed);
    await ref.read(audioEffectsProvider).setPlaybackSpeed(newSpeed);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
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
                'Playback Speed',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_currentSpeed.toStringAsFixed(1)}x',
                style: const TextStyle(color: Color(0xFF6366F1), fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Adjusts tempo with automatic pitch correction.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 32),
          
          // 🎯 The Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              activeTrackColor: const Color(0xFF6366F1),
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
              valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            child: Slider(
              value: _currentSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 15, // Allows 0.1 increments
              label: '${_currentSpeed.toStringAsFixed(1)}x',
              onChanged: _setSpeed,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 🎯 Quick Select Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedChip(0.5),
              _buildSpeedChip(1.0),
              _buildSpeedChip(1.2),
              _buildSpeedChip(1.5),
              _buildSpeedChip(2.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedChip(double speed) {
    final isSelected = _currentSpeed == speed;
    return GestureDetector(
      onTap: () => _setSpeed(speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF818CF8) : Colors.white10),
        ),
        child: Text(
          '${speed}x',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}