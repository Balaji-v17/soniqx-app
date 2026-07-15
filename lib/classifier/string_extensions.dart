// ============================================================
//  SONIQ — lib/classifier/string_extensions.dart
//  Text cleansing for AI matching.
// ============================================================

extension ArtistNormalization on String {
  /// Cleans messy ID3 tags to perfectly match the seed database keys.
  String toNormalizedArtist() {
    String raw = toLowerCase();

    // 🎯 FIX for Bottleneck B6: Compound artist splitting
    // Strip everything after a comma, ampersand, or '×' so we only look up the primary artist
    raw = raw.split(',').first;
    raw = raw.split('&').first;
    raw = raw.split('×').first;

    // 1. Remove "feat." and "ft." and everything after it
    // Example: "arijit singh feat. shreya" -> "arijit singh "
    raw = raw.replaceAll(RegExp(r'\bfeat\.?\b.*'), '');
    raw = raw.replaceAll(RegExp(r'\bft\.?\b.*'), '');
    
    // 2. Remove dots from initials
    // Example: "a.r. rahman" -> "ar rahman"
    raw = raw.replaceAll(RegExp(r'\.'), '');
    
    // 3. Remove all other special characters (brackets, hyphens, etc.)
    // Example: "spb (official)" -> "spb  official "
    raw = raw.replaceAll(RegExp(r'[^\w\s]'), '');
    
    // 4. Collapse multiple spaces into a single space and trim edges
    // Example: "ar  rahman " -> "ar rahman"
    raw = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return raw;
  }
}