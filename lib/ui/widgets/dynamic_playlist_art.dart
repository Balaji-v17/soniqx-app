import 'package:flutter/material.dart';
import 'dart:math';

class DynamicPlaylistArt extends StatelessWidget {
  final String title;
  final double size;
  final double borderRadius;

  const DynamicPlaylistArt({
    super.key,
    required this.title,
    this.size = 140,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    // 🎯 Generate deterministic colors using the string's hash code
    final hash = title.hashCode;
    final random = Random(hash);
    
    // Pick two beautiful, saturated hues
    final hue1 = random.nextDouble() * 360;
    // Ensure the second hue is far enough away on the color wheel for a good gradient
    final hue2 = (hue1 + 45 + random.nextDouble() * 90) % 360;
    
    final color1 = HSLColor.fromAHSL(1.0, hue1, 0.7, 0.5).toColor();
    final color2 = HSLColor.fromAHSL(1.0, hue2, 0.8, 0.4).toColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Center(
        child: Text(
          title.trim().isNotEmpty ? title.trim().substring(0, 1).toUpperCase() : '?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}