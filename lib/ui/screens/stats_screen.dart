// ============================================================
//  SONIQ — lib/ui/screens/stats_screen.dart
//  Personalized Listening Statistics Dashboard.
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers/stats_provider.dart';
import 'package:soniq/audio/artwork_extractor.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPlaysAsync = ref.watch(totalPlaysProvider);
    final topSongsAsync = ref.watch(topSongsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A).withOpacity(0.9),
        elevation: 0,
        title: const Text(
          'Your Stats',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF6366F1),
        backgroundColor: const Color(0xFF13141F),
        onRefresh: () async {
          ref.invalidate(totalPlaysProvider);
          ref.invalidate(topSongsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // 🎯 Total Plays Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bar_chart_rounded, color: Colors.white70, size: 32),
                  const SizedBox(height: 16),
                  totalPlaysAsync.when(
                    data: (plays) => Text(
                      '$plays',
                      style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, height: 1.0),
                    ),
                    loading: () => const SizedBox(height: 48, child: CircularProgressIndicator(color: Colors.white)),
                    error: (_, __) => const Text('Error', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 4),
                  const Text('Total Tracks Played', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'TOP TRACKS',
              style: TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 16),
            
            // 🎯 Top Songs List
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF13141F),
                borderRadius: BorderRadius.circular(24),
              ),
              child: topSongsAsync.when(
                data: (songs) {
                  if (songs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          'Keep listening to generate your top tracks!',
                          style: TextStyle(color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  
                  return Column(
                    children: songs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final song = entry.value;
                      final isLast = index == songs.length - 1;
                      
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            
                            // 🎯 FIXED: Rank numbers and Album Art side-by-side
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '#${index + 1}',
                                    style: TextStyle(
                                      color: index < 3 ? const Color(0xFF6366F1) : Colors.white38,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (song['path'] != null)
                                  FutureBuilder<Uri?>(
                                    future: ArtworkExtractor.getArtUriFromPath(song['path']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Image.file(
                                            File(snapshot.data!.toFilePath()),
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _buildStatsFallback(),
                                          ),
                                        );
                                      }
                                      return _buildStatsFallback();
                                    },
                                  )
                                else
                                  _buildStatsFallback(),
                              ],
                            ),
                            
                            title: Text(song['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            subtitle: Text(song['artist'], style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                            trailing: Text(
                              '${song['count']} plays',
                              style: const TextStyle(color: Color(0xFF639922), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          if (!isLast) const Divider(color: Colors.white10, height: 1, indent: 24, endIndent: 24),
                        ],
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
                ),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent))),
              ),
            ),
            
            const SizedBox(height: 120), // Mini-player padding
          ],
        ),
      ),
    );
  }

  // 🎯 Helper for fallback album art
  Widget _buildStatsFallback() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        width: 44,
        height: 44,
        color: Colors.white10,
        child: const Icon(Icons.music_note_rounded, color: Color(0xFF818CF8), size: 20),
      ),
    );
  }
}