import 'widgets/add_to_playlist_sheet.dart';
import 'package:flutter/material.dart';
import '../database/database.dart'; // Adjust if your Drift DB path is different
import 'package:soniq/ui/widgets/manual_tag_sheet.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
  });

  // 🎯 Helper to dynamically color the tags based on language
  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'hindi':
        return const Color(0xFFF59E0B); // Amber
      case 'tamil':
        return const Color(0xFF10B981); // Emerald
      case 'english':
        return const Color(0xFF3B82F6); // Blue
      case 'korean':
        return const Color(0xFFEC4899); // Pink
      default:
        return const Color(0xFF8B5CF6); // Default Purple
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format duration from milliseconds to mm:ss
    final duration = Duration(milliseconds: song.durationMs ?? 0);
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    // Check if the AI has assigned a language tag
    final hasLanguageTag = song.languageTag != null && song.languageTag!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Album Art Placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Deep grey placeholder
                borderRadius: BorderRadius.circular(8), // Soft corners
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white54,
              ),
            ),
            const SizedBox(width: 16),
            
            // Title, Artist & Language Badges
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          song.artist ?? 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // 🎯 The dynamic language badge rendering logic
                      if (hasLanguageTag) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getLanguageColor(song.languageTag!).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getLanguageColor(song.languageTag!).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            song.languageTag!.toUpperCase(),
                            style: TextStyle(
                              color: _getLanguageColor(song.languageTag!),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Duration
            Text(
              '$minutes:$seconds',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            
            // 🎯 FIXED: Converted to a PopupMenuButton to support multiple actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white54),
              color: const Color(0xFF2A2A2A), // Dark theme matching background
              onSelected: (value) {
                switch (value) {
                  case 'add_to_playlist':
                    AddToPlaylistSheet.show(context, song.id);
                    break;
                  case 'edit_tag':
                    // Delay slightly to let the popup menu close before opening the sheet
                    Future.delayed(
                      const Duration(milliseconds: 50),
                      () => ManualTagSheet.show(context, song), 
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'add_to_playlist',
                  child: Row(
                    children: [
                      Icon(Icons.playlist_add, size: 20, color: Colors.white70),
                      SizedBox(width: 12),
                      Text('Add to Playlist', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'edit_tag',
                  child: Row(
                    children: [
                      Icon(Icons.label_outline, size: 20, color: Colors.white70),
                      SizedBox(width: 12),
                      Text('Edit Language Tag', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}