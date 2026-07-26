// ============================================================
//  SONIQ — lib/classifier/language_classifier.dart
//  Tier 1: Deterministic Metadata & Fuzzy Matching
// ============================================================

import 'package:flutter/foundation.dart';

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
  
  // Strategy 1: Strict Unicode Script Detection
  static String? detectScriptLanguage(String text) {
    for (final char in text.runes) {
      if ((char >= 0x0041 && char <= 0x005A) || (char >= 0x0061 && char <= 0x007A)) continue; 
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

  // Strategy 2: Explicit Romanized Language Keywords
  static String? matchExplicitLanguage(String text) {
    final normalized = text.toLowerCase();
    if (normalized.contains('telugu')) return 'Telugu';
    if (normalized.contains('tamil')) return 'Tamil';
    if (normalized.contains('kannada')) return 'Kannada';
    if (normalized.contains('hindi')) return 'Hindi';
    if (normalized.contains('malayalam')) return 'Malayalam';
    if (normalized.contains('english')) return 'English';
    return null;
  }

  // 🎯 THE FIX: Tier 1.5 Emergency Lexicon (Catches Romanized & Missed Tags)
  static String? matchEmergencyHeuristics(String? title, String? artist) {
    final t = (title ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final a = (artist ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    // 1. Problematic Artist Overrides
    if (a.contains('sushinshyam')) return 'Malayalam';
    if (a.contains('thamans')) return 'Telugu';
    if (a.contains('shankarehsaanloy') || a.contains('heroandking')) return 'Hindi';
    if (a.contains('vasukivaibhav') || a.contains('ajaneesh') || a.contains('sanjithhegde') || 
        a.contains('yogarajbhat') || a.contains('vsridhar') || a.contains('chintanvikas') || 
        a.contains('varunramachandra') || a.contains('bjbharath') || a.contains('aishwaryarangarajan') ||
        a.contains('shankarmahadevan') || a.contains('kailashkher')) {
      return 'Kannada';
    }

    // 2. Romanized Title Overrides
    if (t.contains('baare') || t.contains('barebare') || t.contains('neenire') || 
        t.contains('ondu') || t.contains('kaagadada') || t.contains('kathey') || 
        t.contains('thirboki') || t.contains('yenagali') || t.contains('heywhoa') || 
        t.contains('lastbench') || t.contains('ogm')) {
      return 'Kannada';
    }
    
    if (t.contains('illuminati')) return 'Malayalam';
    if (t.contains('tabaahi') || t.contains('suchkehrahahai') || t.contains('jeenelaga') || t.contains('donthetheme')) return 'Hindi';
    if (t.contains('kanmani')) return 'Tamil';
    if (t.contains('firestorm')) return 'Telugu';
    if (t.contains('dietmountaindew')) return 'English';

    return null;
  }

  static ClassificationResult classify({
    required String? title,
    required String? artist,
    required String? album,
    required Map<String, Map<String, double>> localDb,
  }) {
    // ──────── CASCADE 0: EXPLICIT KEYWORDS ────────
    if (title != null) {
      final explicitLang = matchExplicitLanguage(title);
      if (explicitLang != null) return ClassificationResult.confident(explicitLang, 1.0);
    }
    
    // ──────── CASCADE 0.5: EMERGENCY LEXICON ────────
    final emergencyLang = matchEmergencyHeuristics(title, artist);
    if (emergencyLang != null) return ClassificationResult.confident(emergencyLang, 0.99);

    // ──────── CASCADE 1: UNICODE SCRIPT ────────
    if (title != null) {
      final lang = detectScriptLanguage(title);
      if (lang != null) return ClassificationResult.confident(lang, 0.99);
    }
    if (album != null) {
      final lang = detectScriptLanguage(album);
      if (lang != null) return ClassificationResult.confident(lang, 0.97);
    }

    // ──────── CASCADE 2: ARTIST DATABASE LOOKUP ────────
    if (artist != null && artist.isNotEmpty) {
      final rawArtists = artist.split(RegExp(r'(,|\s&\s|\sand\s|feat\.?|ft\.?|;)'));
      final aggregatedScores = <String, double>{};
      
      for (final raw in rawArtists) {
        if (raw.trim().isEmpty) continue;
        
        final cleanArtist = raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').trim();
        if (cleanArtist.isEmpty) continue;

        bool matched = false;
        
        if (localDb.containsKey(cleanArtist)) {
          localDb[cleanArtist]!.forEach((lang, score) {
            aggregatedScores[lang] = (aggregatedScores[lang] ?? 0.0) + score;
          });
          matched = true;
        }

        if (!matched && cleanArtist.length >= 4) {
          for (final entry in localDb.entries) {
            final dbKey = entry.key;
            if (dbKey.length >= 4 && (cleanArtist.contains(dbKey) || dbKey.contains(cleanArtist))) {
              entry.value.forEach((lang, score) {
                aggregatedScores[lang] = (aggregatedScores[lang] ?? 0.0) + score;
              });
              break; 
            }
          }
        }
      }

      if (aggregatedScores.isNotEmpty) {
        final sorted = aggregatedScores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
        final topLang = sorted[0].key;
        final rawScore = sorted[0].value;
        final topScore = rawScore > 0.99 ? 0.99 : rawScore;
        
        if (sorted.length == 1) {
          if (topScore >= 0.50) return ClassificationResult.confident(topLang, topScore);
          return ClassificationResult.ambiguous(topLang, topScore);
        }
        
        final rawSecond = sorted[1].value;
        final secondScore = rawSecond > 0.99 ? 0.99 : rawSecond;
        final gap = topScore - secondScore;

        if (gap >= 0.15 && topScore >= 0.40) {
          return ClassificationResult.confident(topLang, topScore);
        }
        
        return ClassificationResult.ambiguous(topLang, topScore);
      }
    }

    return ClassificationResult.unknown();
  }
}