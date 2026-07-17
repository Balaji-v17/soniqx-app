// ============================================================
//  SONIQ — lib/ui/screens/playlist_detail_screen.dart
//  Dynamic Playlist View & Song Management.
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/audio/soniq_audio_handler.dart';
import 'package:soniq/audio/artwork_extractor.dart';
import 'package:soniq/audio/shuffle_engine.dart';
import 'package:soniq/ui/widgets/mini_player.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final audioHandler = ref.watch(audioHandlerProvider);
    
    // Grab the current theme to dynamically style the UI
    final theme = Theme.of(context);

    return Scaffold(
      // 🎯 FIXED: Removed hardcoded black background. Now it inherits the global theme background.
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Premium App Bar
              SliverAppBar(
                backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
                pinned: true,
                expandedHeight: 120.0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
                  title: Text(
                    playlist.name,
                    style: TextStyle(
                      color: theme.textTheme.titleLarge?.color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.add_rounded, color: theme.iconTheme.color, size: 28),
                    onPressed: () => _showAddSongsSheet(context, db, playlist.id, theme),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // 2. Play & Shuffle Controls
              StreamBuilder<List<Song>>(
                stream: db.playlistsDao.watchSongsForPlaylist(playlist.id),
                builder: (context, snapshot) {
                  final songs = snapshot.data ?? [];
                  
                  if (songs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _playPlaylist(songs, 0, audioHandler),
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                              label: const Text('Play', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1), // Kept primary brand color
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _shufflePlaylist(songs, audioHandler),
                              icon: Icon(Icons.shuffle_rounded, color: theme.colorScheme.onSurfaceVariant),
                              label: Text('Shuffle', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.surfaceVariant, // 🎯 FIXED: Dynamic button background
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 3. Dynamic Song List
              StreamBuilder<List<Song>>(
                stream: db.playlistsDao.watchSongsForPlaylist(playlist.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
                    );
                  }

                  final songs = snapshot.data ?? [];

                  if (songs.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.queue_music_rounded, size: 64, color: theme.iconTheme.color?.withOpacity(0.1)),
                            const SizedBox(height: 16),
                            Text(
                              'This playlist is empty',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5)),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => _showAddSongsSheet(context, db, playlist.id, theme),
                              child: const Text('Add Songs', style: TextStyle(color: Color(0xFF818CF8))),
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final song = songs[index];
                        return _PlaylistSongTile(
                          song: song,
                          playlistId: playlist.id,
                          db: db,
                          theme: theme, // Pass theme to tile
                          onTap: () => _playPlaylist(songs, index, audioHandler),
                        );
                      },
                      childCount: songs.length,
                    ),
                  );
                },
              ),
              
              // Clear the mini-player padding
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          
          const Align(
            alignment: Alignment.bottomCenter,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }

  Future<void> _playPlaylist(List<Song> songs, int startIndex, SoniqAudioHandler handler) async {
    final queue = await Future.wait(songs.map((s) async {
      final artUri = await ArtworkExtractor.getArtUriFromPath(s.path);
      return MediaItem(
        id: s.id.toString(),
        title: s.title ?? 'Unknown Track',
        artist: s.artist ?? 'Unknown Artist',
        album: s.album ?? 'Unknown Album',
        duration: Duration(milliseconds: s.durationMs ?? 0),
        artUri: artUri,
        extras: {'path': s.path},
      );
    }));

    await handler.updateQueue(queue);
    await handler.setShuffleMode(AudioServiceShuffleMode.none); 
    await handler.skipToQueueItem(startIndex);
    await handler.play();
  }

  Future<void> _shufflePlaylist(List<Song> songs, SoniqAudioHandler handler) async {
    final shuffleEngine = SoniqShuffleEngine();
    final shuffleResult = shuffleEngine.generateQueue(songs);

    final queue = await Future.wait(shuffleResult.queue.map((s) async {
      final artUri = await ArtworkExtractor.getArtUriFromPath(s.path);
      return MediaItem(
        id: s.id.toString(),
        title: s.title ?? 'Unknown Track',
        artist: s.artist ?? 'Unknown Artist',
        album: s.album ?? 'Unknown Album',
        duration: Duration(milliseconds: s.durationMs ?? 0),
        artUri: artUri,
        extras: {'path': s.path},
      );
    }));

    await handler.updateQueue(queue);
    await handler.setShuffleMode(AudioServiceShuffleMode.all); 
    await handler.skipToQueueItem(0);
    await handler.play();
  }

  void _showAddSongsSheet(BuildContext context, AppDatabase db, int playlistId, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor, // 🎯 FIXED: Dynamic bottom sheet color
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Add Songs', style: TextStyle(color: theme.textTheme.titleLarge?.color, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: StreamBuilder<List<Song>>(
                stream: db.songsDao.watchAllAvailable(),
                builder: (context, snapshot) {
                  final allSongs = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: allSongs.length,
                    itemBuilder: (context, index) {
                      final song = allSongs[index];
                      return ListTile(
                        leading: Icon(Icons.music_note_rounded, color: theme.iconTheme.color?.withOpacity(0.6)),
                        title: Text(song.title ?? 'Unknown Track', maxLines: 1, style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                        subtitle: Text(song.artist ?? 'Unknown', maxLines: 1, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF6366F1)),
                          onPressed: () async {
                            await db.playlistsDao.addSongToPlaylist(playlistId, song.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${song.title}'),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFF4F46E5),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistSongTile extends StatelessWidget {
  final Song song;
  final int playlistId;
  final AppDatabase db;
  final ThemeData theme;
  final VoidCallback onTap;

  const _PlaylistSongTile({
    required this.song,
    required this.playlistId,
    required this.db,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 48,
          height: 48,
          color: theme.colorScheme.surfaceVariant, // 🎯 FIXED: Dynamic icon container
          child: const Icon(Icons.music_note_rounded, color: Color(0xFF818CF8)),
        ),
      ),
      title: Text(
        song.title ?? 'Unknown Track',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        song.artist ?? 'Unknown Artist',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6), fontSize: 13),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded, color: theme.iconTheme.color?.withOpacity(0.6)),
        color: theme.cardColor, // 🎯 FIXED: Dynamic popup menu background
        onSelected: (value) async {
          if (value == 'remove') {
            final entries = await db.select(db.playlistEntries).get();
            final entryToRemove = entries.firstWhere(
              (e) => e.playlistId == playlistId && e.songId == song.id,
            );
            await db.playlistsDao.removeSongFromPlaylist(entryToRemove.id);
          }
        },
        itemBuilder: (BuildContext context) => [
          const PopupMenuItem(
            value: 'remove',
            child: Text('Remove from Playlist', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}