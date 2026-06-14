import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/domain/enums/card_state.dart';

void main() {
  group('CardState', () {
    test('values match FSRS spec', () {
      expect(CardState.new_.value, 0);
      expect(CardState.learning.value, 1);
      expect(CardState.review.value, 2);
      expect(CardState.relearning.value, 3);
    });

    test('fromValue returns correct state', () {
      expect(CardState.fromValue(0), CardState.new_);
      expect(CardState.fromValue(1), CardState.learning);
      expect(CardState.fromValue(2), CardState.review);
      expect(CardState.fromValue(3), CardState.relearning);
    });

    test('fromValue defaults to new for unknown values', () {
      expect(CardState.fromValue(-1), CardState.new_);
      expect(CardState.fromValue(99), CardState.new_);
    });
  });
}
