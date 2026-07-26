import 'package:flutter/material.dart';
import 'dart:math';

class MiniWaveform extends StatefulWidget {
  final Color color;
  final bool isPlaying;
  final double size;

  const MiniWaveform({
    super.key,
    required this.color,
    this.isPlaying = true,
    this.size = 24.0,
  });

  @override
  State<MiniWaveform> createState() => _MiniWaveformState();
}

class _MiniWaveformState extends State<MiniWaveform> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isPlaying) _controller.repeat();
  }

  @override
  void didUpdateWidget(MiniWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(4, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // 🎯 The Math: Staggered sine waves for an organic audio bounce
              final sineValue = sin((_controller.value * 2 * pi) + (index * pi / 2));
              final heightMultiplier = widget.isPlaying ? (0.3 + (0.7 * sineValue.abs())) : 0.2;

              return Container(
                width: widget.size * 0.15,
                height: widget.size * heightMultiplier,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}