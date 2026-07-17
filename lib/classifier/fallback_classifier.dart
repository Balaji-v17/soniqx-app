// ============================================================
//  SONIQ — lib/classifier/fallback_classifier.dart
//  Metadata-stripped file language detection
// ============================================================

class FilenameSanitizer {
  static final _quality = RegExp(
    r'\b(128|160|192|256|320|64|96)\s*kbps?\b',
    caseSensitive: false,
  );
  
  static final _format = RegExp(
    r'\b(mp3|mp4|m4a|flac|aac|ogg|opus|wav|wma|ape|alac|aiff)\b',
    caseSensitive: false,
  );
  
  static final _watermarks = RegExp(
    r'(?:'
    r'www\.[a-z0-9\-]+\.[a-z]{2,}'   
    r'|djpunjab|pagalworld|songs\.pk|vidmate|mr\s*jatt|mr\.jatt|mrjatt'
    r'|raagsong|mp3tau|mp3quack|bestwap|wapking|waploft|downloadming'
    r'|songspk|hindilinks4u|bollywood4u|djtunes|gaana|saavn|wynk|hungama'
    r'|jiosaavn|spotify'
    r')',
    caseSensitive: false,
  );

  static final _brackets = RegExp(r'\([^)]*\)|\[[^\]]*\]|\{[^}]*\}');
  
  static final _genericTerms = RegExp(
    r'\b(?:'
    r'official|lyric(?:s|al)?|audio|video|hd|hq|full|song|music'
    r'|download|free|new|latest|2023|2024|2025|2026'
    r'|remix|mashup|cover|version|mix|edit|extended'
    r'|feat(?:uring)?|ft|x' 
    r'|4k|8k|1080p|720p|480p'
    r'|dj\s*\w+'
    r'|www|http|https|com|net|org'
    r')\b',
    caseSensitive: false,
  );

  static final _trackNumber = RegExp(r'^(?:track\s*)?\d{1,3}[\s._\-]+');
  static final _separators = RegExp(r'[_\-\.]+');
  static final _multiSpace = RegExp(r'\s{2,}');

  static final _emojis = RegExp(
    r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}'
    r'\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}'
    r'\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}'
    r'\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', 
    unicode: true,
  );

  static String sanitize(String rawFilename) {
    var s = rawFilename.replaceAll(RegExp(r'\.[a-zA-Z0-9]{2,5}$'), '');
    s = s.replaceAll(_emojis, ' '); 
    s = s.replaceAll(_brackets, ' ');
    s = s.replaceAll(_watermarks, ' ');
    s = s.replaceAll(_quality, ' ');
    s = s.replaceAll(_format, ' ');
    s = s.replaceAll(_trackNumber, '');
    s = s.replaceAll(_separators, ' ');
    s = s.replaceAll(_genericTerms, ' ');
    return s.replaceAll(_multiSpace, ' ').trim();
  }

  static List<String> tokenize(String sanitized) {
    return sanitized
        .split(' ')
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.length >= 2)
        .toList();
  }

  static List<String> extractArtistCandidates(List<String> tokens) {
    final candidates = <String>[];
    candidates.addAll(tokens);
    for (int i = 0; i < tokens.length - 1; i++) {
      candidates.add('${tokens[i]} ${tokens[i + 1]}');
    }
    for (int i = 0; i < tokens.length - 2; i++) {
      candidates.add('${tokens[i]} ${tokens[i + 1]} ${tokens[i + 2]}');
    }
    return candidates;
  }
}

class FolderPathAnalyzer {
  static const Map<String, List<String>> _folderKeywords = {
    'Kannada': ['kannada', 'kannad', 'sandalwood', 'kn songs', 'ಕನ್ನಡ'],
    'Tamil': ['tamil', 'kollywood', 'tamilsongs', 'ta songs', 'தமிழ்'],
    'Telugu': ['telugu', 'tollywood', 'telugumusic', 'te songs', 'తెలుగు'],
    'Malayalam': ['malayalam', 'mollywood', 'malayali', 'ml songs', 'മലയാളം'],
    'Hindi': ['hindi', 'bollywood', 'hind', 'hindi songs', 'hindi music', 'हिंदी', 'बॉलीवुड'],
    'Punjabi': ['punjabi', 'punjab', 'pollywood', 'bhangra', 'ਪੰਜਾਬੀ'],
    'Bengali': ['bengali', 'bangla', 'tollywood bengali', 'বাংলা'],
    'English': ['english', 'western', 'international', 'english songs', 'pop', 'rock', 'edm'],
  };

