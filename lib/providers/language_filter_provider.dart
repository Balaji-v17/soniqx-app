// ============================================================
//  SONIQ — lib/providers/language_filter_provider.dart
//  Holds the currently selected language filter state.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

// null means "All Tracks" is selected
final languageFilterProvider = StateProvider<String?>((ref) => null);