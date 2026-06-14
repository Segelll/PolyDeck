import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/domain/models/revlog_entry.dart';

void main() {
  group('RevlogEntry', () {
    test('fromMap and toMap roundtrip', () {
      final entry = RevlogEntry(
        id: 1,
        cardId: 42,
        deckTable: 'en',
        rating: 3,
        state: 2,
        due: '2025-06-14',
        stability: 5.0,
        difficulty: 3.5,
        elapsedDays: 2,
        lastElapsedDays: 1,
        scheduledDays: 7,
        reviewDate: '2025-06-14T10:30:00',
      );

      final map = entry.toMap();
      final restored = RevlogEntry.fromMap(map);

      expect(restored.id, 1);
      expect(restored.cardId, 42);
      expect(restored.deckTable, 'en');
      expect(restored.rating, 3);
      expect(restored.state, 2);
      expect(restored.due, '2025-06-14');
      expect(restored.stability, 5.0);
      expect(restored.difficulty, 3.5);
      expect(restored.elapsedDays, 2);
      expect(restored.lastElapsedDays, 1);
      expect(restored.scheduledDays, 7);
      expect(restored.reviewDate, '2025-06-14T10:30:00');
    });

    test('fromMap handles missing id', () {
      final entry = RevlogEntry.fromMap({
        'card_id': 1,
        'deck_table': 'en',
        'rating': 1,
        'state': 0,
        'due': '2025-01-01',
        'stability': 0.0,
        'difficulty': 0.0,
        'elapsed_days': 0,
        'scheduled_days': 0,
        'review_date': '2025-01-01T00:00:00',
      });

      expect(entry.id, isNull);
      expect(entry.lastElapsedDays, 0);
    });

    test('toMap excludes null id', () {
      final entry = RevlogEntry(
        cardId: 1,
        deckTable: 'tr',
        rating: 2,
        state: 1,
        due: '2025-01-01',
        stability: 1.0,
        difficulty: 5.0,
        elapsedDays: 0,
        scheduledDays: 1,
        reviewDate: '2025-01-01T00:00:00',
      );

      final map = entry.toMap();
      expect(map.containsKey('id'), false);
    });
  });
}
