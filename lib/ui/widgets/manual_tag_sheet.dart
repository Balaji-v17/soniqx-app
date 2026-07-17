// ============================================================
//  SONIQ — lib/ui/widgets/manual_tag_sheet.dart
//  Manual tagging UI & AI Feedback Loop trigger.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/providers.dart'; // Ensure this points to your databaseProvider

class ManualTagSheet extends ConsumerWidget {
  final Song song;

  const ManualTagSheet({super.key, required this.song});

  /// Helper method to easily trigger the sheet from any track menu
  static void show(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ManualTagSheet(song: song),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    
    // Core languages for your Indian/Global library context
    const languages = [
      'Hindi', 'Kannada', 'Tamil', 'Telugu', 
      'Malayalam', 'Punjabi', 'Bengali', 'English', 'Instrumental'
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: MediaQuery.of(context).padding.bottom + 24.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Track Language',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Manually tagging "${song.title}" helps the AI learn how to tag ${song.artist ?? "this artist"} in the future.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70, // Adjust color based on your theme
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: languages.map((lang) {
              final isCurrent = song.languageTag == lang;
              
              return ActionChip(
                label: Text(
                  lang,
                  style: TextStyle(
                    color: isCurrent ? Colors.black : Colors.white,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                backgroundColor: isCurrent ? Colors.amber : Colors.white12,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () async {
                  // 1. Tag the specific song in the SQLite database
                  await db.songsDao.manuallyTag(song.id, lang);

                  // 2. Feed the AI Brain for future scans
                  if (song.artist != null && song.artist!.isNotEmpty) {
                    final cleanArtist = song.artist!.toLowerCase().trim();
                    
                    await db.languageDao.logCorrection(
                      UserCorrectionsCompanion.insert(
                        rawArtistName: song.artist!,
                        artistKey: cleanArtist,
                        predictedLanguage: song.languageTag ?? 'ambiguous',
                        correctedLanguage: lang,
                      ),
                    );
                    
                    debugPrint('🧠 AI Fed: 1 point to $cleanArtist for $lang');
                  }

                  // 3. Force the UI to refresh!
                  // NOTE: If your list provider in providers.dart is named 
                  // something else (like 'libraryProvider' or 'filteredSongsProvider'), 
                  // change 'songsProvider' below to match it.
                 // 3. Force the UI to refresh by invalidating the database provider
                 ref.invalidate(databaseProvider);

                  // 4. Dismiss the sheet
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}