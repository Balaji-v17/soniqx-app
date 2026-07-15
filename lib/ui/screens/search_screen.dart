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

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A).withOpacity(0.8),
        elevation: 0,
        toolbarHeight: 80,
        title: TextField(
          controller: _searchController,
          onChanged: (value) => _onSearchChanged(value, ref),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search songs, artists, or albums...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('', ref);
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFF1A1A2E),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
body: searchQuery.isEmpty
          ? _buildIdleState()
          // 🎯 FIXED: Changed StreamBuilder to FutureBuilder
          : FutureBuilder<List<Song>>(
              future: db.songsDao.searchSongs(searchQuery), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  );
                }

                final results = snapshot.data ?? [];

                if (results.isEmpty) {
                  return _buildNoResultsState(searchQuery);
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80), // Added bottom padding to clear the mini-player
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

  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'Find your music',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your spelling or try a different term.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
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
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.white.withOpacity(0.05),
      splashColor: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            RepaintBoundary(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: const Icon(Icons.music_note_rounded, color: Color(0xFF6366F1), size: 24),
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
                    style: const TextStyle(
                      color: Colors.white,
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
                      color: Colors.white.withOpacity(0.55),
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