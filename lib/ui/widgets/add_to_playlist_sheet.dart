import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';

class AddToPlaylistSheet extends ConsumerWidget {
  final int songId;

  const AddToPlaylistSheet({super.key, required this.songId});

  // A simple static helper to launch the sheet from anywhere in the app
  static void show(BuildContext context, int songId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true, // Allows the list to size properly
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AddToPlaylistSheet(songId: songId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.watch(databaseProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap tightly around the content
          children: [
            const SizedBox(height: 12),
            // The little pill drag handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add to Playlist',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            
            // The list of available playlists
            Flexible(
              child: StreamBuilder(
                stream: database.playlistsDao.watchAllUserPlaylists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                    );
                  }

                  final playlists = snapshot.data ?? [];

                  if (playlists.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("No custom mixes yet.", style: TextStyle(color: Colors.white54)),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Prevents layout errors inside the Column
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.queue_music_rounded, color: Color(0xFF6366F1)),
                        ),
                        title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                        subtitle: const Text('Custom Mix', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        onTap: () async {
                          // 1. Insert the relational database link!
                          await database.playlistsDao.addSongToPlaylist(playlist.id, songId);
                          
                          if (context.mounted) {
                            // 2. Close the sheet
                            Navigator.pop(context);
                            
                            // 3. Show a success toast
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added to ${playlist.name}'),
                                backgroundColor: const Color(0xFF6366F1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
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