// ============================================================
//  SONIQ — lib/ui/screens/home_screen.dart
// ============================================================

import 'dart:io';
import 'package:soniq/ui/widgets/mini_waveform.dart';
import 'package:soniq/utils/time_utils.dart';
import 'package:soniq/ui/screens/browse_screens.dart'; 
import 'package:soniq/ui/widgets/skeleton_loaders.dart';
import 'package:just_audio/just_audio.dart'; 
import 'package:flutter/services.dart'; 
import 'package:soniq/classifier/language_service.dart';
import 'package:soniq/providers/auto_mix_provider.dart';
import 'package:soniq/providers/library_filter_provider.dart';
import 'package:soniq/ui/widgets/add_to_playlist_sheet.dart';
import 'package:soniq/ui/widgets/manual_tag_sheet.dart';
import 'package:soniq/ui/widgets/fallback_album_art.dart';
import 'package:soniq/ui/widgets/alphabet_scrubber.dart';
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
import 'package:soniq/audio/music_scanner.dart';

// 🎯 CACHED STREAM PROVIDERS 
final recentlyPlayedProvider = StreamProvider.autoDispose((ref) {
  final db = ref.watch(databaseProvider);
  return db.historyDao.watchRecentlyPlayed(limit: 10);
});

final historyFullProvider = StreamProvider.autoDispose((ref) {
  final db = ref.watch(databaseProvider);
  return db.historyDao.watchRecentlyPlayed(limit: 100);
});

final libraryStatsProvider = StreamProvider.autoDispose((ref) {
  final db = ref.watch(databaseProvider);
  return db.songsDao.watchLibraryStats();
});

final availableSongsProvider = StreamProvider.autoDispose((ref) {
  final db = ref.watch(databaseProvider);
  return db.songsDao.watchAllAvailable();
});

final isFavoriteProvider = StreamProvider.family.autoDispose<bool, int>((ref, songId) {
  final db = ref.watch(databaseProvider);
  return db.playlistsDao.watchIsFavorite(songId);
});

