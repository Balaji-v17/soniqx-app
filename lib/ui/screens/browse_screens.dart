// ============================================================
//  SONIQ — lib/ui/screens/browse_screens.dart
//  Premium Grid and Detail Views for Albums & Artists.
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/audio/artwork_extractor.dart';
import 'package:soniq/ui/widgets/fallback_album_art.dart';
import 'package:soniq/ui/song_tile.dart';

// ─── ALBUMS SCREEN ──────────────────────────────────────────────────

class AlbumsScreen extends ConsumerWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Albums', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Song>>(
        stream: db.songsDao.watchAllAvailable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }
          
          final songs = snapshot.data ?? [];
          if (songs.isEmpty) return const Center(child: Text("No albums found.", style: TextStyle(color: Colors.white54)));

          // Group songs by Album
          final albumsMap = <String, List<Song>>{};
          for (var s in songs) {
            final albumName = (s.album?.trim().isNotEmpty == true) ? s.album!.trim() : 'Unknown Album';
            albumsMap.putIfAbsent(albumName, () => []).add(s);
          }
          
          final albumNames = albumsMap.keys.toList()..sort();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              childAspectRatio: 0.80, 
              crossAxisSpacing: 16, 
              mainAxisSpacing: 16,
            ),
            itemCount: albumNames.length,
            itemBuilder: (context, index) {
              final albumName = albumNames[index];
              final albumSongs = albumsMap[albumName]!;
              return _CategoryGridItem(
                title: albumName,
                subtitle: '${albumSongs.length} tracks',
                sampleSongPath: albumSongs.first.path,
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => CategoryDetailScreen(title: albumName, songs: albumSongs))
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── ARTISTS SCREEN ─────────────────────────────────────────────────

class ArtistsScreen extends ConsumerWidget {
  const ArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Artists', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Song>>(
        stream: db.songsDao.watchAllAvailable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }
          
          final songs = snapshot.data ?? [];
          if (songs.isEmpty) return const Center(child: Text("No artists found.", style: TextStyle(color: Colors.white54)));

          // Group songs by Artist
          final artistsMap = <String, List<Song>>{};
          for (var s in songs) {
            final artistName = (s.artist?.trim().isNotEmpty == true) ? s.artist!.trim() : 'Unknown Artist';
            artistsMap.putIfAbsent(artistName, () => []).add(s);
          }
          
          final artistNames = artistsMap.keys.toList()..sort();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              childAspectRatio: 0.80, 
              crossAxisSpacing: 16, 
              mainAxisSpacing: 16,
            ),
            itemCount: artistNames.length,
            itemBuilder: (context, index) {
              final artistName = artistNames[index];
              final artistSongs = artistsMap[artistName]!;
              return _CategoryGridItem(
                title: artistName,
                subtitle: '${artistSongs.length} tracks',
                sampleSongPath: artistSongs.first.path,
                isCircular: true, // Artists traditionally use circular avatars
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => CategoryDetailScreen(title: artistName, songs: artistSongs))
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── DETAIL SCREEN ──────────────────────────────────────────────────

class CategoryDetailScreen extends ConsumerWidget {
  final String title;
  final List<Song> songs;

  const CategoryDetailScreen({super.key, required this.title, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎯 Use the first song's path to extract the artwork for the header
    final samplePath = songs.isNotEmpty ? songs.first.path : '';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: CustomScrollView(
        slivers: [
          // 🎯 Premium Sliver App Bar with Dynamic Artwork
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 48, bottom: 16),
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Artwork Layer
                  if (samplePath.isNotEmpty)
                    FutureBuilder<Uri?>(
                      future: ArtworkExtractor.getArtUriFromPath(samplePath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                          return Image.file(
                            File(snapshot.data!.toFilePath()),
                            fit: BoxFit.cover,
                          );
                        }
                        return const FallbackAlbumArt(width: double.infinity, height: 320, borderRadius: 0);
                      },
                    )
                  else
                    const FallbackAlbumArt(width: double.infinity, height: 320, borderRadius: 0),
                  
                  // Gradient Overlay Layer to ensure text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF121212).withOpacity(0.5),
                          const Color(0xFF121212),
                        ],
                        stops: const [0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 🎯 Song List
          SliverPadding(
            padding: const EdgeInsets.only(top: 8, bottom: 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = songs[index];
                  return SongTile(
                    song: song,
                    onTap: () async {
                      final audioHandler = ref.read(audioHandlerProvider);
                      
                      final items = await Future.wait(songs.map((s) async {
                        final artUri = await ArtworkExtractor.getArtUriFromPath(s.path);
                        return MediaItem(
                          id: s.id.toString(),
                          title: s.title ?? "Unknown Track",
                          artist: s.artist ?? "Unknown Artist",
                          duration: Duration(milliseconds: s.durationMs ?? 0),
                          artUri: artUri,
                          extras: {'path': s.path}, 
                        );
                      }));

                      await audioHandler.updateQueue(items);
                      await audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
                      await audioHandler.skipToQueueItem(index);
                      await audioHandler.play();
                    },
                  );
                },
                childCount: songs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── REUSABLE GRID WIDGET ───────────────────────────────────────────

class _CategoryGridItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String sampleSongPath;
  final bool isCircular;
  final VoidCallback onTap;

  const _CategoryGridItem({
    required this.title,
    required this.subtitle,
    required this.sampleSongPath,
    this.isCircular = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FutureBuilder<Uri?>(
              future: ArtworkExtractor.getArtUriFromPath(sampleSongPath),
              builder: (context, snapshot) {
                Widget imageWidget;
                if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                  imageWidget = Image.file(File(snapshot.data!.toFilePath()), fit: BoxFit.cover);
                } else {
                  imageWidget = const FallbackAlbumArt(width: 200, height: 200, borderRadius: 0);
                }

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isCircular ? null : BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                    ]
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageWidget,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title, 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 1, 
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle, 
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}