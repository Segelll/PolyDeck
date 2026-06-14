import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/domain/enums/feedback_type.dart';

void main() {
  group('FeedbackType', () {
    test('fromValue returns correct enum for known values', () {
      expect(FeedbackType.fromValue(1), FeedbackType.hard);
      expect(FeedbackType.fromValue(2), FeedbackType.easy);
      expect(FeedbackType.fromValue(3), FeedbackType.medium);
    });

    test('fromValue defaults to hard for unknown values', () {
      expect(FeedbackType.fromValue(0), FeedbackType.hard);
      expect(FeedbackType.fromValue(99), FeedbackType.hard);
    });

    test('each enum has a unique integer value', () {
      final values = FeedbackType.values.map((e) => e.value).toSet();
      expect(values.length, FeedbackType.values.length);
    });
  });
}
