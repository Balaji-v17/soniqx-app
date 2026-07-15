// ============================================================
//  SONIQ — lib/audio/equalizer_presets.dart
//  10-band EQ preset library | July 2026
//
//  Bands: 31Hz, 62Hz, 125Hz, 250Hz, 500Hz, 1kHz,
//         2kHz, 4kHz, 8kHz, 16kHz
//  Range: -12dB to +12dB per band
// ============================================================

// ── Band frequency labels ──────────────────────────────────
const List<String> kEqBandLabels = [
  '31', '62', '125', '250', '500', '1K', '2K', '4K', '8K', '16K',
];

const List<int> kEqBandFrequenciesHz = [
  31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000,
];

const double kEqMinDb = -12.0;
const double kEqMaxDb = 12.0;
const int kEqBandCount = 10;

// ── Preset model ───────────────────────────────────────────
class EqPreset {
  final String id;
  final String name;
  final String emoji;
  final List<double> bands; // 10 values, each -12.0 to +12.0 dB
  final bool isCustom;
  final int bassBoost;      // 0–1000 Android strength
  final int virtualizer;    // 0–1000 Android strength

  const EqPreset({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bands,
    this.isCustom = false,
    this.bassBoost = 0,
    this.virtualizer = 0,
  });

  EqPreset copyWith({
    String? id,
    String? name,
    String? emoji,
    List<double>? bands,
    bool? isCustom,
    int? bassBoost,
    int? virtualizer,
  }) => EqPreset(
    id: id ?? this.id,
    name: name ?? this.name,
    emoji: emoji ?? this.emoji,
    bands: bands ?? List.from(this.bands),
    isCustom: isCustom ?? this.isCustom,
    bassBoost: bassBoost ?? this.bassBoost,
    virtualizer: virtualizer ?? this.virtualizer,
  );

  // Flat check — all bands within ±0.5dB of 0
  bool get isFlat => bands.every((b) => b.abs() < 0.5);
}

// ── Built-in presets ──────────────────────────────────────
// Band order: 31 | 62 | 125 | 250 | 500 | 1K | 2K | 4K | 8K | 16K
const List<EqPreset> kBuiltinPresets = [
  EqPreset(
    id: 'flat', name: 'Flat', emoji: '➖',
    bands: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
  ),

  // ── Genre presets ─────────────────────────────────────────
  EqPreset(
    id: 'rock', name: 'Rock', emoji: '🎸',
    bands: [5.0, 4.0, 3.0, 1.0, -1.0, 0.0, 2.0, 4.0, 5.0, 6.0],
    bassBoost: 200,
  ),
  EqPreset(
    id: 'pop', name: 'Pop', emoji: '🌟',
    bands: [-1.0, 2.0, 4.0, 4.0, 1.0, -1.0, -1.0, 0.0, 2.0, 3.0],
  ),
  EqPreset(
    id: 'jazz', name: 'Jazz', emoji: '🎷',
    bands: [3.0, 2.0, 1.0, 2.0, -1.0, -1.0, 0.0, 1.0, 2.0, 3.0],
    virtualizer: 150,
  ),
  EqPreset(
    id: 'classical', name: 'Classical', emoji: '🎻',
    bands: [4.0, 3.0, 2.0, 2.0, -1.0, -1.0, 0.0, 2.0, 3.0, 4.0],
    virtualizer: 200,
  ),
  EqPreset(
    id: 'electronic', name: 'Electronic', emoji: '🎧',
    bands: [5.0, 4.0, 1.0, 0.0, -2.0, 1.0, 1.0, 2.0, 4.0, 5.0],
    bassBoost: 300,
    virtualizer: 300,
  ),
  EqPreset(
    id: 'hiphop', name: 'Hip-Hop', emoji: '🎤',
    bands: [5.0, 4.0, 2.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 2.0],
    bassBoost: 400,
  ),
  EqPreset(
    id: 'rnb', name: 'R&B', emoji: '💜',
    bands: [6.0, 5.0, 2.0, 1.0, -1.0, -1.0, 2.0, 3.0, 4.0, 5.0],
    bassBoost: 350,
    virtualizer: 200,
  ),
  EqPreset(
    id: 'acoustic', name: 'Acoustic', emoji: '🎵',
    bands: [3.0, 2.0, 3.0, 3.0, 2.0, 1.0, 1.0, 1.0, 2.0, 2.0],
  ),
  EqPreset(
    id: 'country', name: 'Country', emoji: '🤠',
    bands: [3.0, 2.0, 1.0, 3.0, 2.0, 1.0, 2.0, 3.0, 3.0, 2.0],
  ),
  EqPreset(
    id: 'dance', name: 'Dance', emoji: '🕺',
    bands: [6.0, 5.0, 2.0, 0.0, -2.0, 2.0, 4.0, 5.0, 4.0, 3.0],
    bassBoost: 500,
    virtualizer: 400,
  ),
  EqPreset(
    id: 'lofi', name: 'Lo-Fi', emoji: '🌙',
    bands: [3.0, 3.0, 2.0, 1.0, 0.0, -1.0, -2.0, -3.0, -4.0, -5.0],
  ),

  // ── Sound enhancement presets ─────────────────────────────
  EqPreset(
    id: 'bass_boost', name: 'Bass Boost', emoji: '🔊',
    bands: [8.0, 7.0, 5.0, 3.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    bassBoost: 700,
  ),
  EqPreset(
    id: 'treble_boost', name: 'Treble Boost', emoji: '✨',
    bands: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 4.0, 6.0, 8.0],
  ),
  EqPreset(
    id: 'vocal', name: 'Vocal Clarity', emoji: '🎙️',
    bands: [-2.0, -1.0, 1.0, 3.0, 5.0, 5.0, 4.0, 2.0, 1.0, -1.0],
  ),
  EqPreset(
    id: 'loudness', name: 'Loudness', emoji: '📣',
    bands: [5.0, 3.0, 1.0, 0.0, 0.0, 0.0, 1.0, 2.0, 3.0, 4.0],
    bassBoost: 300,
    virtualizer: 200,
  ),
  EqPreset(
    id: 'late_night', name: 'Late Night', emoji: '🌃',
    bands: [2.0, 2.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 2.0, 2.0],
    bassBoost: 150,
  ),
  EqPreset(
    id: 'small_speaker', name: 'Small Speaker', emoji: '📱',
    bands: [4.0, 3.0, 2.0, 1.0, 0.0, 0.0, 1.0, 3.0, 4.0, 4.0],
  ),

  // ── Indian music presets (SONIQ-specific) ─────────────────
  EqPreset(
    id: 'bollywood', name: 'Bollywood', emoji: '🎬',
    bands: [3.0, 3.0, 2.0, 0.0, 0.0, 1.0, 2.0, 3.0, 2.0, 2.0],
    bassBoost: 200,
    virtualizer: 150,
  ),
  EqPreset(
    id: 'carnatic', name: 'Carnatic', emoji: '🪘',
    bands: [1.0, 1.0, 0.0, -1.0, 0.0, 3.0, 4.0, 4.0, 3.0, 2.0],
    virtualizer: 100,
  ),
  EqPreset(
    id: 'folk', name: 'Folk & Devotional', emoji: '🪗',
    bands: [4.0, 3.0, 3.0, 2.0, 1.0, 2.0, 2.0, 2.0, 1.0, 0.0],
  ),
  EqPreset(
    id: 'hindustani', name: 'Hindustani', emoji: '🎼',
    bands: [4.0, 3.0, 1.0, 0.0, 1.0, 2.0, 3.0, 4.0, 4.0, 3.0],
    virtualizer: 200,
  ),
];