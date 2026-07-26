import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/pigeon/language_classifier.gen.dart',
  kotlinOut: 'android/app/src/main/kotlin/com/soniq/app/LanguageClassifierGen.kt',
  kotlinOptions: KotlinOptions(package: 'com.soniq.app'),
))

class ClassificationResult {
  final String languageTag;
  final double confidence;

  ClassificationResult({
    required this.languageTag, 
    required this.confidence
  });
}

@HostApi()
abstract class FastTextClassifierApi {
  @async
  ClassificationResult classifyText(String text);
}