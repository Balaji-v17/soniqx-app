// ============================================================
//  SONIQ — lib/ui/widgets/artwork_display.dart
//  Universal artwork renderer with premium fallback UI.
// ============================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';

class ArtworkDisplay extends StatelessWidget {
  final Uint8List? artworkBytes;
  final double size;
  final double borderRadius;
  final IconData fallbackIcon;

  const ArtworkDisplay({
    super.key,
    required this.artworkBytes,
    this.size = 56.0,
    this.borderRadius = 12.0,
    this.fallbackIcon = Icons.music_note_rounded,
  });

  @override
  Widget build(BuildContext context) {
    // 1. If we have valid bytes, try to render the image
    if (artworkBytes != null && artworkBytes!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.memory(
          artworkBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          // 2. If the bytes are corrupted and Flutter fails to decode them,
          // gracefully catch the crash and show the fallback anyway!
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        ),
      );
    }
    
    // 3. If there are no bytes at all, show the fallback
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E29), // Premium dark surface
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white10, width: 1), // Subtle outline
      ),
      child: Center(
        child: Icon(
          fallbackIcon,
          color: Colors.white38,
          size: size * 0.5, // Icon scales perfectly with the container
        ),
      ),
    );
  }
}