// ============================================================
//  SONIQ — lib/ui/widgets/mini_player.dart
//  Persistent Glassmorphic Mini-Player Layer.
// ============================================================

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:soniq/providers.dart';
import '../sheets/full_player_sheet.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        // 🎯 FIXED: Detect the extracted local artwork cache file
        final hasArt = mediaItem.artUri != null && mediaItem.artUri!.scheme == 'file';
        final artFile = hasArt ? File(mediaItem.artUri!.path) : null;

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, stateSnapshot) {
            final playing = stateSnapshot.data?.playing ?? false;

            return GestureDetector(
              onTap: () {
                // Launch the Full Player Sheet!
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const FullPlayerSheet(),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2A).withOpacity(0.9), // Sleek dark premium base
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          // ─── 1. DYNAMIC ALBUM ART ───
                          Hero(
                            tag: 'album_art_${mediaItem.id}',
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.0),
                                color: const Color(0xFF6366F1).withOpacity(0.2), // Fallback tint
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                // 🎯 If we have the artwork file, render it! Otherwise show the icon.
                                child: (hasArt && artFile != null && artFile.existsSync())
                                    ? Image.file(
                                        artFile, 
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.music_note_rounded, color: Color(0xFF6366F1)),
                                      )
                                    : const Icon(Icons.music_note_rounded, color: Color(0xFF6366F1)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // ─── 2. TRACK INFO ───
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  mediaItem.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mediaItem.artist ?? 'Unknown Artist',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          // ─── 3. PLAY/PAUSE ───
                          GestureDetector(
                            onTap: () => playing ? audioHandler.pause() : audioHandler.play(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  key: ValueKey(playing),
                                  color: Colors.black,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // ─── 4. NEXT TRACK ───
                          IconButton(
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
                            onPressed: () => audioHandler.skipToNext(),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}