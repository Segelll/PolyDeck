import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/domain/enums/rating.dart';

void main() {
  group('Rating', () {
    test('values match FSRS spec', () {
      expect(Rating.again.value, 1);
      expect(Rating.hard.value, 2);
      expect(Rating.good.value, 3);
      expect(Rating.easy.value, 4);
    });

    test('fromValue returns correct rating', () {
      expect(Rating.fromValue(1), Rating.again);
      expect(Rating.fromValue(2), Rating.hard);
      expect(Rating.fromValue(3), Rating.good);
      expect(Rating.fromValue(4), Rating.easy);
    });

    test('fromValue defaults to good for unknown values', () {
      expect(Rating.fromValue(0), Rating.good);
      expect(Rating.fromValue(99), Rating.good);
    });
  });
}
