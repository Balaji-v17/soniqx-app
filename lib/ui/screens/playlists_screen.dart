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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // 🎯 REMOVED: Colors.transparent. Automatically uses the theme's background.
      body: CustomScrollView(
        slivers: [
          // 1. Premium App Bar
          SliverAppBar(
            // 🎯 DYNAMIC: Matches background but keeps the opacity effect
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            pinned: true,
            expandedHeight: 120.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Playlists',
                style: TextStyle(
                  color: colorScheme.onBackground, // 🎯 DYNAMIC
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add_rounded, color: colorScheme.onBackground), // 🎯 DYNAMIC
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
                  Text(
                    'Made for you',
                    style: TextStyle(
                      color: colorScheme.onBackground, // 🎯 DYNAMIC
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
                  color: colorScheme.onBackground.withOpacity(0.9), // 🎯 DYNAMIC
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
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'No playlists created yet.', 
                        style: TextStyle(color: colorScheme.onBackground.withOpacity(0.5)) // 🎯 DYNAMIC
                      ),
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
                          // 🎯 DYNAMIC: Adapts nicely in both themes using primary color with low opacity
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.queue_music_rounded, color: colorScheme.primary),
                      ),
                      title: Text(
                        playlist.name,
                        style: TextStyle(
                          color: colorScheme.onBackground, // 🎯 DYNAMIC
                          fontWeight: FontWeight.w500, 
                          fontSize: 16
                        ),
                      ),
                      
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: colorScheme.onBackground.withOpacity(0.4)), // 🎯 DYNAMIC
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: colorScheme.surface, // 🎯 DYNAMIC
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('Delete Playlist?', style: TextStyle(color: colorScheme.onSurface)), // 🎯 DYNAMIC
                              content: Text(
                                'Are you sure you want to delete "${playlist.name}"? Your songs will remain safely in your library.', 
                                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)) // 🎯 DYNAMIC
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text('CANCEL', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))), // 🎯 DYNAMIC
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
    final colorScheme = Theme.of(context).colorScheme;
    
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface, // 🎯 DYNAMIC
        title: Text('New Playlist', style: TextStyle(color: colorScheme.onSurface)), // 🎯 DYNAMIC
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface), // 🎯 DYNAMIC
          decoration: InputDecoration(
            hintText: 'Playlist Name', 
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.3)), // 🎯 DYNAMIC
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))), // 🎯 DYNAMIC
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
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
              // 💡 Note: Text on solid gradients stays white regardless of theme mode.
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: colorScheme.surface, // 🎯 DYNAMIC
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)), // 🎯 DYNAMIC
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        return Column(
          children: [
            Text(
              '${snapshot.data ?? 0}', 
              style: TextStyle(
                color: colorScheme.onSurface, // 🎯 DYNAMIC
                fontSize: 18, 
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label, 
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.4), // 🎯 DYNAMIC
                fontSize: 10, 
                letterSpacing: 1.0, 
                fontWeight: FontWeight.w600
              ),
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
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1), // 🎯 DYNAMIC
    );
  }
}