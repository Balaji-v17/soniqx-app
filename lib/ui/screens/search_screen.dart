// ============================================================
//  SONIQ — lib/ui/screens/search_screen.dart
//  FTS5 Debounced Search Engine with Premium UI.
// ============================================================

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/audio/soniq_audio_handler.dart';

// Riverpod provider to hold the current, debounced search query
final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, WidgetRef ref) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Wait 300ms after the user stops typing before hitting the SQLite DB
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = query.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final audioHandler = ref.watch(audioHandlerProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    // 🎯 Access the global theme colors
    final colorScheme = Theme.of(context).colorScheme;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: Colors.transparent, // Lets the RootScreen background show through
      appBar: AppBar(
        // 🎯 DYNAMIC: Inherit background but keep the translucency
        backgroundColor: scaffoldBg.withOpacity(0.8),
        elevation: 0,
        toolbarHeight: 80,
        title: TextField(
          controller: _searchController,
          onChanged: (value) => _onSearchChanged(value, ref),
          style: TextStyle(color: colorScheme.onBackground, fontSize: 16), // 🎯 DYNAMIC
          decoration: InputDecoration(
            hintText: 'Search songs, artists, or albums...',
            hintStyle: TextStyle(color: colorScheme.onBackground.withOpacity(0.3)), // 🎯 DYNAMIC
            prefixIcon: Icon(Icons.search_rounded, color: colorScheme.primary), // 🎯 DYNAMIC
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: colorScheme.onBackground.withOpacity(0.54)), // 🎯 DYNAMIC
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('', ref);
                    },
                  )
                : null,
            filled: true,
            fillColor: colorScheme.surface, // 🎯 DYNAMIC: Changes from dark purple to white automatically
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: searchQuery.isEmpty
          ? _buildIdleState(context)
          : FutureBuilder<List<Song>>(
              future: db.songsDao.searchSongs(searchQuery), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: colorScheme.primary),
                  );
                }

                final results = snapshot.data ?? [];

                if (results.isEmpty) {
                  return _buildNoResultsState(context, searchQuery);
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80), // Clear the mini-player
                  itemCount: results.length,
                  itemExtent: 72.0, // 60fps locked scroll
                  itemBuilder: (context, index) {
                    final song = results[index];
                    return _SearchResultTile(
                      song: song,
                      onTap: () => _playSearchResult(song, results, index, audioHandler),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 64, color: colorScheme.onBackground.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Find your music',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onBackground.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context, String query) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search_rounded, size: 64, color: colorScheme.onBackground.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: colorScheme.onBackground),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your spelling or try a different term.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onBackground.withOpacity(0.5)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playSearchResult(Song selectedSong, List<Song> allResults, int index, SoniqAudioHandler handler) async {
    final queue = allResults.map((s) => MediaItem(
      id: s.id.toString(),
      title: s.title ?? 'Unknown Track',
      artist: s.artist ?? 'Unknown Artist',
      album: s.album ?? 'Unknown Album',
      duration: Duration(milliseconds: s.durationMs ?? 0),
      extras: {'path': s.path},
    )).toList();

    await handler.updateQueue(queue);
    await handler.skipToQueueItem(index);
    await handler.play();
  }
}

class _SearchResultTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _SearchResultTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      highlightColor: colorScheme.onBackground.withOpacity(0.05), // 🎯 DYNAMIC
      splashColor: colorScheme.onBackground.withOpacity(0.1), // 🎯 DYNAMIC
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            RepaintBoundary(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surface, // 🎯 DYNAMIC
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: colorScheme.onBackground.withOpacity(0.05)), // 🎯 DYNAMIC
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Icon(Icons.music_note_rounded, color: colorScheme.primary, size: 24), // 🎯 DYNAMIC
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    song.title ?? 'Unknown Track',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onBackground, // 🎯 DYNAMIC
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist ?? 'Unknown Artist',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.55), // 🎯 DYNAMIC
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}