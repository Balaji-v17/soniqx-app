import 'package:flutter/material.dart';

class FallbackAlbumArt extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final double shadowOpacity;

  const FallbackAlbumArt({
    super.key,
    this.width = 56.0,
    this.height = 56.0,
    this.borderRadius = 12.0,
    this.shadowOpacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: -2, 
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          // 🎯 FIXED: Now correctly points to the new .jpg file
          'assets/images/default_album_art.jpg',
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              // Changed the deep fallback color to match the new dark neon vibe
              color: const Color(0xFF0F0B1A), 
              child: Icon(Icons.music_note_rounded, color: Colors.white24, size: width * 0.5),
            );
          },
        ),
      ),
    );
  }
}