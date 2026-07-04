import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/core/constants/language_codes.dart';

void main() {
  group('LanguageCodes', () {
    group('tableNameFor', () {
      test('returns same ISO code for Portuguese (unified DB)', () {
        expect(LanguageCodes.tableNameFor('pt'), 'pt');
      });

      test('returns same ISO code for Spanish (unified DB)', () {
        expect(LanguageCodes.tableNameFor('es'), 'es');
      });

      test('returns same code for standard languages', () {
        expect(LanguageCodes.tableNameFor('en'), 'en');
        expect(LanguageCodes.tableNameFor('tr'), 'tr');
        expect(LanguageCodes.tableNameFor('de'), 'de');
        expect(LanguageCodes.tableNameFor('fr'), 'fr');
        expect(LanguageCodes.tableNameFor('it'), 'it');
      });

      test('normalizes legacy pr/esp to pt/es', () {
        expect(LanguageCodes.tableNameFor('pr'), 'pt',
            reason: 'Legacy "pr" code should normalize to "pt"');
        expect(LanguageCodes.tableNameFor('esp'), 'es',
            reason: 'Legacy "esp" code should normalize to "es"');
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
        expect(LanguageCodes.displayCodeFor('pt'), 'pt');
        expect(LanguageCodes.displayCodeFor('es'), 'es');
      });
    });

    test('displayCodes contains only proper ISO codes', () {
      expect(LanguageCodes.displayCodes, [
        'en', 'tr', 'de', 'fr', 'it', 'pt', 'es',
      ]);
    });

    test('tableNames contains only proper ISO codes', () {
      expect(LanguageCodes.tableNames, [
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
