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
import 'package:soniq/ui/widgets/fallback_album_art.dart'; 
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

        // 🎯 FIX 1: Listen to the raw duration stream so the progress bar works
        return StreamBuilder<Duration?>(
          stream: (audioHandler as dynamic).player.durationStream,
          builder: (context, durationSnapshot) {
            final totalDuration = durationSnapshot.data ?? mediaItem.duration ?? Duration.zero;

            return StreamBuilder<PlaybackState>(
              stream: audioHandler.playbackState,
              builder: (context, stateSnapshot) {
                final playbackState = stateSnapshot.data;
                final playing = playbackState?.playing ?? false;
                
                // 🎯 FIX 2: Extract accurate Shuffle and Repeat states
                final shuffleMode = playbackState?.shuffleMode ?? AudioServiceShuffleMode.none;
                final repeatMode = playbackState?.repeatMode ?? AudioServiceRepeatMode.none;

                final isShuffle = shuffleMode == AudioServiceShuffleMode.all;
                final isRepeat = repeatMode != AudioServiceRepeatMode.none;

                final repeatIcon = repeatMode == AudioServiceRepeatMode.one 
                    ? Icons.repeat_one_rounded 
                    : Icons.repeat_rounded;

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
                      color: colorScheme.surface.withOpacity(0.9), 
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // ─── 1. DYNAMIC ALBUM ART ───
                                  Hero(
                                    tag: 'album_art_${mediaItem.id}',
                                    child: (hasArt && artFile != null && artFile.existsSync())
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(16.0),
                                            child: Image.file(
                                              artFile, 
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const FallbackAlbumArt(
                                                width: 48, 
                                                height: 48, 
                                                borderRadius: 16.0,
                                                shadowOpacity: 0.0,
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
                                  const SizedBox(width: 12),
                                  
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
                                          style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14), 
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          mediaItem.artist ?? 'Unknown Artist',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12), 
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ─── 3. SHUFFLE BUTTON (Compact) ───
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      Icons.shuffle_rounded, 
                                      color: isShuffle ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.4), 
                                      size: 20
                                    ),
                                    onPressed: () {
                                      final nextMode = isShuffle 
                                          ? AudioServiceShuffleMode.none 
                                          : AudioServiceShuffleMode.all;
                                      audioHandler.setShuffleMode(nextMode);
                                    },
                                  ),
                                  const SizedBox(width: 8),

                                  // ─── 4. PLAY/PAUSE ───
                                  GestureDetector(
                                    onTap: () => playing ? audioHandler.pause() : audioHandler.play(),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: colorScheme.onSurface, 
                                        shape: BoxShape.circle,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 250),
                                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                        child: Icon(
                                          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          key: ValueKey(playing),
                                          color: colorScheme.surface, 
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // ─── 5. NEXT TRACK ───
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(Icons.skip_next_rounded, color: colorScheme.onSurface, size: 28), 
                                    onPressed: () => audioHandler.skipToNext(),
                                  ),
                                  const SizedBox(width: 8),

                                  // ─── 6. REPEAT BUTTON (Compact) ───
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      repeatIcon, 
                                      color: isRepeat ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.4), 
                                      size: 20
                                    ),
                                    onPressed: () {
                                      AudioServiceRepeatMode nextMode;
                                      if (repeatMode == AudioServiceRepeatMode.none) {
                                        nextMode = AudioServiceRepeatMode.all;
                                      } else if (repeatMode == AudioServiceRepeatMode.all) {
                                        nextMode = AudioServiceRepeatMode.one;
                                      } else {
                                        nextMode = AudioServiceRepeatMode.none;
                                      }
                                      audioHandler.setRepeatMode(nextMode);
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                            ),
                            // ─── 7. LIVE PROGRESS BAR ───
                            StreamBuilder<Duration>(
                              stream: AudioService.position,
                              builder: (context, posSnapshot) {
                                final position = posSnapshot.data ?? Duration.zero;
                                double progress = totalDuration.inMilliseconds > 0 
                                    ? position.inMilliseconds / totalDuration.inMilliseconds 
                                    : 0.0;
                                
                                return LinearProgressIndicator(
                                  value: progress.clamp(0.0, 1.0),
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                                  minHeight: 3.0,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}