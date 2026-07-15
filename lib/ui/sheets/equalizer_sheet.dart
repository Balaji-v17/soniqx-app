// ============================================================
//  SONIQ — lib/ui/sheets/equalizer_sheet.dart
//  Hardware DSP Routing & 10-Band EQ UI.
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:soniq/providers.dart';

class EqualizerSheet extends ConsumerStatefulWidget {
  const EqualizerSheet({super.key});

  @override
  ConsumerState<EqualizerSheet> createState() => _EqualizerSheetState();
}

class _EqualizerSheetState extends ConsumerState<EqualizerSheet> {
  // Local state for the UI sliders. 
  final List<double> _bandLevels = List.filled(10, 0.0);
  final List<String> _bandLabels = ['31', '62', '125', '250', '500', '1K', '2K', '4K', '8K', '16K'];
  bool _eqEnabled = false;

  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.watch(audioHandlerProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              color: const Color(0xFF13141F).withOpacity(0.85),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24.0),
                children: [
                  // ─── Header Drag Handle ───
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // ─── Title & Switch ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Graphic Equalizer',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Switch(
                        value: _eqEnabled,
                        activeColor: const Color(0xFFEAB308),
                        activeTrackColor: const Color(0xFFEAB308).withOpacity(0.3),
                        inactiveThumbColor: Colors.white54,
                        inactiveTrackColor: Colors.white10,
                        onChanged: (val) {
                          setState(() {
                            _eqEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ─── StreamBuilder for Active Playback ───
                  StreamBuilder<PlaybackState>(
                    stream: audioHandler.playbackState,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data?.playing ?? false;
                      final processingState = snapshot.data?.processingState ?? AudioProcessingState.idle;

                      // If nothing is playing and engine is idle, show fallback
                      if (!isPlaying && processingState == AudioProcessingState.idle) {
                        return SizedBox(
                          height: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.play_circle_outline_rounded, size: 64, color: Colors.white38),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Play a track first to activate the Hardware DSP.',
                                style: TextStyle(color: Colors.white54, fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }

                      // Otherwise, show the actual 10-Band EQ UI with Horizontal Scrolling
                      return AnimatedOpacity(
                        opacity: _eqEnabled ? 1.0 : 0.4,
                        duration: const Duration(milliseconds: 300),
                        child: AbsorbPointer(
                          absorbing: !_eqEnabled, 
                          child: SizedBox(
                            height: 350,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: List.generate(10, (index) {
                                  return SizedBox(
                                    width: 64, 
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: RotatedBox(
                                            quarterTurns: 3,
                                            child: SliderTheme(
                                              data: SliderThemeData(
                                                trackHeight: 4,
                                                activeTrackColor: const Color(0xFFEAB308),
                                                inactiveTrackColor: Colors.white10,
                                                thumbColor: Colors.white,
                                                overlayColor: const Color(0xFFEAB308).withOpacity(0.2),
                                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                              ),
                                              child: Slider(
                                                value: _bandLevels[index],
                                                min: -15.0,
                                                max: 15.0,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _bandLevels[index] = val;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _bandLabels[index],
                                          style: const TextStyle(
                                            color: Colors.white54, 
                                            fontSize: 12, 
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}