  static Map<String, double> analyze(String filePath) {
    final scores = <String, double>{};
    final parts = filePath.replaceAll('\\', '/').split('/');
    if (parts.length < 2) return scores;

    final dirsToCheck = <MapEntry<String, double>>[];
    if (parts.length >= 2) dirsToCheck.add(MapEntry(parts[parts.length - 2], 0.72));
    if (parts.length >= 3) dirsToCheck.add(MapEntry(parts[parts.length - 3], 0.60));

    for (final dirEntry in dirsToCheck) {
      final dirLower = dirEntry.key.toLowerCase();
      final weight   = dirEntry.value;
      for (final langEntry in _folderKeywords.entries) {
        final lang     = langEntry.key;
        final keywords = langEntry.value;
        for (final keyword in keywords) {
          if (dirLower.contains(keyword.toLowerCase())) {
            scores[lang] = [scores[lang] ?? 0.0, weight].reduce((a, b) => a > b ? a : b);
            break; 
          }
        }
      }
    }
    return scores;
  }
}

class ScriptDetector {
  static const Map<String, List<List<int>>> _scriptRanges = {
    'Kannada':   [[0x0C80, 0x0CFF]],
    'Tamil':     [[0x0B80, 0x0BFF]],
    'Telugu':    [[0x0C00, 0x0C7F]],
    'Malayalam': [[0x0D00, 0x0D7F]],
    'Hindi':     [[0x0900, 0x097F]],   
    'Punjabi':   [[0x0A00, 0x0A7F]],   
    'Bengali':   [[0x0980, 0x09FF]],
    'Gujarati':  [[0x0A80, 0x0AFF]],
    'Odia':      [[0x0B00, 0x0B7F]],
  };

  static ScriptResult? detect(String text) {
    for (final rune in text.runes) {
      for (final entry in _scriptRanges.entries) {
        final lang   = entry.key;
        final ranges = entry.value;
        for (final range in ranges) {
          if (rune >= range[0] && rune <= range[1]) {
            final confidence = lang == 'Hindi' ? 0.88 : 0.97;
            return ScriptResult(language: lang, confidence: confidence);
          }
        }
      }
    }
    return null; 
  }
}

class ScriptResult {
  final String language;
  final double confidence;
  const ScriptResult({required this.language, required this.confidence});
}

class FallbackClassificationResult {
  final String? language;
  final double confidence;
  final String signalSource;
  final bool shouldAutoTag;

  const FallbackClassificationResult({
    required this.language,
    required this.confidence,
    required this.signalSource,
    required this.shouldAutoTag,
  });

  static const unclassified = FallbackClassificationResult(
    language:      null,
    confidence:    0.0,
    signalSource:  'none',
    shouldAutoTag: false,
  );
}

class FallbackClassifier {
  final Map<String, Map<String, double>> _seedDb;
  final Map<String, String> _albumPatterns;
  static const double _autoTagThreshold   = 0.65;
  static const double _manualTagThreshold = 0.40;

  FallbackClassifier({
    required Map<String, Map<String, double>> seedDb,
    required Map<String, String> albumPatterns,
  })  : _seedDb        = seedDb,
        _albumPatterns = albumPatterns;

  FallbackClassificationResult classify(String filePath) {
    final filename  = _basename(filePath);
    final sanitized = FilenameSanitizer.sanitize(filename);

    final filenameScript = ScriptDetector.detect(filename);
    if (filenameScript != null) {
      return FallbackClassificationResult(
        language:     filenameScript.language,
        confidence:   filenameScript.confidence,
        signalSource: 'filename_script',
        shouldAutoTag: filenameScript.confidence >= _autoTagThreshold,
      );
    }

    final pathScript = ScriptDetector.detect(filePath);
    if (pathScript != null) {
      return FallbackClassificationResult(
        language:     pathScript.language,
        confidence:   pathScript.confidence * 0.97, 
        signalSource: 'folder_script',
        shouldAutoTag: true,
      );
    }

    final tokens     = FilenameSanitizer.tokenize(sanitized);
    final candidates = FilenameSanitizer.extractArtistCandidates(tokens);
    final artistResult = _lookupArtists(candidates);
    if (artistResult != null) return artistResult;

    final albumResult = _matchAlbumPatterns(sanitized);
    if (albumResult != null) return albumResult;

    final folderScores = FolderPathAnalyzer.analyze(filePath);
    if (folderScores.isNotEmpty) {
      final topEntry = folderScores.entries.reduce((a, b) => a.value > b.value ? a : b);
      return FallbackClassificationResult(
        language:      topEntry.key,
        confidence:    topEntry.value,
        signalSource:  'folder_keyword',
        shouldAutoTag: topEntry.value >= _autoTagThreshold,
      );
    }

    final keywordResult = _detectKeywordInTokens(tokens);
    if (keywordResult != null) return keywordResult;

    return FallbackClassificationResult.unclassified;
  }

