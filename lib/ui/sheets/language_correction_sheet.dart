// ============================================================
//  SONIQ — lib/ui/sheets/language_correction_sheet.dart
//  User feedback UI & AI training loop trigger.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soniq/providers.dart';
import 'package:soniq/database/database.dart';
import 'package:soniq/classifier/string_extensions.dart';
import 'package:drift/drift.dart' as drift;

class LanguageCorrectionSheet extends ConsumerWidget {
  final Song song;

  const LanguageCorrectionSheet({super.key, required this.song});

  // The core languages for your user base
  static const List<String> _languages = [
    'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Punjabi', 'English', 'Malayalam', 'Bengali'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: const BoxDecoration(
        color: Color(0xFF13141F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                const Icon(Icons.psychology_alt_rounded, color: Color(0xFFDB2777)),
                const SizedBox(width: 12),
                const Text(
                  'Correct AI Tag',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (song.languageTag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'AI Guessed: ${song.languageTag}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10, height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isCurrent = song.languageTag == lang;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                  title: Text(
                    lang,
                    style: TextStyle(
                      color: isCurrent ? const Color(0xFFDB2777) : Colors.white,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isCurrent ? const Icon(Icons.check_circle_rounded, color: Color(0xFFDB2777)) : null,
                  onTap: () async {
                    // 1. Clean the artist name for the database
                    final cleanArtist = song.artist?.toNormalizedArtist() ?? 'unknown';

                    // 2. Log the correction for the AI Feedback Loop! (Step 3.2)
                    await db.languageDao.logCorrection(
                      UserCorrectionsCompanion.insert(
                        rawArtistName: song.artist ?? 'Unknown',
                        artistKey: cleanArtist,
                        predictedLanguage: song.languageTag ?? 'none',
                        correctedLanguage: lang,
                        signalThatFired: const drift.Value(2), // Assuming Signal 2 (Artist DB)
                        confidenceAtTime: drift.Value(song.classifierConfidence),
                      ),
                    );

                    // 3. Actually update the song in the user's library
                    await db.songsDao.manuallyTag(song.id, lang);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Saved! AI learned that ${song.artist} sings in $lang.'),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
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