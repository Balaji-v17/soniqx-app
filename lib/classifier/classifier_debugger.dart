// ============================================================
//  SONIQ — lib/classifier/classifier_debugger.dart
//
//  Drop this file in temporarily. Call debugClassifySong() on
//  any misclassified song and it prints the exact decision at
//  every tier so you can see where the pipeline breaks.
//
//  Usage (in your scan notifier or a debug screen):
//    ClassifierDebugger.debugClassifySong(
//      title: 'Rowdy Baby',
//      artist: 'Dhanush, Dhee',
//      filePath: '/storage/emulated/0/Music/Tamil/Rowdy Baby.mp3',
//    );
//
//  REMOVE BEFORE PLAY STORE SUBMISSION
// ============================================================

class ClassifierDebugger {
  static void debugClassifySong({
    required String? title,
    required String? artist,
    required String filePath,
  }) {
    final divider = '─' * 60;
    final log = StringBuffer();

    log.writeln('\n$divider');
    log.writeln('CLASSIFIER DEBUG');
    log.writeln('  title   : ${title ?? "(null)"}');
    log.writeln('  artist  : ${artist ?? "(null)"}');
    log.writeln('  path    : $filePath');
    log.writeln(divider);

    // ── 1. Normalization diagnostics ─────────────────────────
    log.writeln('\n[NORMALIZATION]');
    if (artist != null && artist.isNotEmpty) {
      final splits = _splitArtist(artist);
      log.writeln('  Split result (${splits.length} tokens):');
      for (final s in splits) {
        final normalized = _normalize(s);
        log.writeln('    raw: "$s" → normalized: "$normalized"');
      }

      log.writeln('\n  N-gram candidates generated:');
      final allCandidates = splits
          .map(_normalize)
          .where((s) => s.length >= 2)
          .toList();
      final ngrams = _generateNgrams(allCandidates);
      for (final c in ngrams) {
        log.writeln('    "$c"');
      }
    } else {
      log.writeln('  artist is null/empty — Tier 1 will be skipped entirely');
    }

    // ── 2. Seed DB lookup diagnostic ─────────────────────────
    log.writeln('\n[TIER 1 — SEED DB LOOKUP]');
    if (artist != null && artist.isNotEmpty) {
      final splits   = _splitArtist(artist);
      final ngrams   = _generateNgrams(splits.map(_normalize).toList());
      final scores   = <String, double>{};
      bool anyHit    = false;

      for (final candidate in ngrams) {
        // Replace this with your actual seed DB lookup
        // final entry = LanguageSeedDb.instance.lookup(candidate);
        final entry = _mockSeedDbLookup(candidate);

        if (entry != null) {
          anyHit = true;
          log.writeln('  HIT: "$candidate" → $entry');
          entry.forEach((lang, weight) {
            scores[lang] = (scores[lang] ?? 0.0) + weight;
          });
        } else {
          log.writeln('  MISS: "$candidate" → not in seed DB');
        }
      }

      if (anyHit) {
        log.writeln('\n  Aggregated scores: $scores');
        final sorted = scores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sorted.isNotEmpty) {
          final top    = sorted.first;
          final second = sorted.length > 1 ? sorted[1].value : 0.0;
          final gap    = top.value - second;

          log.writeln('  Top language: ${top.key} (${top.value.toStringAsFixed(2)})');
          log.writeln('  Gap from #2:  ${gap.toStringAsFixed(2)} '
              '(need > 0.35 to auto-classify)');
          if (gap < 0.35) {
            log.writeln('  ⚠️  GAP TOO SMALL — polyglot artist, '
                'falling through to Tier 2');
          }
        }
      } else {
        log.writeln('\n  ⚠️  ZERO SEED DB HITS — all tokens missed');
        log.writeln('  This is why everything falls to Tier 2');
      }
    }

    // ── 3. Folder path analysis diagnostic ───────────────────
    log.writeln('\n[TIER 2 — FOLDER PATH ANALYSIS]');
    final segments = filePath.replaceAll('\\', '/').split('/');
    log.writeln('  Path segments: $segments');
    
    // Check parent and grandparent directory names
    for (int i = segments.length - 2; i >= 0 && i >= segments.length - 3; i--) {
      final seg = segments[i];
      log.writeln('  Checking segment: "$seg"');
      for (final lang in _folderKeywords.keys) {
        for (final keyword in _folderKeywords[lang]!) {
          if (seg.toLowerCase().contains(keyword.toLowerCase())) {
            log.writeln('    HIT: "$keyword" → $lang');
          }
        }
      }
    }