  FallbackClassificationResult? _lookupArtists(List<String> candidates) {
    final scores = <String, double>{};
    for (final candidate in candidates) {
      final entry = _seedDb[candidate];
      if (entry == null) continue;
      for (final langEntry in entry.entries) {
        final lang   = langEntry.key;
        final weight = langEntry.value;
        scores[lang] = [scores[lang] ?? 0.0, weight].reduce((a, b) => a > b ? a : b);
      }
    }
    if (scores.isEmpty) return null;
    
    final sorted = scores.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topLang  = sorted.first.key;
    final topScore = sorted.first.value;
    final gap      = sorted.length > 1 ? topScore - sorted[1].value : topScore;

    if (gap < 0.25 || topScore < 0.55) return null;

    final confidence = topScore * 0.87;
    return FallbackClassificationResult(
      language:      topLang,
      confidence:    confidence,
      signalSource:  'filename_artist_db',
      shouldAutoTag: confidence >= _autoTagThreshold,
    );
  }

  FallbackClassificationResult? _matchAlbumPatterns(String sanitized) {
    final lower = sanitized.toLowerCase();
    for (final entry in _albumPatterns.entries) {
      if (lower.contains(entry.key)) {
        return FallbackClassificationResult(
          language:     entry.value,
          confidence:   0.78,
          signalSource: 'album_pattern',
          shouldAutoTag: true,
        );
      }
    }
    return null;
  }

  FallbackClassificationResult? _detectKeywordInTokens(List<String> tokens) {
    const Map<String, List<String>> languageKeywords = {
      'Hindi':     ['hindi', 'bollywood', 'bharat', 'desi'],
      'Kannada':   ['kannada', 'sandalwood', 'kn'],
      'Tamil':     ['tamil', 'kollywood', 'thamizh'],
      'Telugu':    ['telugu', 'tollywood'],
      'Malayalam': ['malayalam', 'mollywood', 'mallu'],
      'Punjabi':   ['punjabi', 'bhangra', 'pollywood'],
      'English':   ['english', 'western', 'remix'],
    };
    for (final token in tokens) {
      for (final entry in languageKeywords.entries) {
        if (entry.value.contains(token)) {
          return FallbackClassificationResult(
            language:     entry.key,
            confidence:   0.62,
            signalSource: 'filename_keyword',
            shouldAutoTag: false, 
          );
        }
      }
    }
    return null;
  }

  String _basename(String path) {
    final parts = path.replaceAll('\\', '/').split('/');
    return parts.isEmpty ? path : parts.last;
  }
}

class SiblingConsensusPass {
  static const double _consensusThreshold = 0.65; 
  static const int    _minSiblingsNeeded  = 3;    

  static Map<String, _ConsensusResult> run({
    required List<String> unclassifiedPaths,
    required Map<String, String> allClassified,
  }) {
    final results = <String, _ConsensusResult>{};
    for (final path in unclassifiedPaths) {
      final dir = _dirname(path);
      final siblings = allClassified.entries.where((e) => _dirname(e.key) == dir).toList();
      if (siblings.length < _minSiblingsNeeded) continue;

      final tally = <String, int>{};
      for (final s in siblings) {
        tally[s.value] = (tally[s.value] ?? 0) + 1;
      }
      final topEntry = tally.entries.reduce((a, b) => a.value > b.value ? a : b);
      final consensusRatio = topEntry.value / siblings.length;

      if (consensusRatio >= _consensusThreshold) {
        results[path] = _ConsensusResult(
          language:   topEntry.key,
          confidence: consensusRatio * 0.65,
          siblingCount: siblings.length,
          consensusRatio: consensusRatio,
        );
      }
    }
    return results;
  }

  static String _dirname(String path) {
    final parts = path.replaceAll('\\', '/').split('/');
    if (parts.length < 2) return '';
    return parts.sublist(0, parts.length - 1).join('/');
  }
}

class _ConsensusResult {
  final String language;
  final double confidence;
  final int    siblingCount;
  final double consensusRatio;
  const _ConsensusResult({
    required this.language,
    required this.confidence,
    required this.siblingCount,
    required this.consensusRatio,
  });
}

class UnclassifiedSongState {
  static const String? untaggedDbValue = null;
  static const String pendingDbValue = '__pending__';
  static const String untaggedDisplayLabel = 'Unclassified';
  static const String pendingDisplayLabel = 'Needs Review';

  static String? dbValue(FallbackClassificationResult result) {
    if (result.language == null) return untaggedDbValue;
    if (!result.shouldAutoTag) return pendingDbValue;
    return result.language; 
  }
}