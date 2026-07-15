import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortField { title, artist, album, dateAdded, duration }
enum SortOrder { ascending, descending }

class SortConfig {
  final SortField field;
  final SortOrder order;
  const SortConfig({this.field = SortField.dateAdded, this.order = SortOrder.descending});
}

final sortProvider = StateProvider<SortConfig>((ref) => const SortConfig());