import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/core/constants/language_codes.dart';

void main() {
  group('LanguageCodes', () {
    group('tableNameFor', () {
      test('returns correct table name for Portuguese', () {
        expect(LanguageCodes.tableNameFor('pt'), 'pr');
      });

      test('returns correct table name for Spanish', () {
        expect(LanguageCodes.tableNameFor('es'), 'esp');
      });

      test('returns same code for standard languages', () {
        expect(LanguageCodes.tableNameFor('en'), 'en');
        expect(LanguageCodes.tableNameFor('tr'), 'tr');
        expect(LanguageCodes.tableNameFor('de'), 'de');
        expect(LanguageCodes.tableNameFor('fr'), 'fr');
        expect(LanguageCodes.tableNameFor('it'), 'it');
      });
    });

    group('displayCodeFor', () {
      test('returns correct display code for Portuguese table', () {
        expect(LanguageCodes.displayCodeFor('pr'), 'pt');
      });

      test('returns correct display code for Spanish table', () {
        expect(LanguageCodes.displayCodeFor('esp'), 'es');
      });

      test('returns same code for standard language tables', () {
        expect(LanguageCodes.displayCodeFor('en'), 'en');
        expect(LanguageCodes.displayCodeFor('tr'), 'tr');
      });
    });

    test('displayCodes contains only proper ISO codes', () {
      expect(LanguageCodes.displayCodes, [
        'en', 'tr', 'de', 'fr', 'it', 'pt', 'es',
      ]);
    });

    test('round-trip conversion is consistent', () {
      for (final code in LanguageCodes.displayCodes) {
        final table = LanguageCodes.tableNameFor(code);
        final display = LanguageCodes.displayCodeFor(table);
        expect(display, code,
            reason: 'Round-trip failed for $code: table=$table, display=$display');
      }
    });
  });
}