    // ── 4. Filename token diagnostic ─────────────────────────
    log.writeln('\n[TIER 2 — FILENAME TOKENS]');
    final basename = filePath.split('/').last;
    final sanitized = _sanitizeFilename(basename);
    log.writeln('  Raw filename:  "$basename"');
    log.writeln('  Sanitized:     "$sanitized"');

    final tokens = sanitized
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2)
        .toList();
    
    log.writeln('  Tokens: $tokens');

    for (final token in tokens) {
      for (final lang in _languageKeywords.keys) {
        if (_languageKeywords[lang]!.contains(token)) {
          log.writeln('  Keyword hit: "$token" → $lang');
        }
      }
    }

    log.writeln('\n$divider\n');
    
    // Print all at once so output isn't interleaved with other logs
    print(log.toString());
  }

  // ── Helpers (these must match your actual classifier exactly) ──

  static List<String> _splitArtist(String artist) {
    return artist
        .split(RegExp(r',|&|feat\.?|ft\.?|×|✕|और|ಮತ್ತು',
            caseSensitive: false))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  static String _normalize(String raw) {
    return raw
        .trim()
        .toLowerCase()
        // Remove dots that appear BEFORE a space or at end: "V." → "V"
        // This prevents "V. Sridhar" → "V Sridhar" vs "vsridhar"
        .replaceAll(RegExp(r'\.(?=\s|$)'), '')
        // Remove dots between letters that have NO space: "V.Sridhar" → "V Sridhar"
        .replaceAll(RegExp(r'(?<=[a-z])\.(?=[a-z])', caseSensitive: false), ' ')
        // Remove remaining special characters (except spaces)
        .replaceAll(RegExp(r'[^\w\s]'), '')
        // Collapse multiple spaces
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  static List<String> _generateNgrams(List<String> tokens) {
    final result = <String>[];
    for (final t in tokens) {
      if (t.length >= 2) result.add(t);
    }
    // Bigrams across adjacent tokens (for multi-word artist names)
    for (int i = 0; i < tokens.length - 1; i++) {
      result.add('${tokens[i]} ${tokens[i + 1]}');
    }
    // Trigrams
    for (int i = 0; i < tokens.length - 2; i++) {
      result.add('${tokens[i]} ${tokens[i + 1]} ${tokens[i + 2]}');
    }
    return result;
  }

  static String _sanitizeFilename(String filename) {
    return filename
        .replaceAll(RegExp(r'\.[a-zA-Z0-9]{2,5}$'), '')
        .replaceAll(RegExp(r'\([^)]*\)|\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'[_\-\.]+'), ' ')
        .replaceAll(RegExp(r'\b(128|192|256|320)\s*kbps?\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b(official|audio|video|hd|lyrics?)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  // STUB — replace with your actual seed DB lookup in real classifier
  static Map<String, double>? _mockSeedDbLookup(String key) => null;

  static const Map<String, List<String>> _folderKeywords = {
    'Kannada':   ['kannada', 'sandalwood', 'ಕನ್ನಡ'],
    'Tamil':     ['tamil', 'kollywood', 'தமிழ்'],
    'Telugu':    ['telugu', 'tollywood', 'తెలుగు'],
    'Malayalam': ['malayalam', 'mollywood', 'മലയാളം'],
    'Hindi':     ['hindi', 'bollywood', 'हिंदी'],
    'Punjabi':   ['punjabi', 'bhangra', 'ਪੰਜਾਬੀ'],
    'English':   ['english', 'western'],
  };

  static const Map<String, List<String>> _languageKeywords = {
    'Hindi':     ['hindi', 'bollywood'],
    'Kannada':   ['kannada', 'sandalwood'],
    'Tamil':     ['tamil', 'kollywood', 'thamizh'],
    'Telugu':    ['telugu', 'tollywood'],
    'Malayalam': ['malayalam', 'mollywood'],
    'Punjabi':   ['punjabi', 'bhangra'],
    'English':   ['english'],
  };
}

void main() {
  ClassifierDebugger.debugClassifySong(
    title: 'Rowdy Baby',
    artist: 'Dhanush, Dhee',
    filePath: '/storage/emulated/0/Download/Rowdy Baby.mp3',
  );

  ClassifierDebugger.debugClassifySong(
    title: 'Yenagali',
    artist: 'V. Sridhar, Sonu Nigam',
    filePath: '/storage/emulated/0/Music/Yenagali.mp3',
  );
}
