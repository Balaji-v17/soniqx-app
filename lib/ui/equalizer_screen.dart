import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({super.key});

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  // Placeholder values for a 5-band EQ (-15dB to +15dB)
  final List<double> _bandLevels = [0.0, 3.0, -2.0, 4.0, 1.0];
  final List<String> _bandLabels = ['60Hz', '230Hz', '910Hz', '3.6kHz', '14kHz'];
  bool _eqEnabled = true;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text('Equalizer', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          Switch(
            value: _eqEnabled,
            activeColor: const Color(0xFF6366F1),
            onChanged: (val) {
              setState(() => _eqEnabled = val);
              // TODO: Tell backend to toggle EQ
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _eqEnabled ? _buildSliders(textColor) : Center(
        child: Text('Equalizer is disabled', style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 16)),
      ),
    );
  }

  Widget _buildSliders(Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 48.0, bottom: 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_bandLevels.length, (index) {
          return Column(
            children: [
              Text(
                '${_bandLevels[index] > 0 ? '+' : ''}${_bandLevels[index].toInt()} dB',
                style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3, 
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: const Color(0xFF6366F1),
                      inactiveTrackColor: textColor.withOpacity(0.1),
                      thumbColor: Colors.white,
                      overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _bandLevels[index],
                      min: -15.0,
                      max: 15.0,
                      onChanged: (val) {
                        setState(() => _bandLevels[index] = val);
                        // TODO: Send exact dB value to audio backend
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _bandLabels[index],
                style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          );
        }),
      ),
    );
  }
}