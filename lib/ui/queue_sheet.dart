import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import '../providers.dart';
import '../audio/audio_handler.dart';

class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(audioHandlerProvider) as SoniqAudioHandler;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle & Header
          const SizedBox(height: 12),
          Container(
            width: 40, height: 5,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Up Next', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => handler.updateQueue([]), // Clear Queue
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Divider(color: textColor.withOpacity(0.1), height: 1),

          // The Interactive Queue List
          Expanded(
            child: StreamBuilder<List<MediaItem>>(
              stream: handler.queue,
              builder: (context, queueSnap) {
                final queue = queueSnap.data ?? [];
                
                if (queue.isEmpty) {
                  return Center(
                    child: Text('Your queue is empty', style: TextStyle(color: textColor.withOpacity(0.5))),
                  );
                }

                return StreamBuilder<MediaItem?>(
                  stream: handler.mediaItem,
                  builder: (context, itemSnap) {
                    final currentItem = itemSnap.data;

                    return ReorderableListView.builder(
                      itemCount: queue.length,
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) newIndex -= 1;
                        handler.moveQueueItem(oldIndex, newIndex);
                      },
                      itemBuilder: (context, index) {
                        final item = queue[index];
                        final isPlaying = currentItem?.id == item.id;

                        return Dismissible(
                          key: ValueKey(item.id + index.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            color: Colors.red.shade400,
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                          ),
                          onDismissed: (_) => handler.removeQueueItemAt(index),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                            tileColor: isPlaying ? textColor.withOpacity(0.05) : Colors.transparent,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: item.artUri != null
                                  ? Image.file(File(item.artUri!.toFilePath()), width: 48, height: 48, fit: BoxFit.cover)
                                  : Container(
                                      width: 48, height: 48,
                                      color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
                                      child: const Icon(Icons.music_note_rounded, color: Color(0xFF6366F1)),
                                    ),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: isPlaying ? const Color(0xFF6366F1) : textColor, fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal),
                            ),
                            subtitle: Text(
                              item.artist ?? 'Unknown Artist',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 13),
                            ),
                            trailing: ReorderableDragStartListener(
                              index: index,
                              child: Icon(Icons.drag_handle_rounded, color: textColor.withOpacity(0.3)),
                            ),
                            onTap: () => handler.skipToQueueItem(index),
                          ),
                        );
                      },
                    );
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}