Future<List<MediaItem>> _buildMediaItems(List<Song> songs, {int activeIndex = 0}) async {
  if (songs.isEmpty) return [];

  final safeIndex = (activeIndex >= 0 && activeIndex < songs.length) ? activeIndex : 0;
  final activeSong = songs[safeIndex];
  
  final activeArtUri = await ArtworkExtractor.getArtUriFromPath(activeSong.path);

  return songs.map((s) {
    final isActive = s.id == activeSong.id;
    return MediaItem(
      id: s.id.toString(),
      title: s.title ?? 'Unknown Track',
      artist: s.artist ?? 'Unknown Artist',
      album: s.album ?? 'Unknown Album',
      duration: Duration(milliseconds: s.durationMs ?? 0),
      artUri: isActive ? activeArtUri : null,
      extras: {'path': s.path},
    );
  }).toList();
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _userName = "User";
  bool _isLoadingName = true;
  
  bool _isSelectionMode = false;
  final Set<int> _selectedSongIds = {};

  final _HeaderOffsetScrollController _scrollController = _HeaderOffsetScrollController();
  int _currentTrackCount = 0;
  
  // 🎯 FIXED: Local state cache to prevent list shrinkage during Riverpod updates
  List<Song> _cachedSongs = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    
    _scrollController.getListLength = () => _currentTrackCount;

    Future.microtask(() async {
      ref.read(languageServiceProvider).runWeeklyMaintenance();
      _healSeededTracks();
      try { await ref.read(languageServiceProvider).runClassificationPass(); } catch (_) {}
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _healSeededTracks() async {
    final db = ref.read(databaseProvider);
    try {
      final brokenSongs = await (db.select(db.songs)
        ..where((s) => s.durationMs.isNull() | s.durationMs.equals(0))).get();

      if (brokenSongs.isEmpty) return;

      final player = AudioPlayer();
      final List<SongsCompanion> updates = [];

      for (final song in brokenSongs) {
        if (!mounted) break;
        if (song.path.isNotEmpty && File(song.path).existsSync()) {
          try {
            final duration = await player.setFilePath(song.path).timeout(const Duration(milliseconds: 800));
            if (duration != null && duration.inMilliseconds > 0) {
              updates.add(SongsCompanion(
                id: drift.Value(song.id),
                durationMs: drift.Value(duration.inMilliseconds),
              ));
            }
          } catch (_) {}
        }
      }

      await player.dispose();

      if (updates.isNotEmpty && mounted) {
        await db.batch((batch) {
          for (final u in updates) {
            batch.update(db.songs, u, where: (t) => t.id.equals(u.id.value));
          }
        });
      }
    } catch (_) {}
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

  void _toggleSelection(int songId) {
    setState(() {
      if (_selectedSongIds.contains(songId)) {
        _selectedSongIds.remove(songId);
        if (_selectedSongIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedSongIds.add(songId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedSongIds.clear();
    });
  }

  void _showLanguageTagDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final List<String> availableLanguages = ['Hindi', 'Kannada', 'Tamil', 'Telugu', 'Malayalam', 'English'];

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tag ${_selectedSongIds.length} tracks as:',
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: availableLanguages.map((lang) {
                    return ActionChip(
                      backgroundColor: colorScheme.onSurface.withOpacity(0.05),
                      label: Text(lang, style: TextStyle(color: colorScheme.primary)),
                      onPressed: () async {
                        final db = ref.read(databaseProvider);
                        for (final id in _selectedSongIds) {
                          await (db.update(db.songs)..where((t) => t.id.equals(id))).write(
                            SongsCompanion(languageTag: drift.Value(lang)),
                          );
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Updated language to $lang'), backgroundColor: Colors.green),
                          );
                          _exitSelectionMode();
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteTracks() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('Delete ${_selectedSongIds.length} tracks?', style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          'This action will permanently remove these tracks from your library.',
          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: colorScheme.primary)),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              for (final id in _selectedSongIds) {
                await (db.delete(db.songs)..where((t) => t.id.equals(id))).go();
              }
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selected tracks removed.'), backgroundColor: Colors.redAccent),
                );
                _exitSelectionMode();
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scanState = ref.watch(scanProvider);
    final isSortingAZ = ref.watch(sortOrderProvider) == SortOrder.aToZ;

    // 🎯 FIXED: Populate the cache at the very top of the build lifecycle.
    // If the StreamProvider emits a state transition, the local state retains the previous list.
    final filteredSongsAsync = ref.watch(filteredSongsProvider);
    if (filteredSongsAsync.hasValue) {
      _cachedSongs = filteredSongsAsync.value!;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: colorScheme.surface,
              leading: IconButton(
                icon: Icon(Icons.close, color: colorScheme.onSurface),
                onPressed: _exitSelectionMode,
              ),
              title: Text('${_selectedSongIds.length} Selected', style: TextStyle(color: colorScheme.onSurface)),
              actions: [
                IconButton(
                  icon: Icon(Icons.label_outline, color: colorScheme.primary),
                  tooltip: 'Tag Language',
                  onPressed: _showLanguageTagDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  tooltip: 'Delete Selected',
                  onPressed: _confirmDeleteTracks,
                ),
              ],
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController, 
              key: const PageStorageKey('home_main_scroll_key'),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
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
                ),

                SliverToBoxAdapter(
                  child: Padding(
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
                                  final playlist = await (database.select(database.playlists)..where((p) => p.id.equals(1))).getSingleOrNull();
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
                                  final playlist = await (database.select(database.playlists)..where((p) => p.id.equals(3))).getSingleOrNull();
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
                                  final handler = ref.read(audioHandlerProvider);
                                  final songs = await database.songsDao.watchAllAvailable().first;
                                  if (songs.isEmpty) return;

                                  final recentHistory = await database.historyDao.watchRecentlyPlayed(limit: 50).first;
                                  final recentIds = recentHistory.map((s) => s.id).toSet();

                                  final shuffleEngine = SoniqShuffleEngine();
                                  final shuffleResult = shuffleEngine.generateQueue(songs, recentlyPlayedIds: recentIds);
                                  
                                  if (shuffleResult.queue.isNotEmpty) {
                                    await _recordPlayHistory(context, database, shuffleResult.queue.first);
                                  }

                                  final items = await _buildMediaItems(shuffleResult.queue, activeIndex: 0);

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
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                SliverToBoxAdapter(
                  child: _buildSectionTitle(
                    'Jump back in', 
                    hasViewAll: true,
                    onViewAll: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PlayHistoryScreen(),
                    )),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final recentAsync = ref.watch(recentlyPlayedProvider);
                      return recentAsync.when(
                        loading: () => SkeletonPulse(
                          child: SizedBox(
                            height: 220,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: 4,
                              itemBuilder: (context, index) => Container(
                                width: 140,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: 140, height: 140, decoration: BoxDecoration(color: colorScheme.onBackground.withOpacity(0.1), borderRadius: BorderRadius.circular(12))),
                                    const SizedBox(height: 12),
                                    Container(width: 100, height: 14, decoration: BoxDecoration(color: colorScheme.onBackground.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
                                    const SizedBox(height: 8),
                                    Container(width: 60, height: 12, decoration: BoxDecoration(color: colorScheme.onBackground.withOpacity(0.1), borderRadius: BorderRadius.circular(4))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        error: (err, stack) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Text('Error loading history.', style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54))),
                        ),
                        data: (recentSongs) {
                          if (recentSongs.isEmpty) return _buildEmptyState("Play some music to start your history!");
                          return SizedBox(
                            height: 220, 
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              scrollDirection: Axis.horizontal,
                              itemCount: recentSongs.length,
                              itemBuilder: (context, index) => _JumpBackInCard(
                                key: ValueKey(recentSongs[index].id),
                                song: recentSongs[index], 
                                ref: ref
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                SliverToBoxAdapter(child: _buildSectionTitle('Made for you')),

                SliverToBoxAdapter(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final mixesAsync = ref.watch(autoMixProvider);
                      
                      return mixesAsync.when(
                        loading: () => SkeletonPulse(
                          child: SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (context, index) => Container(
                                width: 240,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: colorScheme.onBackground.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                        error: (err, stack) => _buildEmptyState("Error generating mixes."),
                        data: (mixes) {
                          if (mixes.isEmpty) return _buildEmptyState("Tag more songs to generate custom mixes!");

                          return SizedBox(
                            height: 200,
                            child: PageView.builder(
                              controller: PageController(viewportFraction: 0.85),
                              padEnds: false,
                              itemCount: mixes.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(left: 24.0, right: 8.0),
                                child: _SmartMixCard(
                                  key: ValueKey(mixes[index].title),
                                  mix: mixes[index]
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                SliverToBoxAdapter(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final statsAsync = ref.watch(libraryStatsProvider);
                      final stats = statsAsync.value ?? const LibraryStats();
                      final hours = (stats.totalDurationMs / (1000 * 60 * 60)).round();

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
                              _StatItem(value: stats.trackCount.toString(), label: 'TRACKS'),
                              Container(width: 1, height: 40, color: colorScheme.onSurface.withOpacity(0.1)),
                              _StatItem(
                                value: stats.albumCount.toString(), 
                                label: 'ALBUMS',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AlbumsScreen())),
                              ),
                              Container(width: 1, height: 40, color: colorScheme.onSurface.withOpacity(0.1)),
                              _StatItem(
                                value: stats.artistCount.toString(), 
                                label: 'ARTISTS',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArtistsScreen())),
                              ),
                              Container(width: 1, height: 40, color: colorScheme.onSurface.withOpacity(0.1)),
                              _StatItem(value: hours.toString(), label: 'HOURS'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 48)),

                SliverToBoxAdapter(child: _buildFilterChips(context, ref)),
                SliverToBoxAdapter(child: _buildDynamicSectionTitle(ref)),

                // 🎯 FIXED: Re-architected sliver layout to remove identity-destroying Consumer wrappers
                if (!scanState.isComplete && !scanState.isError)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              scanState.phase == ScanPhase.indexing 
                                ? "Indexing Library..." 
                                : "Processing Files...",
                              style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: scanState.total > 0 ? scanState.processed / scanState.total : null,
                              backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                              borderRadius: BorderRadius.circular(8),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "${scanState.processed} / ${scanState.total} Tracks",
                              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
                            ),
                            if (scanState.currentTitle != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                scanState.currentTitle!,
                                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5), fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  _buildFilteredLibrarySliver(context, filteredSongsAsync.isLoading),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            
            if (isSortingAZ && _cachedSongs.isNotEmpty)
              AnimatedBuilder(
                animation: _scrollController,
                builder: (context, child) {
                  double headerHeight = 1120.0;
                  if (_scrollController.hasClients && _currentTrackCount > 0) {
                    final pos = _scrollController.position;
                    final listHeight = _currentTrackCount * 72.0;
                    final totalContent = pos.maxScrollExtent + pos.viewportDimension;
                    final calc = totalContent - listHeight - 120.0;
                    if (calc > 0) headerHeight = calc;
                  }

                  final offset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                  double topPos = headerHeight - offset + 60.0;

                  if (topPos > MediaQuery.of(context).size.height - 150) {
                    return const SizedBox.shrink();
                  }

                  topPos = topPos.clamp(100.0, 9999.0);

                  return Positioned(
                    right: 2,
                    top: topPos,
                    bottom: 120,
                    child: child!,
                  );
                },
                child: AlphabetScrubber(
                  scrollController: _scrollController,
                  songs: _cachedSongs,
                  itemExtent: 72.0,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool hasViewAll = false, VoidCallback? onViewAll}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: colorScheme.onBackground, fontSize: 20, fontWeight: FontWeight.bold)),
          if (hasViewAll)
            GestureDetector(
              onTap: onViewAll,
              child: Text('See all', style: TextStyle(color: colorScheme.primary, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
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
              onTap: () {
                ref.read(libraryFilterProvider.notifier).state = lang;
                if (_isSelectionMode) _exitSelectionMode();
              },
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
    final currentSort = ref.watch(sortOrderProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            activeFilter == 'All Tracks' ? 'All Library Tracks' : activeFilter,
            style: TextStyle(color: colorScheme.onBackground, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          
          PopupMenuButton<SortOrder>(
            icon: Icon(Icons.sort_rounded, color: colorScheme.primary),
            color: colorScheme.surface,
            tooltip: 'Sort Tracks',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (SortOrder newSort) {
              ref.read(sortOrderProvider.notifier).state = newSort;
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOrder>>[
              _buildSortMenuItem(SortOrder.newestFirst, 'Newest First', Icons.schedule, currentSort, colorScheme),
              _buildSortMenuItem(SortOrder.oldestFirst, 'Oldest First', Icons.history, currentSort, colorScheme),
              const PopupMenuDivider(),
              _buildSortMenuItem(SortOrder.aToZ, 'Title (A-Z)', Icons.sort_by_alpha, currentSort, colorScheme),
              _buildSortMenuItem(SortOrder.zToA, 'Title (Z-A)', Icons.sort_by_alpha, currentSort, colorScheme),
              const PopupMenuDivider(),
              _buildSortMenuItem(SortOrder.artist, 'Artist', Icons.person_outline, currentSort, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<SortOrder> _buildSortMenuItem(SortOrder value, String label, IconData icon, SortOrder currentSort, ColorScheme colorScheme) {
    final isSelected = value == currentSort;
    return PopupMenuItem<SortOrder>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isSelected ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredLibrarySliver(BuildContext context, bool isLoading) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_cachedSongs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _currentTrackCount = _cachedSongs.length;
      });

      return SliverFixedExtentList(
        key: const Key('library_list_sliver_key'),
        itemExtent: 72.0,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final song = _cachedSongs[index];
            return _RecentVerticalTile(
              key: ValueKey(song.id), 
              song: song, 
              ref: ref,
              currentQueue: _cachedSongs,
              currentIndex: index,
              isSelectionMode: _isSelectionMode,
              isSelected: _selectedSongIds.contains(song.id),
              onTapOverride: _isSelectionMode ? () => _toggleSelection(song.id) : null,
              onLongPress: () {
                if (!_isSelectionMode) {
                  setState(() {
                    _isSelectionMode = true;
                    _selectedSongIds.add(song.id);
                  });
                }
              },
            );
          },
          childCount: _cachedSongs.length,
          // 🎯 FIXED: Anchors scroll position seamlessly tracking the exact visible items on screen!
          findChildIndexCallback: (Key key) {
            final ValueKey<int> valueKey = key as ValueKey<int>;
            final id = valueKey.value;
            final index = _cachedSongs.indexWhere((s) => s.id == id);
            return index >= 0 ? index : null;
          },
        ),
      );
    }

    if (isLoading) {
      return SliverFixedExtentList(
        itemExtent: 72.0,
        delegate: SliverChildBuilderDelegate(
          (context, index) => const SkeletonSongTile(),
          childCount: 8,
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text('No tracks found.', style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54))),
      ),
    );
  }
} 

// ─── Sub-widgets ─────────────────

class _AlbumArtWidget extends StatefulWidget {
  final Song song;
  final double size;
  final double borderRadius;
  final double iconSize;

  static final Map<String, Uri> _uriCache = {};
  static final Set<String> _noArtCache = {};

  const _AlbumArtWidget({
    required this.song,
    required this.size,
    this.borderRadius = 8.0,
    this.iconSize = 24.0,
  });

  @override
  State<_AlbumArtWidget> createState() => _AlbumArtWidgetState();
}

class _AlbumArtWidgetState extends State<_AlbumArtWidget> {
  Uri? _artUri;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (_AlbumArtWidget._uriCache.containsKey(widget.song.path)) {
      _artUri = _AlbumArtWidget._uriCache[widget.song.path];
      _loaded = true;
    } else if (_AlbumArtWidget._noArtCache.contains(widget.song.path)) {
      _loaded = true;
    } else {
      Future.delayed(const Duration(milliseconds: 80), _loadArtwork);
    }
  }

  Future<void> _loadArtwork() async {
    if (!mounted) return;
    try {
      final uri = await ArtworkExtractor.getArtUriFromPath(widget.song.path);
      if (mounted) {
        setState(() {
          if (uri != null) {
            _artUri = uri;
            _AlbumArtWidget._uriCache[widget.song.path] = uri;
          } else {
            _AlbumArtWidget._noArtCache.add(widget.song.path);
          }
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }

    if (_artUri != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.file(
          File(_artUri!.toFilePath()),
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          cacheWidth: (widget.size * 2).toInt(),
          errorBuilder: (context, error, stackTrace) => FallbackAlbumArt(width: widget.size, height: widget.size, borderRadius: widget.borderRadius),
        ),
      );
    }

    return FallbackAlbumArt(width: widget.size, height: widget.size, borderRadius: widget.borderRadius);
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
      onTap: () {
        HapticFeedback.lightImpact(); 
        if (onTap != null) onTap!();
      },
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

  const _JumpBackInCard({super.key, required this.song, required this.ref});

  @override
  Widget build(BuildContext context) {
    final db = ref.read(databaseProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact(); 
        
        final handler = ref.read(audioHandlerProvider);
        await _recordPlayHistory(context, db, song);

        final recentSongs = await db.historyDao.watchRecentlyPlayed(limit: 50).first;
        final startIndex = recentSongs.indexWhere((s) => s.id == song.id);
        
        final queueItems = await _buildMediaItems(recentSongs, activeIndex: startIndex);
        
        await handler.updateQueue(queueItems);
        await handler.setShuffleMode(AudioServiceShuffleMode.none);
        await handler.skipToQueueItem(startIndex >= 0 ? startIndex : 0);
        await handler.play();
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

  const _SmartMixCard({super.key, required this.mix});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = [Color(mix.gradientColors[0]), Color(mix.gradientColors[1])];

    return GestureDetector(
      onTap: () async {
        final handler = ref.read(audioHandlerProvider);
        final db = ref.read(databaseProvider);

        if (mix.tracks.isNotEmpty) {
          await _recordPlayHistory(context, db, mix.tracks.first);
        }

        final items = await _buildMediaItems(mix.tracks, activeIndex: 0);

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

class _RecentVerticalTile extends ConsumerWidget {
  final Song song;
  final WidgetRef ref;
  
  final List<Song> currentQueue; 
  final int currentIndex;
  
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onTapOverride;
  final VoidCallback? onLongPress;

  const _RecentVerticalTile({
    super.key,
    required this.song, 
    required this.ref,
    required this.currentQueue,
    required this.currentIndex,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onTapOverride,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final handler = ref.watch(audioHandlerProvider);

    return StreamBuilder<MediaItem?>(
      stream: handler.mediaItem,
      builder: (context, snapshot) {
        final currentItem = snapshot.data;
        final isCurrentlyPlaying = currentItem?.id == song.id.toString();

        return ListTile(
          tileColor: isCurrentlyPlaying ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          selected: isSelected,
          selectedTileColor: colorScheme.primary.withOpacity(0.15),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Stack(
            alignment: Alignment.center,
            children: [
              _AlbumArtWidget(song: song, size: 48, borderRadius: 6, iconSize: 24),
              if (isCurrentlyPlaying)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.black54,
                  ),
                  child: const Center(
                    child: MiniWaveform(
                      color: Colors.white,
                      isPlaying: true, 
                      size: 24.0,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            song.title ?? 'Unknown Track', 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis, 
            style: TextStyle(
              color: isCurrentlyPlaying ? colorScheme.primary : colorScheme.onBackground, 
              fontSize: 15, 
              fontWeight: isCurrentlyPlaying ? FontWeight.bold : FontWeight.w600
            )
          ),
          subtitle: Text(
            song.artist ?? 'Unknown Artist', 
            maxLines: 1, 
            overflow: TextOverflow.ellipsis, 
            style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54), fontSize: 13)
          ),
          onLongPress: onLongPress,
          onTap: onTapOverride ?? () async {
            HapticFeedback.lightImpact(); 
            await _recordPlayHistory(context, db, song);
            final queueItems = await _buildMediaItems(currentQueue, activeIndex: currentIndex);
            await handler.updateQueue(queueItems);
            await handler.setShuffleMode(AudioServiceShuffleMode.none);
            await handler.skipToQueueItem(currentIndex);
            await handler.play();
          },
          trailing: isSelectionMode ? null : Row(
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
                    _getDisplayLanguage(song.languageTag?.isNotEmpty == true ? song.languageTag : song.genre).toUpperCase(), 
                    style: TextStyle(color: colorScheme.primary, fontSize: 9, fontWeight: FontWeight.bold)
                  ),
                ),
              
              Consumer(
                builder: (context, ref, child) {
                  final isFav = ref.watch(isFavoriteProvider(song.id)).value ?? false;
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? colorScheme.primary : colorScheme.onBackground.withOpacity(0.38),
                      size: 20,
                    ),
                    onPressed: () => db.playlistsDao.toggleFavorite(song.id),
                  );
                },
              ),
              const SizedBox(width: 8),
              
              Text(
                formatSongDuration(song.durationMs), 
                style: TextStyle(color: colorScheme.onBackground.withOpacity(0.38), fontSize: 13)
              ),
              
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
    );
  }
}

class RecentlyAddedScreen extends ConsumerWidget {
  const RecentlyAddedScreen({super.key});

  Future<void> _playQueue(BuildContext context, WidgetRef ref, List<Song> queue, {required bool shuffle}) async {
    if (queue.isEmpty) return;
    final handler = ref.read(audioHandlerProvider);
    final db = ref.read(databaseProvider);
    
    List<Song> playList = List.from(queue);
    if (shuffle) playList.shuffle();

    if (playList.isNotEmpty) await _recordPlayHistory(context, db, playList.first);

    final items = await _buildMediaItems(playList, activeIndex: 0);

    await handler.updateQueue(items);
    await handler.setShuffleMode(shuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
    await handler.skipToQueueItem(0);
    await handler.play();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final songsAsync = ref.watch(availableSongsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        title: Text('Recently Added', style: TextStyle(color: colorScheme.onBackground, fontWeight: FontWeight.bold)),
      ),
      body: songsAsync.when(
        loading: () => SkeletonPulse(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120, top: 8),
            itemCount: 8,
            itemExtent: 72.0,
            itemBuilder: (context, index) => const SkeletonSongTile(),
          ),
        ),
        error: (err, stack) => Center(child: Text("Error loading songs.", style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54)))),
        data: (rawSongs) {
          final songs = List<Song>.from(rawSongs);
          if (songs.isEmpty) return Center(child: Text("No songs found.", style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54))));

          songs.sort((a, b) {
            int cmp = (b.ctimeNs ?? 0).compareTo(a.ctimeNs ?? 0);
            if (cmp == 0) cmp = b.firstSeen.compareTo(a.firstSeen);
            if (cmp == 0) cmp = b.id.compareTo(a.id);
            return cmp;
          });
          
          final recentSongs = songs.take(100).toList(); 

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _playQueue(context, ref, recentSongs, shuffle: false),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _playQueue(context, ref, recentSongs, shuffle: true),
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Shuffle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  key: const PageStorageKey('recently_added_scroll_key'),
                  padding: const EdgeInsets.only(bottom: 120, top: 8),
                  itemCount: recentSongs.length,
                  itemExtent: 72.0,   
                  itemBuilder: (context, index) => _RecentVerticalTile(
                    key: ValueKey(recentSongs[index].id),
                    song: recentSongs[index], 
                    ref: ref,
                    currentQueue: recentSongs,
                    currentIndex: index,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PlayHistoryScreen extends ConsumerWidget {
  const PlayHistoryScreen({super.key});

  Future<void> _playQueue(BuildContext context, WidgetRef ref, List<Song> queue, {required bool shuffle}) async {
    if (queue.isEmpty) return;
    final handler = ref.read(audioHandlerProvider);
    final db = ref.read(databaseProvider);
    
    List<Song> playList = List.from(queue);
    if (shuffle) playList.shuffle();

    if (playList.isNotEmpty) await _recordPlayHistory(context, db, playList.first);

    final items = await _buildMediaItems(playList, activeIndex: 0);

    await handler.updateQueue(items);
    await handler.setShuffleMode(shuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
    await handler.skipToQueueItem(0);
    await handler.play();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final historyAsync = ref.watch(historyFullProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        title: Text('Listening History', style: TextStyle(color: colorScheme.onBackground, fontWeight: FontWeight.bold)),
      ),
      body: historyAsync.when(
        loading: () => SkeletonPulse(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 120, top: 8),
            itemCount: 8,
            itemExtent: 72.0,
            itemBuilder: (context, index) => const SkeletonSongTile(),
          ),
        ),
        error: (err, stack) => Center(child: Text("Error loading play history.", style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54)))),
        data: (historySongs) {
          if (historySongs.isEmpty) return Center(child: Text("No play history yet.", style: TextStyle(color: colorScheme.onBackground.withOpacity(0.54))));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _playQueue(context, ref, historySongs, shuffle: false),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _playQueue(context, ref, historySongs, shuffle: true),
                        icon: const Icon(Icons.shuffle_rounded),
                        label: const Text('Shuffle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.surface,
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  key: const PageStorageKey('play_history_scroll_key'),
                  padding: const EdgeInsets.only(bottom: 120, top: 8),
                  itemCount: historySongs.length,
                  itemExtent: 72.0,   
                  itemBuilder: (context, index) => _RecentVerticalTile(
                    key: ValueKey('history_${historySongs[index].id}_$index'),
                    song: historySongs[index], 
                    ref: ref,
                    currentQueue: historySongs,
                    currentIndex: index,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap; 

  const _StatItem({required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, 
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: colorScheme.onBackground, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: colorScheme.onBackground.withOpacity(0.4), fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

Future<void> _recordPlayHistory(BuildContext context, AppDatabase db, Song song, {DateTime? customTime}) async {
  final safeDuration = (song.durationMs != null && song.durationMs! > 0) ? song.durationMs! : 180000;

  try {
    await db.historyDao.recordPlay(
      songId: song.id,
      listenedMs: safeDuration,
      counted: true,
      skippedEarly: false,
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SQL History Error: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }
}

String _getDisplayLanguage(String? rawCode) {
  if (rawCode == null || rawCode.trim().isEmpty || rawCode.toLowerCase() == 'und' || rawCode.toLowerCase() == 'unclassified') {
    return 'UNCLASSIFIED';
  }
  return rawCode.toUpperCase();
}

class _HeaderOffsetScrollController extends ScrollController {
  int Function()? getListLength;

  @override
  void jumpTo(double value) {
    double dynamicHeaderOffset = 1120.0;
    
    if (hasClients && getListLength != null) {
      final int songCount = getListLength!();
      if (songCount > 0) {
        final pos = position;
        final listHeight = songCount * 72.0;
        final totalScrollableContent = pos.maxScrollExtent + pos.viewportDimension;
        
        final calculatedHeaderHeight = totalScrollableContent - listHeight - 120.0;
        
        if (calculatedHeaderHeight > 0) {
          dynamicHeaderOffset = calculatedHeaderHeight;
        }
      }
    }
    
    super.jumpTo(value + dynamicHeaderOffset);
  }
}