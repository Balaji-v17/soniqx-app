import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/audio/equalizer_presets.dart'; // The file you just generated

class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  bool _isEnabled = false;
  AndroidEqualizerParameters? _params;
  EqPreset _currentPreset = kBuiltinPresets[0];

  @override
  void initState() {
    super.initState();
    _initEqualizer();
  }

  Future<void> _initEqualizer() async {
    // Native Equalizer is an Android-exclusive hardware feature in just_audio
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

      // 🎯 Smart Mapping Algorithm: Finds the closest 10-band preset value for the device's actual native band
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
      // Native Android bounds are often -15dB to +15dB, so we safely clamp
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
                    // Presets Row
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
                    const Spacer(),
                    
                    // Dynamic Sliders matching the screenshot
                    SizedBox(
                      height: 300,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _params!.bands.map((band) {
                          return _buildSlider(band);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 64),
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
                trackHeight: 4,
                activeTrackColor: const Color(0xFFC49A45),
                inactiveTrackColor: Colors.white10,
                thumbColor: const Color(0xFFD4D4D8),
                overlayColor: const Color(0xFFC49A45).withOpacity(0.2),
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
        Text(freqLabel, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}