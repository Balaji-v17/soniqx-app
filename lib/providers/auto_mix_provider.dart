// ============================================================
//  SONIQ — lib/providers/auto_mix_provider.dart
//  Algorithmic playlist generator based on AI language tags.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart'; 
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

  return db.songsDao.watchAllAvailable().map((songs) {
    final mixes = <SmartMix>[];
    
    final groupedSongs = <String, List<Song>>{};
    
    for (final song in songs) {
      final rawLang = song.languageTag?.trim().toLowerCase();
      // 🎯 FIX 1: Added 'und' to the exclusion list so it doesn't create an "Und Mix"
      if (rawLang != null && 
          rawLang.isNotEmpty && 
          rawLang != 'unclassified' && 
          rawLang != 'unknown' && 
          rawLang != 'und') {
        
        final displayLang = _getDisplayLanguage(rawLang);
        groupedSongs.putIfAbsent(displayLang, () => []).add(song);
      }
    }

    groupedSongs.forEach((displayLang, tracks) {
      if (tracks.length >= 5) {
        tracks.sort((a, b) => (b.durationMs ?? 0).compareTo(a.durationMs ?? 0));
        
        mixes.add(
          SmartMix(
            title: '$displayLang Mix',
            subtitle: 'AI GENERATED • ${tracks.length} TRACKS',
            tracks: tracks,
            gradientColors: _getGradientForLanguage(displayLang),
          ),
        );
      }
    });

    // 🎯 FIX 2: Explicitly catch 'und' tracks and route them to the Discovery Mix
    final untagged = songs.where((s) {
      final lang = s.languageTag?.trim().toLowerCase();
      return lang == null || 
             lang.isEmpty || 
             lang == 'unclassified' || 
             lang == 'unknown' || 
             lang == 'und';
    }).toList();

    if (untagged.length >= 5) {
      mixes.add(
        SmartMix(
          title: 'Discovery Mix',
          subtitle: 'UNCLASSIFIED SONGS • ${untagged.length}',
          tracks: untagged,
          gradientColors: [0xFF4A00E0, 0xFF8E2DE2], 
        )
      );
    }

    return mixes;
  });
});

List<int> _getGradientForLanguage(String displayLang) {
  switch (displayLang.toLowerCase()) { 
    case 'hindi':
      return [0xFFF59E0B, 0xFFEF4444]; 
    case 'kannada':
      return [0xFF10B981, 0xFF059669]; 
    case 'tamil':
      return [0xFF3B82F6, 0xFF1D4ED8]; 
    case 'telugu':
      return [0xFF8B5CF6, 0xFF6D28D9]; 
    case 'malayalam':
      return [0xFF06B6D4, 0xFF0369A1]; 
    case 'english':
      return [0xFF64748B, 0xFF334155]; 
    default:
      return [0xFF1D2671, 0xFFC33764]; 
  }
}

String _getDisplayLanguage(String rawCode) {
  final code = rawCode.toLowerCase();
  if (code.startsWith('hi')) return 'Hindi';
  if (code.startsWith('en')) return 'English';
  if (code.startsWith('ta')) return 'Tamil';
  if (code.startsWith('te')) return 'Telugu';
  if (code.startsWith('kn')) return 'Kannada';
  if (code.startsWith('ml')) return 'Malayalam';
  if (code.startsWith('ar')) return 'Arabic';
  if (code == 'ny') return 'Nyanja';
  if (code == 'und') return 'Unknown';
  
  if (rawCode.isEmpty) return 'Unknown';
  return '${rawCode[0].toUpperCase()}${rawCode.substring(1)}';
}