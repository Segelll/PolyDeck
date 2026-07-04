import 'package:flutter_test/flutter_test.dart';
import 'package:poly2/core/constants/language_codes.dart';

void main() {
  group('LanguageCodes', () {
    test('displayCodes contains all 7 ISO 639-1 codes', () {
      expect(LanguageCodes.displayCodes, [
        'en', 'tr', 'de', 'fr', 'it', 'pt', 'es',
      ]);
    });

    test('tableNameFor is identity (DB and display codes are identical)', () {
      for (final code in LanguageCodes.displayCodes) {
        expect(LanguageCodes.tableNameFor(code), code);
      }
    });

    test('displayCodeFor is identity (DB and display codes are identical)', () {
      for (final code in LanguageCodes.displayCodes) {
        expect(LanguageCodes.displayCodeFor(code), code);
      }
    });

    test('round-trip is identity', () {
      for (final code in LanguageCodes.displayCodes) {
        expect(
          LanguageCodes.displayCodeFor(LanguageCodes.tableNameFor(code)),
          code,
        );
      }
    });
  });
}
