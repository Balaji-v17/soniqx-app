// ============================================================
//  SONIQ — lib/ui/sheets/language_picker_sheet.dart
//  Manual tagging UI with AI feedback loop.
// ============================================================

import 'package:flutter/material.dart';
import 'package:soniq/database/database.dart';

class LanguagePickerSheet extends StatelessWidget {
  final Song song;
  final AppDatabase db;

  const LanguagePickerSheet({super.key, required this.song, required this.db});

  static const List<String> _languages = [
    'Hindi', 'English', 'Tamil', 'Telugu', 
    'Kannada', 'Malayalam', 'Bengali', 'Marathi', 
    'Punjabi', 'Gujarati', 'Instrumental'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13141F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Language',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            song.title ?? 'Unknown Track',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _languages.map((lang) {
              final isCurrent = song.languageTag == lang;
              return InkWell(
                onTap: () => _handleLanguageSelection(context, lang),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrent ? const Color(0xFF6366F1) : const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCurrent ? const Color(0xFF818CF8) : Colors.white10,
                    ),
                  ),
                  child: Text(
                    lang,
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.white70,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLanguageSelection(BuildContext context, String language) async {
    // 1. Tag the song permanently (bypasses future auto-classifier runs)
    await db.songsDao.manuallyTag(song.id, language);

    // 2. Log the correction so the AI can learn from it if they do this 3 times
    if (song.artist != null && song.artist!.isNotEmpty && song.artist != 'Unknown Artist') {
      await db.languageDao.logCorrection(
        UserCorrectionsCompanion.insert(
          rawArtistName: song.artist!,
          artistKey: song.artist!.toLowerCase(),
          predictedLanguage: 'unknown', 
          correctedLanguage: language,
        ),
      );
    }

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tagged as $language'),
          backgroundColor: const Color(0xFF6366F1),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}