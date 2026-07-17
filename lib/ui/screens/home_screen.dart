// ============================================================
//  SONIQ — lib/ui/screens/home_screen.dart
// ============================================================

import 'dart:io'; 
import 'package:soniq/classifier/language_service.dart';
import 'package:soniq/providers/auto_mix_provider.dart';
import 'package:soniq/providers/library_filter_provider.dart';
import 'package:soniq/ui/widgets/add_to_playlist_sheet.dart';
import 'package:soniq/ui/widgets/manual_tag_sheet.dart';
import 'package:soniq/ui/widgets/fallback_album_art.dart'; // 🎯 FIXED: Imported the new 3D fallback widget!
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
    final colorScheme = Theme.of(context).colorScheme;
    final controller = TextEditingController(text: _userName == "User" ? "" : _userName);
    
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Welcome to Soniq", style: TextStyle(color: colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: colorScheme.onSurface),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "What is your name?",
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.38)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.24))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorScheme.primary)),
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
            child: Text("SAVE", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        child: Icon(Icons.sync_rounded, color: colorScheme.onPrimary),
        onPressed: () async {
          debugPrint("Triggering AI Classification Pass...");
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('🤖 AI is scanning tracks...'), backgroundColor: colorScheme.primary),
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
                          style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoadingName ? '...' : _userName,
                          style: TextStyle(color: colorScheme.onBackground, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _showNamePromptDialog,
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: colorScheme.surface,
                        child: Text(
                          _isLoadingName ? '' : _userName[0].toUpperCase(), 
                          style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)
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
                    return Center(child: CircularProgressIndicator(color: colorScheme.primary));
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
                    loading: () => SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: colorScheme.primary))),
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
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(value: trackCount.toString(), label: 'TRACKS'),
                          Container(width: 1, height: 40, color: colorScheme.onSurface.withOpacity(0.1)),
                          _StatItem(value: albumCount.toString(), label: 'ALBUMS'),
                          Container(width: 1, height: 40, color: colorScheme.onSurface.withOpacity(0.1)),
                          _StatItem(value: artistCount.toString(), label: 'ARTISTS'),
                          Container(width: 1, height: 40, color: colorScheme.onSurface.withOpacity(0.1)),
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
              _buildFilteredLibrary(context, ref),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool hasViewAll = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: colorScheme.onBackground, fontSize: 20, fontWeight: FontWeight.bold)),
          if (hasViewAll)
            Text('See all', style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(message, style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54), fontSize: 16)),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeFilter = ref.watch(libraryFilterProvider);
    final languages = ['All Tracks', 'Hindi', 'Kannada', 'Tamil', 'Telugu', 'Malayalam', 'English', 'Unclassified'];

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
                  color: isActive ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1)),
                ),
                child: Text(
                  lang,
                  style: TextStyle(
                    color: isActive ? colorScheme.onPrimary : colorScheme.onSurface.withOpacity(0.7),
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
    final colorScheme = Theme.of(context).colorScheme;
    final activeFilter = ref.watch(libraryFilterProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Text(
        activeFilter == 'All Tracks' ? 'All Library Tracks' : activeFilter,
        style: TextStyle(color: colorScheme.onBackground, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFilteredLibrary(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredSongsAsync = ref.watch(filteredSongsProvider);

    return filteredSongsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(32),
        child: Text('Error loading tracks.', style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54))),
      ),
      data: (filteredSongs) {
        if (filteredSongs.isEmpty) return _buildEmptyState("No tracks found for this filter.");

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredSongs.length,
          itemExtent: 72.0,   
          cacheExtent: 500.0, 
          itemBuilder: (context, index) => _RecentVerticalTile(song: filteredSongs[index], ref: ref),
        );
      },
    );
  }
} 

// ─── Sub-widgets ─────────────────

class _AlbumArtWidget extends StatelessWidget {
  final Song song;
  final double size;
  final double borderRadius;
  final double iconSize;

  // 🎯 OPTIMIZED: Synchronous RAM cache. Kills the FutureBuilder rebuild loop.
  static final Map<String, Uri> _uriCache = {};
  static final Set<String> _noArtCache = {};

