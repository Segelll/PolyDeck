// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Polydeck Vorschau';

  @override
  String get cardFront => 'Kartenvorderseite';

  @override
  String get cardBack => 'Kartenrückseite';

  @override
  String get flipRed => 'Rot Drehen';

  @override
  String get flipYellow => 'Gelb Drehen';

  @override
  String get flipGreen => 'Grün Drehen';

  @override
  String get reflip => 'Erneut Drehen';

  @override
  String get newCard => 'Neue Karte';

  @override
  String cardCount(Object index, Object total) {
    return 'Karte $index / $total';
  }

  @override
  String get analysis => 'Analyse';

  @override
  String get analysisResults => 'Analyseergebnisse:';

  @override
  String previousDeck(Object deckName) {
    return 'Vorheriges Deck: $deckName';
  }

  @override
  String get startNewDeck => 'Neues Deck Starten';

  @override
  String cardAnalysis(Object index, Object color) {
    return 'Karte $index: $color';
  }

  @override
  String get decks => 'Decks';

  @override
  String get deckPage => 'Deck-Seite';

  @override
  String get a1Deck => 'A1 Deck';

  @override
  String deck(Object index) {
    return 'Deck $index';
  }

  @override
  String get question => 'Frage';

  @override
  String get nextQuestion => 'Nächste Frage';

  @override
  String get finishExam => 'Prüfung Beenden';

  @override
  String get exam => 'Prüfung';

  @override
  String get testResult => 'Testergebnis';

  @override
  String get recommendation => 'Empfohlenes Deck';

  @override
  String get score => 'Punktzahl';

  @override
  String get red => 'Rot';

  @override
  String get yellow => 'Gelb';

  @override
  String get green => 'Grün';

  @override
  String get grey => 'Grau';

  @override
  String get instructionsTitle => 'Anweisungen';

  @override
  String get instructionsContent =>
      'Nach links Wischen: Als Rot markieren (Schwer)\nNach unten Wischen: Als Gelb markieren (Mittel)\nNach rechts Wischen: Als Grün markieren (Leicht)\n\nTippen Sie auf \'Erneut Drehen\', um die Karte erneut zu versuchen.';

  @override
  String get result => 'Ergebnis';

  @override
  String get reviewAnswers => 'Antworten Überprüfen';

  @override
  String get restartExam => 'Prüfung Neustarten';

  @override
  String get help => 'Hilfe';

  @override
  String get confirmRestart =>
      'Sind Sie sicher, dass Sie die Prüfung neu starten möchten?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get correct => 'Richtig';

  @override
  String get incorrect => 'Falsch';

  @override
  String get unanswered => 'Unbeantwortet';

  @override
  String get review => 'Überprüfen';

  @override
  String totalQuestions(Object total) {
    return 'Gesamtfragen: $total';
  }

  @override
  String get answered => 'Beantwortet';

  @override
  String unansweredCount(Object count) {
    return 'Unbeantwortet: $count';
  }

  @override
  String get resultTitle => 'Prüfungsergebnisse';

  @override
  String get pass => 'Herzlichen Glückwunsch! Sie haben die Prüfung bestanden.';

  @override
  String get fail =>
      'Sie haben die Prüfung nicht bestanden. Viel Glück beim nächsten Mal!';

  @override
  String percentage(Object percentage) {
    return 'Ihre Punktzahl: $percentage%';
  }

  @override
  String get backToDeck => 'Zurück zum Deck';

  @override
  String get backToHome => 'Zurück zur Startseite';

  @override
  String get yourAnswer => 'Ihre Antwort';

  @override
  String get correctAnswer => 'Richtige Antwort';

  @override
  String get recommendedDeck => 'Empfohlenes Deck';

  @override
  String get yourScore => 'Punktzahl';

  @override
  String get settings => 'Einstellungen';

  @override
  String get settingsContent => 'Hier können Sie Ihre Einstellungen anpassen.';

  @override
  String get logout => 'Abmelden';

  @override
  String get choosePage => 'Seite Wählen';

  @override
  String get goExam => 'Zur Prüfung Gehen';

  @override
  String get selectLevel => 'Level Auswählen';

  @override
  String get confirmLevels => 'Bestätigen';

  @override
  String get firstTimeTitle => 'Sprachen Auswählen';

  @override
  String get firstTimeContent =>
      'Bitte wählen Sie Ihre Muttersprache und Zielsprache aus.';

  @override
  String get close => 'Schließen';

  @override
  String get weeklyProgress => 'Wöchentlicher Fortschritt';

  @override
  String get monthlyProgress => 'Monatlicher Fortschritt';

  @override
  String get chartWeekly => 'Wöchentliche Grafik';

  @override
  String get chartMonthly => 'Monatliche Grafik';

  @override
  String get progression => 'Ihr Fortschritt';

  @override
  String get progress => 'Fortschritt';

  @override
  String get changeLang => 'Sprache Ändern';

  @override
  String get examIconTooltip => 'Zur Prüfung Gehen';

  @override
  String get combinedDeck => 'Kombiniertes Deck';

  @override
  String get newDeck => 'Neues Deck';

  @override
  String get levelsSelected => 'Ausgewählte Levels';

  @override
  String get proceed => 'Fortfahren';

  @override
  String get targetLanguage => 'Zielsprache';

  @override
  String get motherLanguage => 'Muttersprache';

  @override
  String get firstTimePromptTitle => 'Willkommen!';

  @override
  String get firstTimePromptContent =>
      'Bitte wählen Sie Ihre Muttersprache und Zielsprache aus.';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get saveFailed => 'Einstellungen konnten nicht gespeichert werden';

  @override
  String get selectLanguages => 'Bitte wählen Sie Sprachen aus.';

  @override
  String get decksPage => 'Deck-Seite';
}
