// ============================================================
//  SONIQ — lib/providers/auto_mix_provider.dart
//  Algorithmic playlist generator based on AI language tags.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart'; // Ensure this points to databaseProvider
import 'package:soniq/database/database.dart';

class SmartMix {
  final String title;
  final String subtitle;
  final List<Song> tracks;
  final List<int> gradientColors;

  SmartMix({
    required this.title,
    required this.subtitle,
    required this.tracks,
    required this.gradientColors,
  });
}

final autoMixProvider = StreamProvider<List<SmartMix>>((ref) {
  final db = ref.watch(databaseProvider);

  // Watch the entire library so mixes update instantly if a tag changes
  return db.songsDao.watchAllAvailable().map((songs) {
    final mixes = <SmartMix>[];
    
    // Group songs by their AI language tag
    final groupedSongs = <String, List<Song>>{};
    for (final song in songs) {
      if (song.languageTag != null && song.languageTag!.isNotEmpty) {
        final lang = song.languageTag!.toLowerCase();
        groupedSongs.putIfAbsent(lang, () => []).add(song);
      }
    }

    // Build a mix for any language that has at least 3 tracks
    groupedSongs.forEach((lang, tracks) {
      if (tracks.length >= 1) {
        // Sort by duration or date added just to mix it up
        tracks.sort((a, b) => (b.durationMs ?? 0).compareTo(a.durationMs ?? 0));
        
        mixes.add(
          SmartMix(
            title: '${lang[0].toUpperCase()}${lang.substring(1)} Mix',
            subtitle: 'AI GENERATED • ${tracks.length} TRACKS',
            tracks: tracks,
            gradientColors: _getGradientForLanguage(lang),
          ),
        );
      }
    });

    // Optionally add an "Untagged" mix if you have unclassified songs
    final untagged = songs.where((s) => s.languageTag == null).toList();
    if (untagged.length >= 5) {
      mixes.add(
        SmartMix(
          title: 'Discovery Mix',
          subtitle: 'HELP THE AI LEARN',
          tracks: untagged,
          gradientColors: [0xFF4A00E0, 0xFF8E2DE2], // Purple
        )
      );
    }

    return mixes;
  });
});

// Helper to give each language a distinct, beautiful gradient on the Home Screen
List<int> _getGradientForLanguage(String lang) {
  switch (lang) {
    case 'hindi':
      return [0xFFF59E0B, 0xFFEF4444]; // Amber to Red
    case 'kannada':
      return [0xFF10B981, 0xFF059669]; // Emerald to Green
    case 'tamil':
      return [0xFF3B82F6, 0xFF1D4ED8]; // Blue to Dark Blue
    case 'telugu':
      return [0xFF8B5CF6, 0xFF6D28D9]; // Purple to Deep Purple
    case 'english':
      return [0xFF64748B, 0xFF334155]; // Slate to Dark Slate
    default:
      return [0xFF1D2671, 0xFFC33764]; // Default Soniq Pink/Navy
  }
}