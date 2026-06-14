// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Anteprima Polydeck';

  @override
  String get cardFront => 'Fronte della Carta';

  @override
  String get cardBack => 'Retro della Carta';

  @override
  String get flipRed => 'Gira Rosso';

  @override
  String get flipYellow => 'Gira Giallo';

  @override
  String get flipGreen => 'Gira Verde';

  @override
  String get reflip => 'Gira di Nuovo';

  @override
  String get newCard => 'Nuova Carta';

  @override
  String cardCount(Object index, Object total) {
    return 'Carta $index / $total';
  }

  @override
  String get analysis => 'Analisi';

  @override
  String get analysisResults => 'Risultati dell\'Analisi:';

  @override
  String previousDeck(Object deckName) {
    return 'Deck Precedente: $deckName';
  }

  @override
  String get startNewDeck => 'Inizia Nuovo Deck';

  @override
  String cardAnalysis(Object index, Object color) {
    return 'Carta $index: $color';
  }

  @override
  String get decks => 'Decks';

  @override
  String get deckPage => 'Pagina del Deck';

  @override
  String get a1Deck => 'Deck A1';

  @override
  String deck(Object index) {
    return 'Deck $index';
  }

  @override
  String get question => 'Domanda';

  @override
  String get nextQuestion => 'Domanda Successiva';

  @override
  String get finishExam => 'Termina Esame';

  @override
  String get exam => 'Esame';

  @override
  String get testResult => 'Risultato dell\'Esame';

  @override
  String get recommendation => 'Deck Raccomandato';

  @override
  String get score => 'Punteggio';

  @override
  String get red => 'Rosso';

  @override
  String get yellow => 'Giallo';

  @override
  String get green => 'Verde';

  @override
  String get grey => 'Grigio';

  @override
  String get instructionsTitle => 'Istruzioni';

  @override
  String get instructionsContent =>
      'Scorri a Sinistra: Segna come Rosso (Difficile)\nScorri in Basso: Segna come Giallo (Medio)\nScorri a Destra: Segna come Verde (Facile)\n\nTocca \'Gira di Nuovo\' per riprovare la carta.';

  @override
  String get result => 'Risultato';

  @override
  String get reviewAnswers => 'Rivedi Risposte';

  @override
  String get restartExam => 'Riavvia Esame';

  @override
  String get help => 'Aiuto';

  @override
  String get confirmRestart => 'Sei sicuro di voler riavviare l\'esame?';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get correct => 'Corretto';

  @override
  String get incorrect => 'Errato';

  @override
  String get unanswered => 'Non Risposto';

  @override
  String get review => 'Rivedi';

  @override
  String totalQuestions(Object total) {
    return 'Totale Domande: $total';
  }

  @override
  String get answered => 'Risposto';

  @override
  String unansweredCount(Object count) {
    return 'Non Risposto: $count';
  }

  @override
  String get resultTitle => 'Risultati dell\'Esame';

  @override
  String get pass => 'Congratulazioni! Hai superato l\'esame.';

  @override
  String get fail => 'Non hai superato l\'esame. Migliora la prossima volta!';

  @override
  String percentage(Object percentage) {
    return 'Il Tuo Punteggio: $percentage%';
  }

  @override
  String get backToDeck => 'Torna al Deck';

  @override
  String get backToHome => 'Torna alla Home';

  @override
  String get yourAnswer => 'La Tua Risposta';

  @override
  String get correctAnswer => 'Risposta Corretta';

  @override
  String get recommendedDeck => 'Deck Raccomandato';

  @override
  String get yourScore => 'Punteggio';

  @override
  String get settings => 'Impostazioni';

  @override
  String get settingsContent => 'Qui puoi regolare le tue preferenze.';

  @override
  String get logout => 'Logout';

  @override
  String get choosePage => 'Scegli la Pagina';

  @override
  String get goExam => 'Vai all\'Esame';

  @override
  String get selectLevel => 'Seleziona Livelli';

  @override
  String get confirmLevels => 'Conferma';

  @override
  String get firstTimeTitle => 'Seleziona le Lingue';

  @override
  String get firstTimeContent =>
      'Per favore seleziona la tua lingua madre e lingua target.';

  @override
  String get close => 'Chiudi';

  @override
  String get weeklyProgress => 'Progressione Settimanale';

  @override
  String get monthlyProgress => 'Progressione Mensile';

  @override
  String get chartWeekly => 'Grafico Settimanale';

  @override
  String get chartMonthly => 'Grafico Mensile';

  @override
  String get progression => 'La Tua Progressione';

  @override
  String get progress => 'Progressione';

  @override
  String get changeLang => 'Cambia Lingua';

  @override
  String get examIconTooltip => 'Fai un Esame';

  @override
  String get combinedDeck => 'Deck Combinato';

  @override
  String get newDeck => 'Nuovo Deck';

  @override
  String get levelsSelected => 'Livelli Selezionati';

  @override
  String get proceed => 'Procedi';

  @override
  String get targetLanguage => 'Lingua Target';

  @override
  String get motherLanguage => 'Lingua Madre';

  @override
  String get firstTimePromptTitle => 'Benvenuto!';

  @override
  String get firstTimePromptContent =>
      'Per favore seleziona la tua lingua madre e lingua target.';

  @override
  String get confirm => 'Conferma';

  @override
  String get saveFailed => 'Impostazioni non salvate';

  @override
  String get selectLanguages => 'Seleziona le lingue.';

  @override
  String get decksPage => 'Pagina del Deck';

  @override
  String get again => 'Ancora';

  @override
  String get hard => 'Difficile';

  @override
  String get good => 'Bene';

  @override
  String get easy => 'Facile';

  @override
  String get srsSettings => 'Impostazioni SRS';

  @override
  String get dailyLimits => 'Limiti giornalieri';

  @override
  String get globalSettings => 'Impostazioni globali';

  @override
  String get dangerZone => 'Zona pericolosa';

  @override
  String get loading => 'Caricamento...';

  @override
  String get maxNewPerDay => 'Max nuove al giorno';

  @override
  String get maxReviewsPerDay => 'Max ripassi al giorno';

  @override
  String get enableFuzz => 'Attiva variazione casuale';

  @override
  String get fuzzDescription => 'Aggiunge variazione casuale agli intervalli';

  @override
  String get requestRetention => 'Ritenzione desiderata';

  @override
  String get resetAllSrsProgress => 'Azzera tutto il progresso SRS';

  @override
  String get resetSrsDescription =>
      'Reimposta tutte le carte allo stato Nuovo. La cronologia dei ripassi è conservata nel registro.';

  @override
  String get resetSrsStateTitle => 'Azzera stato SRS?';

  @override
  String get resetSrsConfirmation =>
      'Questo segnerà tutte le carte come Nuove. La cronologia dei ripassi sarà conservata. Continuare?';

  @override
  String get reset => 'Azzera';

  @override
  String get cancel => 'Annulla';

  @override
  String get srsStateReset => 'Lo stato SRS è stato azzerato.';

  @override
  String level(Object level) {
    return 'Livello $level';
  }

  @override
  String newReviewsPerDay(Object newCount, Object reviewCount) {
    return '$newCount nuove / $reviewCount ripassi al giorno';
  }

  @override
  String newCount(Object newCount, Object maxNew) {
    return '$newCount / $maxNew nuove';
  }

  @override
  String reviewCount(Object reviewCount, Object maxReviews) {
    return '$reviewCount / $maxReviews ripassi';
  }
}
