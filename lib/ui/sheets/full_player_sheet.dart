// ============================================================
//  SONIQ — lib/ui/sheets/full_player_sheet.dart
//  Premium Full-Screen Player with Glassmorphic Backgrounds.
// ============================================================
import 'sleep_timer_sheet.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/ui/widgets/fallback_album_art.dart'; // 🎯 FIXED: Added the missing import!

class FullPlayerSheet extends ConsumerWidget {
  const FullPlayerSheet({super.key});

  void _showOptionsSheet(BuildContext context, MediaItem mediaItem, AudioHandler audioHandler) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _OptionsContent(mediaItem: mediaItem, audioHandler: audioHandler),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        final hasArt = mediaItem.artUri != null && mediaItem.artUri!.scheme == 'file';
        final artFile = hasArt ? File(mediaItem.artUri!.path) : null;

        return Dismissible(
          key: const Key('full_player'),
          direction: DismissDirection.down,
          onDismissed: (_) => Navigator.pop(context),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Dynamic Blurred Background Layer
                if (hasArt && artFile != null && artFile.existsSync())
                  Image.file(
                    artFile,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const DefaultBackgroundGradient(),
                  )
                else
                  const DefaultBackgroundGradient(),
                
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                  child: Container(color: Colors.black.withOpacity(0.6)),
                ),

                // 2. Foreground UI
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16.0),
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 36),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text(
                              'NOW PLAYING',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.bedtime_outlined, color: Colors.white, size: 26),
                                  tooltip: 'Sleep Timer',
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (context) => const SleepTimerSheet(),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 28),
                                  onPressed: () => _showOptionsSheet(context, mediaItem, audioHandler),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),
                      Hero(
                        tag: 'album_art_${mediaItem.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0), 
                            child: (artFile != null && artFile.existsSync())
                                ? Image.file(
                                    artFile,
                                    width: 320,
                                    height: 320,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => FallbackAlbumArt(width: 320, height: 320, borderRadius: 20.0, shadowOpacity: 0.3),
                                  )
                                : FallbackAlbumArt(
                                    width: 320, 
                                    height: 320, 
                                    borderRadius: 20.0, 
                                    shadowOpacity: 0.3,
                                  ),
                          ),
                        ),
                      ), 
                      const Spacer(flex: 1),

                      // Song Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            Text(
                              mediaItem.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              mediaItem.artist ?? 'Unknown Artist',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Interactive Seek Bar
                      _PlayerSeekBar(audioHandler: audioHandler, mediaItem: mediaItem),

                      const SizedBox(height: 16),

                      // Main Playback Controls
                      _PlayerControls(audioHandler: audioHandler),

                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Options Menu Bottom Sheet ───────────────────────────────────────

class _OptionsContent extends ConsumerWidget {
  final MediaItem mediaItem;
  final AudioHandler audioHandler;

