import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:drift/drift.dart' as drift;

import 'package:soniq/providers/library_filter_provider.dart';
import 'package:soniq/providers/auto_mix_provider.dart'; 
import '../classifier/language_service.dart'; // 🎯 Added to access the AI Engine

import '../audio/artwork_extractor.dart';
import '../providers.dart';
import '../database/database.dart'; 
import 'song_tile.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredSongsAsync = ref.watch(filteredLibraryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.sync_rounded, color: Colors.white),
        onPressed: () async {
          debugPrint("Triggering AI Classification Pass...");
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🤖 AI is scanning tracks...'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          }

          // 🎯 This forces the AI to scan the database and tag everything again!
          await ref.read(languageServiceProvider).runClassificationPass();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✨ AI Tagging Complete!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Header
            _buildHeader(),
            
            // 2. Dynamic Filter Chips
            _buildFilterChips(context, ref),

            // 3. Real "Jump Back In" Section
            _buildSectionTitle('Jump back in', 'View all'),
            _buildJumpBackInList(ref),

            // 4. Real "Made For You" Section
            _buildSectionTitle('Made for you', ''),
            _buildMadeForYouList(ref),

            // 5. Section Title (Updates dynamically based on filter)
            _buildDynamicSectionTitle(ref),

            // 6. The Filtered Audio Files Stream
            filteredSongsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white54))),
                ),
              ),
              data: (songs) {
                if (songs.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          "No tracks found for this filter.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = songs[index];
                      return SongTile(
                        song: song,
                        onTap: () async {
                          final audioHandler = ref.read(audioHandlerProvider);
                          final artUri = await ArtworkExtractor.getArtUriFromPath(song.path);
                          
                          final newItem = MediaItem(
                            id: song.id.toString(),
                            title: song.title ?? "Unknown Track",
                            artist: song.artist ?? "Unknown Artist",
                            duration: Duration(milliseconds: song.durationMs ?? 0),
                            artUri: artUri,
                            extras: {'path': song.path}, 
                          );

                          final queue = List<MediaItem>.from(audioHandler.queue.value);
                          int targetIndex = queue.indexWhere((item) => item.id == newItem.id);

                          if (targetIndex != -1) {
                            queue[targetIndex] = newItem;
                            await audioHandler.updateQueue(queue);
                          } else {
                            queue.add(newItem);
                            await audioHandler.updateQueue(queue);
                            targetIndex = queue.length - 1;
                          }

                          await audioHandler.skipToQueueItem(targetIndex);
                          await audioHandler.play();
                        },
                      );
                    },
                    childCount: songs.length,
                  ),
                );
              },
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOOD MORNING',
                  style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.5),
                ),
                SizedBox(height: 4),
                Text(
                  'Library',
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            CircleAvatar(
              backgroundColor: Colors.white12,
              child: const Text('B', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFilterChips(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(libraryFilterProvider);
    final languages = ['All Tracks', 'Hindi', 'Kannada', 'Tamil', 'Telugu', 'English'];

    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: languages.map((lang) {
            final isActive = activeFilter == lang;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  ref.read(libraryFilterProvider.notifier).state = lang;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF6366F1) : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? const Color(0xFF6366F1) : Colors.white24,
                    ),
                  ),
                  child: Text(
                    lang,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildDynamicSectionTitle(WidgetRef ref) {
    final activeFilter = ref.watch(libraryFilterProvider);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          activeFilter == 'All Tracks' ? 'Recently added' : activeFilter,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionTitle(String title, String actionText) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (actionText.isNotEmpty)
              Text(
                actionText,
                style: const TextStyle(color: Color(0xFF6366F1), fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  // 🎯 CONNECTED TO SQLITE PLAY HISTORY
  SliverToBoxAdapter _buildJumpBackInList(WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return SliverToBoxAdapter(
      child: StreamBuilder<List<Song>>(
        stream: database.historyDao.watchRecentlyPlayed(limit: 10),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(height: 190, child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))));
          }
          final recentSongs = snapshot.data ?? [];
          
          if (recentSongs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text("Play some music to start your history!", style: TextStyle(color: Colors.white54)),
            );
          }

          return SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: recentSongs.length,
              itemBuilder: (context, index) {
                final song = recentSongs[index];
                return _LibraryRecentCard(song: song, ref: ref);
              },
            ),
          );
        },
      ),
    );
  }

  // 🎯 CONNECTED TO AI SMART MIXES
  SliverToBoxAdapter _buildMadeForYouList(WidgetRef ref) {
    final mixesAsync = ref.watch(autoMixProvider);

    return SliverToBoxAdapter(
      child: mixesAsync.when(
        loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))),
        error: (err, stack) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error generating mixes: $err', style: const TextStyle(color: Colors.white54)),
        ),
        data: (mixes) {
          if (mixes.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text("Tag more songs to generate custom AI mixes!", style: TextStyle(color: Colors.white54)),
            );
          }

          return SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mixes.length,
              itemBuilder: (context, index) {
                return _LibrarySmartMixCard(mix: mixes[index]);
              },
            ),
          );
        }
      ),
    );
  }
}

// ─── NEW CONNECTED UI COMPONENTS ───

class _LibraryRecentCard extends StatelessWidget {
  final Song song;
  final WidgetRef ref;

  const _LibraryRecentCard({required this.song, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final handler = ref.read(audioHandlerProvider);
        final artUri = await ArtworkExtractor.getArtUriFromPath(song.path);
        
        await handler.playMediaItem(MediaItem(
          id: song.id.toString(), 
          title: song.title ?? 'Unknown Track', 
          artist: song.artist ?? 'Unknown Artist',
          duration: Duration(milliseconds: song.durationMs ?? 0), 
          artUri: artUri, 
          extras: {'path': song.path},
        ));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.music_note_rounded, color: Colors.white24, size: 48),
            ),
            const SizedBox(height: 8),
            Text(
              song.title ?? 'Unknown Track',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist ?? 'Unknown Artist',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LibrarySmartMixCard extends ConsumerWidget {
  final SmartMix mix;

  const _LibrarySmartMixCard({required this.mix});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = [Color(mix.gradientColors[0]), Color(mix.gradientColors[1])];

    return GestureDetector(
      onTap: () async {
        final handler = ref.read(audioHandlerProvider);
        
        final items = mix.tracks.map((s) => MediaItem(
          id: s.id.toString(),
          title: s.title ?? 'Unknown Track',
          artist: s.artist ?? 'Unknown Artist',
          album: s.album,
          duration: Duration(milliseconds: s.durationMs ?? 0),
          extras: {'path': s.path},
        )).toList();

        await handler.updateQueue(items);
        await handler.setShuffleMode(AudioServiceShuffleMode.none);
        await handler.skipToQueueItem(0);
        await handler.play();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing ${mix.title}...'), 
              backgroundColor: gradient[0],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              mix.subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              mix.title,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}