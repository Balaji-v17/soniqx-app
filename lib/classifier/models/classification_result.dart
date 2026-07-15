// ============================================================
//  SONIQ — lib/classifier/models/classification_result.dart
//  Output model for the Language Classifier Engine.
// ============================================================

class ClassificationResult {
  final String? language;
  final double confidence;
  final List<String> signalsFired;
  final bool needsManual;

  const ClassificationResult({
    required this.language,
    required this.confidence,
    required this.signalsFired,
    required this.needsManual,
  });

  @override
  String toString() {
    return 'ClassificationResult(lang: $language, conf: ${confidence.toStringAsFixed(2)}, manual: $needsManual, signals: $signalsFired)';
  }
}