import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart'; // 🎯 FIXED: Moved to the top!
import 'package:soniq/providers.dart';
import 'package:soniq/ui/widgets/fallback_album_art.dart';

class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Up Next',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => audioHandler.updateQueue([]), // Clear queue
                  child: const Text('Clear', style: TextStyle(color: Color(0xFF818CF8))),
                )
              ],
            ),
          ),
          const Divider(color: Colors.white12),
          
          Expanded(
            child: StreamBuilder<QueueState>(
              stream: Rx.combineLatest2<List<MediaItem>, MediaItem?, QueueState>(
                audioHandler.queue,
                audioHandler.mediaItem,
                (queue, mediaItem) => QueueState(queue, mediaItem),
              ),
              builder: (context, snapshot) {
                final queueState = snapshot.data;
                final queue = queueState?.queue ?? [];
                final currentItem = queueState?.mediaItem;

                if (queue.isEmpty) {
                  return Center(
                    child: Text('The queue is empty.', style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  );
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.only(bottom: 64.0),
                  itemCount: queue.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = queue.removeAt(oldIndex);
                    queue.insert(newIndex, item);
                    audioHandler.updateQueue(queue); // Sync with audio service
                  },
                  itemBuilder: (context, index) {
                    final item = queue[index];
                    final isPlaying = item.id == currentItem?.id;
                    final hasArt = item.artUri != null && item.artUri!.scheme == 'file';
                    final artFile = hasArt ? File(item.artUri!.path) : null;

                    return ListTile(
                      key: ValueKey(item.id),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                      tileColor: isPlaying ? colorScheme.primary.withOpacity(0.15) : Colors.transparent,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: (artFile != null && artFile.existsSync())
                            ? Image.file(artFile, width: 48, height: 48, fit: BoxFit.cover)
                            : const FallbackAlbumArt(width: 48, height: 48, borderRadius: 8.0),
                      ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying ? const Color(0xFF818CF8) : Colors.white,
                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        item.artist ?? 'Unknown Artist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                      ),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: Icon(Icons.drag_handle_rounded, color: Colors.white.withOpacity(0.3)),
                      ),
                      onTap: () => audioHandler.skipToQueueItem(index),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QueueState {
  final List<MediaItem> queue;
  final MediaItem? mediaItem;
  QueueState(this.queue, this.mediaItem);
}