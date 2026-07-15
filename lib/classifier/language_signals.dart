// ============================================================
//  SONIQ — lib/classifier/language_signals.dart
//  Pure functions for language detection (Isolate-safe).
// ============================================================

class LanguageSignals {
  
  // ─── SIGNAL 1: Unicode Script Detection (Weight: 0.95) ─────────────
  static Map<String, double>? detectScript(String text) {
    // Looks for native characters. Extremely high reliability if found.
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) return {'Hindi': 0.95, 'Marathi': 0.80}; 
    if (RegExp(r'[\u0C80-\u0CFF]').hasMatch(text)) return {'Kannada': 0.95};
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(text)) return {'Tamil': 0.95};
    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(text)) return {'Telugu': 0.95};
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) return {'Bengali': 0.95};
    if (RegExp(r'[\u0D00-\u0D7F]').hasMatch(text)) return {'Malayalam': 0.95};
    
    return null; // English/Latin script returns null to pass to the next signal
  }

  // ─── SIGNAL 2: Artist Normalization ────────────────────────────────
  // Cleans "Arijit Singh feat. Shreya Ghoshal" -> "arijit singh"
  static String normalizeArtist(String raw) {
    return raw
      .toLowerCase()
      .replaceAll(RegExp(r'\s*\bfeat\.?\b.*', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*\bft\.?\b.*', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*[×&].*'), '')
      .replaceAll('.', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  }

  // ─── SIGNAL 3: Folder Path Heuristics (Weight: 0.60) ───────────────
  static Map<String, double>? detectFolderLanguage(String path) {
    final p = path.toLowerCase();
    
    if (p.contains('/hindi/')) return {'Hindi': 0.85};
    if (p.contains('/kannada/')) return {'Kannada': 0.85};
    if (p.contains('/tamil/')) return {'Tamil': 0.85};
    if (p.contains('/telugu/')) return {'Telugu': 0.85};
    if (p.contains('/english/')) return {'English': 0.85};
    if (p.contains('/malayalam/')) return {'Malayalam': 0.85};
    if (p.contains('/bengali/')) return {'Bengali': 0.85};
    
    return null;
  }
}