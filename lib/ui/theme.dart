import 'package:flutter/material.dart';

class SoniqTheme {
  // Add this 'static' getter so it's accessible as SoniqTheme.darkTheme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
    );
  }

  static BoxDecoration glassDecoration(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: cs.surfaceContainerHighest.withOpacity(0.85),
      borderRadius: BorderRadius.circular(24),
    );
  }

  static const double miniPlayerHeight = 68;
}