// ============================================================
//  SONIQ — lib/ui/screens/playlists_screen.dart
//  Premium Playlists Dashboard connected to Drift DB.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';
import 'playlist_detail_screen.dart'; 

class PlaylistsScreen extends ConsumerWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // 1. Premium App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF0A0A0A).withOpacity(0.9),
            pinned: true,
            expandedHeight: 120.0,
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Playlists',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                onPressed: () => _showCreatePlaylistDialog(context, db),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // 2. The "Made for you" Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Made for you',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Horizontal Scroll for Premium Mixes
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _GradientPlaylistCard(
                          title: 'night mix',
                          subtitle: 'CUSTOM MIX',
                          colors: [Color(0xFF4F46E5), Color(0xFFDB2777)],
                        ),
                        SizedBox(width: 16),
                        _GradientPlaylistCard(
                          title: 'Focus Flow',
                          subtitle: 'MODERN CLASSICAL',
                          colors: [Color(0xFF991B1B), Color(0xFF450A0A)],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. The Real-Time Statistics Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _RealLibraryStatsRow(db: db),
            ),
          ),

          // 4. User Custom Playlists Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 32.0, bottom: 16.0),
              child: Text(
                'My Collections',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 5. Dynamic User Playlists List
          StreamBuilder<List<Playlist>>(
            stream: db.playlistsDao.watchAllUserPlaylists(),
            builder: (context, snapshot) {
              final playlists = snapshot.data ?? [];

              if (playlists.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text('No playlists created yet.', style: TextStyle(color: Colors.white38)),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      leading: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.queue_music_rounded, color: Color(0xFF818CF8)),
                      ),
                      title: Text(
                        playlist.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      
                      // 🎯 FIXED: Added the delete button with a confirmation dialog
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF1E1E1E),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Delete Playlist?', style: TextStyle(color: Colors.white)),
                              content: Text(
                                'Are you sure you want to delete "${playlist.name}"? Your songs will remain safely in your library.', 
                                style: const TextStyle(color: Colors.white70)
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await db.playlistsDao.deletePlaylist(playlist.id);
                          }
                        },
                      ),
                      
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistDetailScreen(playlist: playlist),
                          ),
                        );
                      },
                    );
                  },
                  childCount: playlists.length,
                ),
              );
            },
          ),
          
          // Padding for the Mini Player
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, AppDatabase db) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('New Playlist', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist Name', 
            hintStyle: TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6366F1))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF818CF8))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await db.playlistsDao.createPlaylist(controller.text);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────

class _GradientPlaylistCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Color> colors;

  const _GradientPlaylistCard({
    required this.title,
    required this.subtitle,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Real Data Stats Row ─────────────────────────────────────────────

class _RealLibraryStatsRow extends StatelessWidget {
  final AppDatabase db;
  const _RealLibraryStatsRow({required this.db});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF13141F),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatStream(stream: db.songsDao.getTotalSongsCount(), label: 'TRACKS'),
          const _Divider(),
          _StatStream(stream: db.songsDao.getTotalAlbumsCount(), label: 'ALBUMS'),
          const _Divider(),
          _StatStream(stream: db.songsDao.getTotalArtistsCount(), label: 'ARTISTS'),
        ],
      ),
    );
  }
}

class _StatStream extends StatelessWidget {
  final Stream<int> stream;
  final String label;
  
  const _StatStream({required this.stream, required this.label});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        return Column(
          children: [
            Text(
              '${snapshot.data ?? 0}', 
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }
}