  const _AlbumArtWidget({
    required this.song,
    required this.size,
    this.borderRadius = 8.0,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Instant Cache Hit (Fast Path)
    if (_uriCache.containsKey(song.path)) {
      return RepaintBoundary(child: _buildImage(_uriCache[song.path]!));
    }
    
    // 2. Known Missing Art (Fast Path)
    // 🎯 FIXED: Replaced the old manual placeholder with the universal FallbackAlbumArt
    if (_noArtCache.contains(song.path)) {
      return RepaintBoundary(
        child: FallbackAlbumArt(width: size, height: size, borderRadius: borderRadius),
      );
    }

    // 3. First Time Load (Async Path)
    return RepaintBoundary( 
      child: FutureBuilder<Uri?>(
        future: ArtworkExtractor.getArtUriFromPath(song.path),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data != null) {
              _uriCache[song.path] = snapshot.data!; 
              return _buildImage(snapshot.data!);
            } else {
              _noArtCache.add(song.path); 
              // 🎯 FIXED: Connected async failure to universal fallback
              return FallbackAlbumArt(width: size, height: size, borderRadius: borderRadius);
            }
          }
          // Show fallback while loading to prevent size jumping
          return FallbackAlbumArt(width: size, height: size, borderRadius: borderRadius); 
        },
      ),
    );
  }

  Widget _buildImage(Uri uri) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        File(uri.toFilePath()),
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * 2).toInt(), 
        // 🎯 FIXED: Image.file errors are also caught and routed to the FallbackAlbumArt
        errorBuilder: (context, error, stackTrace) => FallbackAlbumArt(width: size, height: size, borderRadius: borderRadius),
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
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.onSurface.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600), maxLines: 2),
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
    final colorScheme = Theme.of(context).colorScheme;

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
            _AlbumArtWidget(song: song, size: 140, borderRadius: 12, iconSize: 48),
            const SizedBox(height: 12),
            Text(song.title ?? 'Unknown Track', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colorScheme.onBackground, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(song.artist ?? 'Unknown Artist', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54), fontSize: 13)),
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
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _AlbumArtWidget(song: song, size: 54, borderRadius: 8, iconSize: 24),
      title: Text(song.title ?? 'Unknown Track', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colorScheme.onBackground, fontSize: 15, fontWeight: FontWeight.w600)),
      subtitle: Text(song.artist ?? 'Unknown Artist', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54), fontSize: 13)),
      
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
          if ((song.languageTag != null && song.languageTag!.isNotEmpty) || (song.genre != null && song.genre!.isNotEmpty))
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
              ),
              child: Text(
                (song.languageTag?.isNotEmpty == true ? song.languageTag! : song.genre!).toUpperCase(), 
                style: TextStyle(color: colorScheme.primary, fontSize: 9, fontWeight: FontWeight.bold)
              ),
            ),
          
          StreamBuilder<bool>(
            stream: db.playlistsDao.watchIsFavorite(song.id),
            builder: (context, snapshot) {
              final isFavorite = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.38),
                  size: 20,
                ),
                onPressed: () => db.playlistsDao.toggleFavorite(song.id),
              );
            },
          ),
          const SizedBox(width: 8),
          Text('$minutes:$seconds', style: TextStyle(color: colorScheme.onBackground.withOpacity(0.38), fontSize: 13)),
          
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onBackground.withOpacity(0.38), size: 20),
            color: colorScheme.surface,
            onSelected: (value) {
              if (value == 'add_to_playlist') AddToPlaylistSheet.show(context, song.id);
              if (value == 'edit_tag') Future.delayed(const Duration(milliseconds: 50), () => ManualTagSheet.show(context, song));
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'add_to_playlist', child: Row(children: [Icon(Icons.playlist_add, size: 20, color: colorScheme.onSurface), const SizedBox(width: 12), Text('Add to Playlist', style: TextStyle(color: colorScheme.onSurface))])),
              PopupMenuItem<String>(value: 'edit_tag', child: Row(children: [Icon(Icons.label_outline, size: 20, color: colorScheme.onSurface), const SizedBox(width: 12), Text('Edit Language Tag', style: TextStyle(color: colorScheme.onSurface))])),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(value, style: TextStyle(color: colorScheme.onBackground, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: colorScheme.onBackground.withOpacity(0.4), fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class RecentlyAddedScreen extends ConsumerWidget {
  const RecentlyAddedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        title: Text('Recently Added', style: TextStyle(color: colorScheme.onBackground, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<Song>>(
        stream: database.songsDao.watchAllAvailable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: colorScheme.primary));
          
          final songs = List<Song>.from(snapshot.data ?? []);
          if (songs.isEmpty) return Center(child: Text("No songs found.", style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54))));

          songs.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
          final recentSongs = songs.take(100).toList(); 

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 120, top: 16),
            itemCount: recentSongs.length,
            itemExtent: 72.0,   
            cacheExtent: 500.0, 
            itemBuilder: (context, index) => _RecentVerticalTile(song: recentSongs[index], ref: ref),
          );
        },
      ),
    );
  }
}