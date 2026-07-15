import 'language_seed_db.dart';
import 'string_extensions.dart';

class ClassificationResult {
  final String? language;
  final double confidence;
  final bool needsManual;

  ClassificationResult({this.language, this.confidence = 0.0, this.needsManual = true});
  
  static ClassificationResult unknown() => ClassificationResult(needsManual: true);
  static ClassificationResult confident(String lang, double conf) => 
      ClassificationResult(language: lang, confidence: conf, needsManual: false);
  static ClassificationResult ambiguous(String lang, double conf) => 
      ClassificationResult(language: lang, confidence: conf, needsManual: true);
}

class LanguageClassifier {
  
  // Strategy 1: Unicode Script Detection
  static String? detectScriptLanguage(String text) {
    for (final char in text.runes) {
      if (char >= 0x0C80 && char <= 0x0CFF) return 'Kannada';
      if (char >= 0x0B80 && char <= 0x0BFF) return 'Tamil';
      if (char >= 0x0C00 && char <= 0x0C7F) return 'Telugu';
      if (char >= 0x0D00 && char <= 0x0D7F) return 'Malayalam';
      if (char >= 0x0900 && char <= 0x097F) return 'Hindi';
      if (char >= 0x0A00 && char <= 0x0A7F) return 'Punjabi';
      if (char >= 0x0980 && char <= 0x09FF) return 'Bengali';
      if (char >= 0x0A80 && char <= 0x0AFF) return 'Gujarati';
    }
    return null;
  }

  // Strategy 3: Album Name Latin Pattern Matching
  static String? matchAlbumPattern(String album) {
    const albumPatterns = { 'mungaru':'Kannada', 'kirik':'Kannada', 'kabali':'Tamil', 'kaithi':'Tamil', 'pushpa':'Telugu', 'dangal':'Hindi' /* etc */ };
    final normalized = album.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '');
    for (final entry in albumPatterns.entries) {
      if (normalized.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static ClassificationResult classify({
    required String? title,
    required String? artist,
    required String? album,
    required Map<String, Map<String, double>> localDb,
  }) {
    // Cascade 1 & 2: Title and Album Unicode Script
    if (title != null) {
      final lang = detectScriptLanguage(title);
      if (lang != null) return ClassificationResult.confident(lang, 0.99);
    }
    if (album != null) {
      final lang = detectScriptLanguage(album);
      if (lang != null) return ClassificationResult.confident(lang, 0.97);
    }

    // Cascade 3: Album Latin Pattern Matching
    if (album != null) {
      final lang = matchAlbumPattern(album);
      if (lang != null) return ClassificationResult.confident(lang, 0.85);
    }

    // Cascade 4 & 5: Artist Seed with Entropy Gap
    if (artist != null && artist.isNotEmpty) {
      final cleanArtist = artist.toNormalizedArtist();
      if (localDb.containsKey(cleanArtist)) {
        final scores = localDb[cleanArtist]!;
        final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        
        final topLang = sorted[0].key;
        final topScore = sorted[0].value;
        
        // 🎯 THE FIX: Distrust Sparse JSON
        // If the DB only has 1 language for this artist, we lack context to do a gap analysis.
        if (sorted.length == 1) {
          // Require extreme confidence (0.85+) to trust a single data point
          if (topScore >= 0.85) return ClassificationResult.confident(topLang, topScore);
          return ClassificationResult.ambiguous(topLang, topScore);
        }
        
        // For artists with multiple DB scores, use the gap logic
        final secondScore = sorted[1].value;
        final gap = topScore - secondScore;

        // Large gap = confident auto-classify
        if (gap >= 0.35 && topScore >= 0.60) return ClassificationResult.confident(topLang, topScore);
        
        // Small gap = polyglot artist, flag as ambiguous
        return ClassificationResult.ambiguous(topLang, topScore);
      }
    }

    return ClassificationResult.unknown();
  }
}