import 'dart:io';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:palette_generator/palette_generator.dart';

import '../providers.dart';
import 'sleep_timer_sheet.dart'; 
import 'queue_sheet.dart'; 

final dominantColorProvider = StreamProvider<Color>((ref) async* {
  final audioHandler = ref.watch(audioHandlerProvider);
  
  await for (final item in audioHandler.mediaItem) {
    if (item?.artUri != null) {
      try {
        final imageProvider = FileImage(File.fromUri(item!.artUri!));
        final palette = await PaletteGenerator.fromImageProvider(imageProvider);
        yield palette.dominantColor?.color ?? palette.mutedColor?.color ?? const Color(0xFF121212);
      } catch (_) {
        yield const Color(0xFF121212);
      }
    } else {
      yield const Color(0xFF121212);
    }
  }
});

class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final bgColor = ref.watch(dominantColorProvider).value ?? const Color(0xFF121212);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.5),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bedtime_outlined, color: Colors.white),
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
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800), 
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              bgColor.withOpacity(0.6), 
              const Color(0xFF121212),  
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: StreamBuilder<MediaItem?>(
                stream: audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  if (mediaItem == null) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: MediaQuery.of(context).size.width * 0.85,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: _buildAlbumArt(mediaItem),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          mediaItem.title,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mediaItem.artist ?? 'Unknown Artist',
                          style: const TextStyle(color: Colors.white54, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 32),
                        StreamBuilder<Duration>(
                          stream: AudioService.position, 
                          builder: (context, positionSnapshot) {
                            final position = positionSnapshot.data ?? Duration.zero;
                            final duration = mediaItem.duration ?? Duration.zero;

                            return _SeekBar(
                              position: position,
                              duration: duration,
                              activeColor: bgColor == const Color(0xFF121212) ? const Color(0xFF6366F1) : bgColor, 
                              onChangeEnd: (newPosition) {
                                audioHandler.seek(newPosition);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        StreamBuilder<PlaybackState>(
                          stream: audioHandler.playbackState,
                          builder: (context, stateSnapshot) {
                            final playing = stateSnapshot.data?.playing ?? false;
                            final shuffle = stateSnapshot.data?.shuffleMode == AudioServiceShuffleMode.all;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.shuffle_rounded),
                                  color: shuffle ? Colors.white : Colors.white38,
                                  iconSize: 28,
                                  onPressed: () => audioHandler.setShuffleMode(
                                    shuffle ? AudioServiceShuffleMode.none : AudioServiceShuffleMode.all
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_previous_rounded),
                                  color: Colors.white,
                                  iconSize: 48,
                                  onPressed: audioHandler.skipToPrevious,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: bgColor == const Color(0xFF121212) ? const Color(0xFF6366F1) : bgColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                                    color: Colors.white,
                                    iconSize: 64,
                                    onPressed: playing ? audioHandler.pause : audioHandler.play,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next_rounded),
                                  color: Colors.white,
                                  iconSize: 48,
                                  onPressed: audioHandler.skipToNext,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.queue_music_rounded),
                                  color: Colors.white70,
                                  iconSize: 28,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (context) => const QueueSheet(),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.12, 
              minChildSize: 0.12,     
              maxChildSize: 0.85,     
              builder: (BuildContext context, ScrollController scrollController) {
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25), 
                    child: Container(
                      color: bgColor.withOpacity(0.3), 
                      child: ListView(
                        controller: scrollController, 
                        padding: const EdgeInsets.all(32),
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Lyrics',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "This is a placeholder for your beautiful lyrics.\n\nImagine the song playing in the background while these words flow.\n\nAs you drag this panel up, the entire background smoothly blurs away into frosted glass.\n\nEventually, we can parse actual .lrc files or ID3 tags to sync these lines to the exact beat of the music.\n\nBut for now, just enjoy the buttery smooth physics of this swipeable sheet.",
                            style: TextStyle(
                              color: Colors.white, 
                              fontSize: 22, 
                              height: 1.8, 
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          const SizedBox(height: 100), 
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // 1. Safe URI-based image loader
  Widget _buildAlbumArt(MediaItem item) {
    // Check if we have a valid file URI
    if (item.artUri != null && item.artUri!.scheme == 'file') {
      final file = File(item.artUri!.path);
      
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.file(
            file,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            // 🎯 The ultimate safety net for the full screen!
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackArt(item.title);
            },
          ),
        );
      }
    }
    
    // If no URI exists, or the file is missing, jump straight to Plan B
    return _buildFallbackArt(item.title);
  }

  // 2. The Premium Plan B Fallback
  Widget _buildFallbackArt(String title) {
    final displayLetter = title.isNotEmpty ? title[0].toUpperCase() : '♫';

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E3141), Color(0xFF13141F)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayLetter,
          style: const TextStyle(
            color: Colors.white24, 
            fontSize: 120,         
            fontWeight: FontWeight.w800,
            letterSpacing: -2.0,
          ),
        ),
      ),
    );
  }
} // <--- THIS WAS THE MISSING BRACKET!

class _SeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final Color activeColor;
  final ValueChanged<Duration> onChangeEnd;

  const _SeekBar({
    required this.position,
    required this.duration,
    required this.activeColor,
    required this.onChangeEnd,
  });

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final max = widget.duration.inMilliseconds.toDouble();
    final value = _dragValue ?? widget.position.inMilliseconds.toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: widget.activeColor,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
          ),
          child: Slider(
            min: 0,
            max: max > 0 ? max : 1,
            value: value.clamp(0.0, max > 0 ? max : 1),
            onChanged: (val) {
              setState(() {
                _dragValue = val;
              });
            },
            onChangeEnd: (val) {
              widget.onChangeEnd(Duration(milliseconds: val.round()));
              _dragValue = null;
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(Duration(milliseconds: value.round())), style: const TextStyle(color: Colors.white54, fontSize: 12)),
            Text(_formatDuration(widget.duration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}