  const _OptionsContent({required this.mediaItem, required this.audioHandler});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 32.0, left: 8.0, right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            title: const Text("Song Details", style: TextStyle(color: Colors.white, fontSize: 16)),
            onTap: () {
              Navigator.pop(context);
              _showDetailsDialog(context, mediaItem);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            title: const Text("Delete from device", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
            onTap: () => _deleteSong(context, ref),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Divider(color: Colors.white12),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: StreamBuilder<double>(
              stream: (audioHandler as dynamic).player.volumeStream,
              builder: (context, snapshot) {
                final volume = snapshot.data ?? 1.0;
                
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_down_rounded, color: Colors.white70),
                      onPressed: () => (audioHandler as dynamic).setVolume((volume - 0.1).clamp(0.0, 1.0)),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4.0,
                          activeTrackColor: const Color(0xFF818CF8),
                          inactiveTrackColor: Colors.white.withOpacity(0.1),
                          thumbColor: Colors.white,
                          overlayColor: const Color(0xFF818CF8).withOpacity(0.2),
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        ),
                        child: Slider(
                          value: volume,
                          onChanged: (val) => (audioHandler as dynamic).setVolume(val),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.white70),
                      onPressed: () => (audioHandler as dynamic).setVolume((volume + 0.1).clamp(0.0, 1.0)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSong(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete File?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will permanently remove the audio file from your device storage. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final db = ref.read(databaseProvider);
      final path = mediaItem.extras?['path'] as String?;
      final songId = int.tryParse(mediaItem.id);

      if (path == null || songId == null) throw Exception("Missing file path or song ID.");

      if (audioHandler.playbackState.value.playing) {
         await audioHandler.skipToNext();
      } else {
         await audioHandler.stop();
      }
      
      await Future.delayed(const Duration(milliseconds: 150));

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      await (db.delete(db.songs)..where((s) => s.id.equals(songId))).go();

      if (context.mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File permanently deleted from device.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Deletion Error: $e');
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete file: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showDetailsDialog(BuildContext context, MediaItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Song Details", style: TextStyle(color: Colors.white)),
        content: Text(
          "Title: ${item.title}\n"
          "Artist: ${item.artist ?? 'Unknown'}\n\n"
          "File Path:\n${item.extras?['path'] ?? 'Unknown'}",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close", style: TextStyle(color: Color(0xFF818CF8))),
          )
        ],
      ),
    );
  }
}

// ─── Default Fallback UI Widgets ─────────────────────────────────────

class DefaultBackgroundGradient extends StatelessWidget {
  const DefaultBackgroundGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2A2D43), Color(0xFF000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class DefaultPlaceholderArt extends StatelessWidget {
  const DefaultPlaceholderArt({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.music_note_rounded, size: 120, color: Colors.white54),
    );
  }
}

// ─── Interactive Seek Bar Component ──────────────────────────────────

class _PlayerSeekBar extends StatefulWidget {
  final AudioHandler audioHandler;
  final MediaItem mediaItem;

  const _PlayerSeekBar({required this.audioHandler, required this.mediaItem});

  @override
  State<_PlayerSeekBar> createState() => _PlayerSeekBarState();
}

class _PlayerSeekBarState extends State<_PlayerSeekBar> {
  double? _dragValue;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = widget.mediaItem.duration ?? Duration.zero;

    return StreamBuilder<Duration>(
      stream: AudioService.position,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4.0,
                  activeTrackColor: const Color(0xFF818CF8),
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                  overlayColor: const Color(0xFF818CF8).withOpacity(0.2),
                ),
                child: Slider(
                  value: _dragValue ?? position.inMilliseconds.toDouble().clamp(0.0, totalDuration.inMilliseconds.toDouble()),
                  max: totalDuration.inMilliseconds.toDouble() > 0 ? totalDuration.inMilliseconds.toDouble() : 1.0,
                  onChanged: (value) {
                    setState(() {
                      _dragValue = value;
                    });
                  },
                  onChangeEnd: (value) {
                    widget.audioHandler.seek(Duration(milliseconds: value.round()));
                    setState(() {
                      _dragValue = null;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_dragValue != null ? Duration(milliseconds: _dragValue!.round()) : position), 
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                    ),
                    Text(_formatDuration(totalDuration), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Playback Controls Component ─────────────────────────────────────

class _PlayerControls extends StatelessWidget {
  final AudioHandler audioHandler;

  const _PlayerControls({required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final playing = playbackState?.playing ?? false;
        
        final shuffleMode = playbackState?.shuffleMode ?? AudioServiceShuffleMode.none;
        final repeatMode = playbackState?.repeatMode ?? AudioServiceRepeatMode.none;

        final isShuffle = shuffleMode == AudioServiceShuffleMode.all;
        final isRepeat = repeatMode != AudioServiceRepeatMode.none;

        final repeatIcon = repeatMode == AudioServiceRepeatMode.one 
            ? Icons.repeat_one_rounded 
            : Icons.repeat_rounded;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.shuffle_rounded, color: isShuffle ? const Color(0xFF818CF8) : Colors.white54),
                iconSize: 24,
                onPressed: () {
                  final nextMode = isShuffle 
                      ? AudioServiceShuffleMode.none 
                      : AudioServiceShuffleMode.all;
                  audioHandler.setShuffleMode(nextMode);
                },
              ),
              
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                iconSize: 42,
                onPressed: audioHandler.skipToPrevious,
              ),
              
              GestureDetector(
                onTap: () => playing ? audioHandler.pause() : audioHandler.play(),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      key: ValueKey(playing),
                      color: const Color(0xFF0A0A0A),
                      size: 40,
                    ),
                  ),
                ),
              ),
              
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                iconSize: 42,
                onPressed: audioHandler.skipToNext,
              ),
              
              IconButton(
                icon: Icon(repeatIcon, color: isRepeat ? const Color(0xFF818CF8) : Colors.white54),
                iconSize: 24,
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
            ],
          ),
        );
      },
    );
  }
}