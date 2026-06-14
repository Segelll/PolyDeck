import 'dart:math';

/// Generates a set of [count] unique random integers in the range [min, max] (inclusive).
///
/// Used by exam question generation and distractor selection.
List<int> generateRandomIds(int min, int max, int count) {
  final random = Random();
  final Set<int> ids = {};
  while (ids.length < count) {
    ids.add(min + random.nextInt(max - min + 1));
  }
  return ids.toList();
}
