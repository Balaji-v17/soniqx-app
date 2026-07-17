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
import 'package:soniq/ui/widgets/fallback_album_art.dart'; // 🎯 IMPORTED: Your new 3D default asset widget
import '../sheets/full_player_sheet.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        final hasArt = mediaItem.artUri != null && mediaItem.artUri!.scheme == 'file';
        final artFile = hasArt ? File(mediaItem.artUri!.path) : null;

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, stateSnapshot) {
            final playing = stateSnapshot.data?.playing ?? false;

            return GestureDetector(
              onTap: () {
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
                  color: colorScheme.surface.withOpacity(0.9), // 🎯 DYNAMIC
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      // 🎯 DYNAMIC: Light, soft shadow for Light Mode. Deep shadow for Dark Mode.
                      color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.1),
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
                            // 🎯 OPTIMIZED: Cleaned container sizing to drop the old flat purple fallback icon style
                            child: (hasArt && artFile != null && artFile.existsSync())
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Image.file(
                                      artFile, 
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      // Trigger 3D fallback if the physical image file errors out at runtime
                                      errorBuilder: (_, __, ___) => const FallbackAlbumArt(
                                        width: 48, 
                                        height: 48, 
                                        borderRadius: 16.0,
                                        shadowOpacity: 0.0, // Suppressed inside mini player container
                                      ),
                                    ),
                                  )
                                : const FallbackAlbumArt(
                                    width: 48, 
                                    height: 48, 
                                    borderRadius: 16.0,
                                    shadowOpacity: 0.0,
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
                                  style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14), // 🎯 DYNAMIC
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mediaItem.artist ?? 'Unknown Artist',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12), // 🎯 DYNAMIC
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
                              decoration: BoxDecoration(
                                color: colorScheme.onSurface, // 🎯 DYNAMIC: Inverts beautifully (Black in Light mode, White in Dark Mode)
                                shape: BoxShape.circle,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  key: ValueKey(playing),
                                  color: colorScheme.surface, // 🎯 DYNAMIC: Matches the background of the mini player
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // ─── 4. NEXT TRACK ───
                          IconButton(
                            icon: Icon(Icons.skip_next_rounded, color: colorScheme.onSurface, size: 32), // 🎯 DYNAMIC
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