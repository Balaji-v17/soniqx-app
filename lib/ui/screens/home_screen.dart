import 'dart:io'; // 🎯 ADDED: Required for rendering Image.file
import 'package:soniq/classifier/language_service.dart';
import 'package:soniq/providers/auto_mix_provider.dart';
import 'package:soniq/providers/library_filter_provider.dart';
import 'package:soniq/ui/widgets/add_to_playlist_sheet.dart';
import 'package:soniq/ui/widgets/manual_tag_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:drift/drift.dart' as drift;

import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/audio/artwork_extractor.dart';
import 'package:soniq/ui/screens/playlist_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soniq/audio/shuffle_engine.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _userName = "User";
  bool _isLoadingName = true;
  
  @override
  void initState() {
    super.initState();
    _loadUserName();
    Future.microtask(() {
      ref.read(languageServiceProvider).runWeeklyMaintenance();
    });
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('userName');
    
    if (name == null || name.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNamePromptDialog();
      });
    } else {
      setState(() {
        _userName = name;
        _isLoadingName = false;
      });
    }
  }

  void _showNamePromptDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final controller = TextEditingController(text: _userName == "User" ? "" : _userName);
    
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Welcome to Soniq", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: "What is your name?",
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF6366F1))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final input = controller.text.trim();
              final finalName = input.isNotEmpty ? input : "Music Lover";
              
              await prefs.setString('userName', finalName);
              setState(() {
                _userName = finalName;
                _isLoadingName = false;
              });
              
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("SAVE", style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);
    final filteredSongsAsync = ref.watch(filteredLibraryProvider); 

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.sync_rounded, color: Colors.white),
        onPressed: () async {
          debugPrint("Triggering AI Classification Pass...");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🤖 AI is scanning tracks...'), backgroundColor: Color(0xFF6366F1)),
            );
          }

          await ref.read(languageServiceProvider).runClassificationPass();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✨ AI Tagging Complete!'), backgroundColor: Colors.green),
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getGreeting(),
                          style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoadingName ? '...' : _userName,
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showNamePromptDialog,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF1E1E1E),
                        child: Text(
                          _isLoadingName ? '' : _userName[0].toUpperCase(), 
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.favorite_border_rounded, 
                            label: 'Liked',
                            onTap: () async {
                              final db = ref.read(databaseProvider);
                              final playlist = await (db.select(db.playlists)..where((p) => p.id.equals(1))).getSingleOrNull();
                              if (playlist != null && context.mounted) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PlaylistDetailScreen(playlist: playlist),
                                ));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.access_time_rounded, 
                            label: 'Recently Added',
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const RecentlyAddedScreen(),
                            )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.local_fire_department_outlined, 
                            label: 'Most Played',
                            onTap: () async {
                              final db = ref.read(databaseProvider);
                              final playlist = await (db.select(db.playlists)..where((p) => p.id.equals(3))).getSingleOrNull();
                              if (playlist != null && context.mounted) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PlaylistDetailScreen(playlist: playlist),
                                ));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.shuffle_rounded, 
                            label: 'Shuffle All',
                            onTap: () async {
                              final db = ref.read(databaseProvider);
                              final handler = ref.read(audioHandlerProvider);
                              
                              final songs = await db.songsDao.watchAllAvailable().first;
                              if (songs.isEmpty) return;

                              final recentHistory = await db.historyDao.watchRecentlyPlayed(limit: 50).first;
                              final recentIds = recentHistory.map((s) => s.id).toSet();

                              final shuffleEngine = SoniqShuffleEngine();
                              final shuffleResult = shuffleEngine.generateQueue(
                                songs,
                                recentlyPlayedIds: recentIds, 
                              );
                              
                              debugPrint('Smart Shuffle Stats: ${shuffleResult.stats.toString()}');

                              final items = await Future.wait(shuffleResult.queue.map((s) async {
                                final artUri = await ArtworkExtractor.getArtUriFromPath(s.path);
                                return MediaItem(
                                  id: s.id.toString(),
                                  title: s.title ?? 'Unknown Track',
                                  artist: s.artist ?? 'Unknown Artist',
                                  duration: Duration(milliseconds: s.durationMs ?? 0),
                                  artUri: artUri,
                                  extras: {'path': s.path},
                                );
                              }));

                              await handler.updateQueue(items);
                              await handler.setShuffleMode(AudioServiceShuffleMode.all);
                              await handler.skipToQueueItem(0);
                              await handler.play();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildSectionTitle('Jump back in', hasViewAll: true),
              StreamBuilder<List<Song>>(
                stream: database.historyDao.watchRecentlyPlayed(limit: 10),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))));
                  }
                  final recentSongs = snapshot.data ?? [];
                  if (recentSongs.isEmpty) return _buildEmptyState("Play some music to start your history!");

                  return SizedBox(
                    height: 220, 
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: recentSongs.length,
                      itemBuilder: (context, index) => _JumpBackInCard(song: recentSongs[index], ref: ref),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              _buildSectionTitle('Made for you'),
              Consumer(
                builder: (context, ref, child) {
                  final mixesAsync = ref.watch(autoMixProvider);
                  
                  return mixesAsync.when(
                    loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))),
                    error: (err, stack) => _buildEmptyState("Error generating mixes."),
                    data: (mixes) {
                      if (mixes.isEmpty) return _buildEmptyState("Tag more songs to generate custom mixes!");

                      return SizedBox(
                        height: 200,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: mixes.length,
                          itemBuilder: (context, index) => _SmartMixCard(mix: mixes[index]),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              StreamBuilder<List<Song>>(
                stream: database.songsDao.watchAllAvailable(), 
                builder: (context, snapshot) {
                  final songs = snapshot.data ?? [];
                  
                  final trackCount = songs.length;
                  final albumCount = songs.map((s) => s.album?.trim()).where((a) => a != null && a.isNotEmpty).toSet().length;
                  final artistCount = songs.map((s) => s.artist?.trim()).where((a) => a != null && a.isNotEmpty).toSet().length;
                  final totalDurationMs = songs.fold<int>(0, (sum, s) => sum + (s.durationMs ?? 0));
                  final hours = (totalDurationMs / (1000 * 60 * 60)).round();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(value: trackCount.toString(), label: 'TRACKS'),
                          Container(width: 1, height: 40, color: Colors.white10),
                          _StatItem(value: albumCount.toString(), label: 'ALBUMS'),
                          Container(width: 1, height: 40, color: Colors.white10),
                          _StatItem(value: artistCount.toString(), label: 'ARTISTS'),
                          Container(width: 1, height: 40, color: Colors.white10),
                          _StatItem(value: hours.toString(), label: 'HOURS'),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              _buildFilterChips(context, ref),
              _buildDynamicSectionTitle(ref),
              _buildFilteredLibrary(filteredSongsAsync, ref),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool hasViewAll = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          if (hasViewAll)
            const Text('See all', style: TextStyle(color: Color(0xFF6366F1), fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(message, style: const TextStyle(color: Colors.white54, fontSize: 16)),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(libraryFilterProvider);
    final languages = ['All Tracks', 'Hindi', 'Kannada', 'Tamil', 'Telugu', 'Malayalam', 'English'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), 
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: languages.map((lang) {
          final isActive = activeFilter == lang;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => ref.read(libraryFilterProvider.notifier).state = lang,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF6366F1) : const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? const Color(0xFF6366F1) : Colors.white24),
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
    );
  }

  Widget _buildDynamicSectionTitle(WidgetRef ref) {
    final activeFilter = ref.watch(libraryFilterProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        activeFilter == 'All Tracks' ? 'All Library Tracks' : activeFilter,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFilteredLibrary(AsyncValue<List<Song>> asyncSongs, WidgetRef ref) {
    return asyncSongs.when(
      loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))),
      error: (err, stack) => Padding(padding: const EdgeInsets.all(32), child: Text('Error: $err', style: const TextStyle(color: Colors.white54))),
      data: (songs) {
        if (songs.isEmpty) return _buildEmptyState("No tracks found for this filter.");
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: songs.length,
          itemBuilder: (context, index) => _RecentVerticalTile(song: songs[index], ref: ref),
        );
      }
    );
  }
}

// 🎯 ADDED: Smart widget to display Album Art with a vibrant color fallback
class _AlbumArtWidget extends StatelessWidget {
  final Song song;
  final double size;
  final double borderRadius;
  final double iconSize;

  const _AlbumArtWidget({
    required this.song,
    required this.size,
    this.borderRadius = 8.0,
    this.iconSize = 24.0,
  });

  // Generates a vibrant, consistent color based on the song's title
  Color _getFallbackColor(String title) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEF4444), // Red
    ];
    final index = title.codeUnits.fold<int>(0, (a, b) => a + b) % colors.length;
    return colors[index].withOpacity(0.3);
  }

  @override
  Widget build(BuildContext context) {
    final fallbackColor = _getFallbackColor(song.title ?? 'Unknown');

    return FutureBuilder<Uri?>(
      future: ArtworkExtractor.getArtUriFromPath(song.path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Image.file(
              File(snapshot.data!.toFilePath()),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallback(fallbackColor),
            ),
          );
        }
        return _buildFallback(fallbackColor);
      },
    );
  }

  Widget _buildFallback(Color bgColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white.withOpacity(0.7), size: iconSize),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickActionCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600), maxLines: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _JumpBackInCard extends StatelessWidget {
  final Song song;
  final WidgetRef ref;

  const _JumpBackInCard({required this.song, required this.ref});

  @override
  Widget build(BuildContext context) {
    final db = ref.read(databaseProvider);

    return GestureDetector(
      onTap: () async {
        final handler = ref.read(audioHandlerProvider);
        try {
          final now = DateTime.now();
          await db.into(db.playHistory).insert(
            PlayHistoryCompanion(
              songId: drift.Value(song.id),
              playedAt: drift.Value(now),
              listenedMs: drift.Value(song.durationMs ?? 180000),
              counted: const drift.Value(true),
              skippedEarly: const drift.Value(false),
            )
          );
        } catch (e) { debugPrint('Tracking failed: $e'); }

        final artUri = await ArtworkExtractor.getArtUriFromPath(song.path);
        await handler.playMediaItem(MediaItem(
          id: song.id.toString(), title: song.title ?? 'Unknown', artist: song.artist ?? 'Unknown',
          duration: Duration(milliseconds: song.durationMs ?? 0), artUri: artUri, extras: {'path': song.path},
        ));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎯 FIXED: Updated to use the smart AlbumArtWidget
            _AlbumArtWidget(song: song, size: 140, borderRadius: 12, iconSize: 48),
            const SizedBox(height: 12),
            Text(song.title ?? 'Unknown Track', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(song.artist ?? 'Unknown Artist', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _SmartMixCard extends ConsumerWidget {
  final SmartMix mix;

  const _SmartMixCard({required this.mix});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = [Color(mix.gradientColors[0]), Color(mix.gradientColors[1])];

    return GestureDetector(
      onTap: () async {
        final handler = ref.read(audioHandlerProvider);
        
        final items = await Future.wait(mix.tracks.map((s) async {
          final artUri = await ArtworkExtractor.getArtUriFromPath(s.path);
          return MediaItem(
            id: s.id.toString(),
            title: s.title ?? 'Unknown',
            artist: s.artist ?? 'Unknown',
            duration: Duration(milliseconds: s.durationMs ?? 0),
            artUri: artUri,
            extras: {'path': s.path},
          );
        }));

        await handler.updateQueue(items);
        await handler.setShuffleMode(AudioServiceShuffleMode.none);
        await handler.skipToQueueItem(0);
        await handler.play();
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(mix.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text(mix.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _RecentVerticalTile extends StatelessWidget {
  final Song song;
  final WidgetRef ref;

  const _RecentVerticalTile({required this.song, required this.ref});

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: song.durationMs ?? 0);
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final db = ref.read(databaseProvider);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      // 🎯 FIXED: Updated to use the smart AlbumArtWidget
      leading: _AlbumArtWidget(song: song, size: 54, borderRadius: 8, iconSize: 24),
      title: Text(song.title ?? 'Unknown Track', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(song.artist ?? 'Unknown Artist', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54, fontSize: 13)),
      
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

      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (song.genre != null && song.genre!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.5)),
              ),
              child: Text(
                song.genre!.toUpperCase(), 
                style: const TextStyle(color: Color(0xFF6366F1), fontSize: 9, fontWeight: FontWeight.bold)
              ),
            ),
          
          StreamBuilder<bool>(
            stream: db.playlistsDao.watchIsFavorite(song.id),
            builder: (context, snapshot) {
              final isFavorite = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? const Color(0xFF6366F1) : Colors.white38,
                  size: 20,
                ),
                onPressed: () => db.playlistsDao.toggleFavorite(song.id),
              );
            },
          ),
          const SizedBox(width: 8),
          Text('$minutes:$seconds', style: const TextStyle(color: Colors.white38, fontSize: 13)),
          
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white38, size: 20),
            color: const Color(0xFF2A2A2A),
            onSelected: (value) {
              if (value == 'add_to_playlist') AddToPlaylistSheet.show(context, song.id);
              if (value == 'edit_tag') Future.delayed(const Duration(milliseconds: 50), () => ManualTagSheet.show(context, song));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'add_to_playlist', child: Row(children: [Icon(Icons.playlist_add, size: 20, color: Colors.white70), SizedBox(width: 12), Text('Add to Playlist', style: TextStyle(color: Colors.white))])),
              const PopupMenuItem<String>(value: 'edit_tag', child: Row(children: [Icon(Icons.label_outline, size: 20, color: Colors.white70), SizedBox(width: 12), Text('Edit Language Tag', style: TextStyle(color: Colors.white))])),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class RecentlyAddedScreen extends ConsumerWidget {
  const RecentlyAddedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Recently Added', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Song>>(
        stream: database.songsDao.watchAllAvailable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          
          final songs = List<Song>.from(snapshot.data ?? []);
          if (songs.isEmpty) return const Center(child: Text("No songs found.", style: TextStyle(color: Colors.white54)));

          songs.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
          final recentSongs = songs.take(100).toList(); 

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 120, top: 16),
            itemCount: recentSongs.length,
            itemBuilder: (context, index) => _RecentVerticalTile(song: recentSongs[index], ref: ref),
          );
        },
      ),
    );
  }
}