// ============================================================
//  SONIQ — lib/ui/screens/equalizer_screen.dart
//  Hardware DSP Equalizer & Psychoacoustic Effects
// ============================================================

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/audio/equalizer_presets.dart'; 

class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  bool _isEnabled = false;
  AndroidEqualizerParameters? _params;
  EqPreset _currentPreset = kBuiltinPresets[0];
  
  double _bassBoostLevel = 0; 
  double _virtualizerLevel = 0; 

  @override
  void initState() {
    super.initState();
    _initEqualizer();
  }

  Future<void> _initEqualizer() async {
    if (!Platform.isAndroid) return; 

    final handler = ref.read(audioHandlerProvider);
    final eq = handler.equalizer;

    final params = await eq.parameters;

    if (mounted) {
      setState(() {
        _isEnabled = eq.enabled;
        _params = params;
      });
    }

    eq.enabledStream.listen((enabled) {
      if (mounted) setState(() => _isEnabled = enabled);
    });
  }

  void _toggleEqualizer(bool value) async {
    final handler = ref.read(audioHandlerProvider);
    await handler.equalizer.setEnabled(value);
  }

  Future<void> _applyPreset(EqPreset preset) async {
    if (_params == null) return;
    setState(() => _currentPreset = preset);

    final bands = _params!.bands;

    for (int i = 0; i < bands.length; i++) {
      final band = bands[i];
      final freqHz = band.centerFrequency;

      int closestIndex = 0;
      double minDiff = double.infinity;
      for (int j = 0; j < kEqBandFrequenciesHz.length; j++) {
        final diff = (kEqBandFrequenciesHz[j] - freqHz).abs();
        if (diff < minDiff) {
          minDiff = diff;
          closestIndex = j;
        }
      }

      final targetGain = preset.bands[closestIndex];
      final clampedGain = targetGain.clamp(_params!.minDecibels, _params!.maxDecibels);

      await band.setGain(clampedGain);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Graphic Equalizer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Switch(
            value: _isEnabled,
            onChanged: _toggleEqualizer,
            activeColor: const Color(0xFFC49A45),
            inactiveTrackColor: Colors.white10,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: !Platform.isAndroid
          ? const Center(child: Text("Equalizer is only supported on Android.", style: TextStyle(color: Colors.white54)))
          : _params == null
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFC49A45)))
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: kBuiltinPresets.length,
                        itemBuilder: (context, index) {
                          final preset = kBuiltinPresets[index];
                          final isSelected = _currentPreset.id == preset.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('${preset.emoji} ${preset.name}', style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
                              selected: isSelected,
                              selectedColor: const Color(0xFFC49A45).withOpacity(0.3),
                              backgroundColor: const Color(0xFF1E1E1E),
                              side: BorderSide(color: isSelected ? const Color(0xFFC49A45) : Colors.transparent),
                              onSelected: (_) => _applyPreset(preset),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _params!.bands.map((band) {
                          return _buildSlider(band);
                        }).toList(),
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBassBooster(),
                          _buildVirtualizer(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  Widget _buildSlider(AndroidEqualizerBand band) {
    String freqLabel;
    if (band.centerFrequency >= 1000) {
      freqLabel = '${(band.centerFrequency / 1000).toStringAsFixed(0)}K';
    } else {
      freqLabel = band.centerFrequency.toStringAsFixed(0);
    }

    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 6, 
                activeTrackColor: const Color(0xFF00E5FF), 
                inactiveTrackColor: Colors.white10,
                thumbColor: const Color(0xFF1E1E1E), 
                overlayColor: const Color(0xFF00E5FF).withOpacity(0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 6, pressedElevation: 10),
              ),
              child: StreamBuilder<double>(
                stream: band.gainStream,
                builder: (context, snapshot) {
                  final gain = snapshot.data ?? band.gain;
                  return Slider(
                    min: _params!.minDecibels,
                    max: _params!.maxDecibels,
                    value: gain,
                    onChanged: _isEnabled ? (val) {
                      band.setGain(val);
                      if (_currentPreset.id != 'custom') {
                        setState(() {
                          _currentPreset = const EqPreset(id: 'custom', name: 'Custom', emoji: '🎛️', bands: []);
                        });
                      }
                    } : null,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(freqLabel, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBassBooster() {
    return Column(
      children: [
        SleekCircularSlider(
          min: 0, max: 100, initialValue: _bassBoostLevel,
          appearance: CircularSliderAppearance(
            size: 130, angleRange: 240, startAngle: 150,
            customColors: CustomSliderColors(
              trackColor: Colors.white10,
              progressBarColors: [const Color(0xFF00E5FF), const Color(0xFFB3FF00), const Color(0xFFFF9800)],
              dotColor: Colors.transparent, 
              shadowColor: const Color(0xFF00E5FF).withOpacity(0.2), shadowMaxOpacity: 0.1, shadowStep: 5,
            ),
            customWidths: CustomSliderWidths(trackWidth: 10, progressBarWidth: 14, handlerSize: 0),
          ),
          innerWidget: (percentage) {
            final double degrees = 150 + ((percentage / 100) * 240);
            final double radians = degrees * (pi / 180);
            return Transform.rotate(
              angle: radians,
              child: Padding(
                padding: const EdgeInsets.all(22.0), 
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFF2A2A2A), Color(0xFF0F0F0F)], center: Alignment.topLeft, radius: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 12, spreadRadius: 2),
                      BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 2, spreadRadius: 1),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: 12, height: 3,
                        decoration: BoxDecoration(color: const Color(0xFF00E5FF), borderRadius: BorderRadius.circular(2), boxShadow: const [BoxShadow(color: Color(0xFF00E5FF), blurRadius: 6)]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          onChange: _isEnabled ? (double value) {
            _bassBoostLevel = value;
            if (_params != null && _params!.bands.isNotEmpty) {
              // 🎯 THE HACK: Manually push the 60Hz band to simulate Bass Boost
              final bassBand = _params!.bands[0];
              final targetGain = (value / 100) * _params!.maxDecibels;
              bassBand.setGain(targetGain);
              
              if (_currentPreset.id != 'custom') {
                setState(() => _currentPreset = const EqPreset(id: 'custom', name: 'Custom', emoji: '🎛️', bands: []));
              }
            }
          } : null,
        ),
        const SizedBox(height: 16),
        Text("Bass Booster", style: TextStyle(color: _isEnabled ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildVirtualizer() {
    return Column(
      children: [
        SleekCircularSlider(
          min: 0, max: 100, initialValue: _virtualizerLevel,
          appearance: CircularSliderAppearance(
            size: 130, angleRange: 240, startAngle: 150,
            customColors: CustomSliderColors(
              trackColor: Colors.white10,
              progressBarColors: [const Color(0xFF9D00FF), const Color(0xFFFF007F)], 
              dotColor: Colors.transparent, shadowColor: const Color(0xFF9D00FF).withOpacity(0.2), shadowMaxOpacity: 0.1, shadowStep: 5,
            ),
            customWidths: CustomSliderWidths(trackWidth: 10, progressBarWidth: 14, handlerSize: 0),
          ),
          innerWidget: (percentage) {
            final double degrees = 150 + ((percentage / 100) * 240);
            final double radians = degrees * (pi / 180);
            return Transform.rotate(
              angle: radians, 
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFF2A2A2A), Color(0xFF0F0F0F)], center: Alignment.topLeft, radius: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.8), blurRadius: 12, spreadRadius: 2),
                      BoxShadow(color: Colors.white.withOpacity(0.05), blurRadius: 2, spreadRadius: 1),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: 12, height: 3,
                        decoration: BoxDecoration(color: const Color(0xFF9D00FF), borderRadius: BorderRadius.circular(2), boxShadow: const [BoxShadow(color: Color(0xFF9D00FF), blurRadius: 6)]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          onChange: _isEnabled ? (double value) {
            _virtualizerLevel = value;
            if (_params != null && _params!.bands.length >= 5) {
              // 🎯 THE HACK: Psychoacoustic Spatialization
              // Scoop the mids (910Hz) to create distance, boost the highs (14KHz) to create width.
              final midBand = _params!.bands[2]; 
              final highBand = _params!.bands[4]; 
              
              final spatialGain = (value / 100) * (_params!.maxDecibels * 0.8);
              final midScoop = -(value / 100) * (_params!.maxDecibels * 0.5); 
              
              highBand.setGain(spatialGain);
              midBand.setGain(midScoop);
              
              if (_currentPreset.id != 'custom') {
                setState(() => _currentPreset = const EqPreset(id: 'custom', name: 'Custom', emoji: '🎛️', bands: []));
              }
            }
          } : null,
        ),
        const SizedBox(height: 16),
        Text("Virtualizer", style: TextStyle(color: _isEnabled ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}