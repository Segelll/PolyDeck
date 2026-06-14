import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/domain/models/word.dart';

void main() {
  group('Word', () {
    final testMap = {
      'id': 42,
      'word': 'hello',
      'sentence': 'Hello, how are you?',
      'level': 'A1',
      'isSeen': 1,
      'feedback': 2,
      'date': '2025-06-14',
      'backword': 'merhaba',
      'backsentence': 'Merhaba, nasılsın?',
    };

    test('fromMap creates correct Word instance', () {
      final word = Word.fromMap(testMap);

      expect(word.id, 42);
      expect(word.word, 'hello');
      expect(word.sentence, 'Hello, how are you?');
      expect(word.level, 'A1');
      expect(word.isSeen, 1);
      expect(word.feedback, 2);
      expect(word.date, '2025-06-14');
      expect(word.backWord, 'merhaba');
      expect(word.backSentence, 'Merhaba, nasılsın?');
    });

    test('fromMap handles missing optional fields', () {
      final minimal = Word.fromMap({'id': 1});

      expect(minimal.id, 1);
      expect(minimal.word, '');
      expect(minimal.sentence, '');
      expect(minimal.isSeen, 0);
      expect(minimal.feedback, 0);
      expect(minimal.date, isNull);
    });

    test('toMap produces correct map', () {
      final word = Word.fromMap(testMap);
      final map = word.toMap();

      expect(map['id'], 42);
      expect(map['word'], 'hello');
      expect(map['sentence'], 'Hello, how are you?');
      expect(map['level'], 'A1');
      expect(map['isSeen'], 1);
      expect(map['feedback'], 2);
      expect(map['date'], '2025-06-14');
    });

    test('copyWith creates modified copy', () {
      final original = Word.fromMap(testMap);
      final modified = original.copyWith(word: 'goodbye', isSeen: 0);

      expect(modified.word, 'goodbye');
      expect(modified.isSeen, 0);
      // Unchanged fields
      expect(modified.id, original.id);
      expect(modified.level, original.level);
    });
  });
}
