// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Aperçu Polydeck';

  @override
  String get cardFront => 'Recto de la Carte';

  @override
  String get cardBack => 'Verso de la Carte';

  @override
  String get flipRed => 'Retourner Rouge';

  @override
  String get flipYellow => 'Retourner Jaune';

  @override
  String get flipGreen => 'Retourner Vert';

  @override
  String get reflip => 'Retourner à Nouveau';

  @override
  String get newCard => 'Nouvelle Carte';

  @override
  String cardCount(Object index, Object total) {
    return 'Carte $index / $total';
  }

  @override
  String get analysis => 'Analyse';

  @override
  String get analysisResults => 'Résultats de l\'Analyse :';

  @override
  String previousDeck(Object deckName) {
    return 'Deck Précédent : $deckName';
  }

  @override
  String get startNewDeck => 'Commencer un Nouveau Deck';

  @override
  String cardAnalysis(Object index, Object color) {
    return 'Carte $index : $color';
  }

  @override
  String get decks => 'Decks';

  @override
  String get deckPage => 'Page du Deck';

  @override
  String get a1Deck => 'Deck A1';

  @override
  String deck(Object index) {
    return 'Deck $index';
  }

  @override
  String get question => 'Question';

  @override
  String get nextQuestion => 'Question Suivante';

  @override
  String get finishExam => 'Terminer l\'Examen';

  @override
  String get exam => 'Examen';

  @override
  String get testResult => 'Résultat de l\'Examen';

  @override
  String get recommendation => 'Deck Recommandé';

  @override
  String get score => 'Score';

  @override
  String get red => 'Rouge';

  @override
  String get yellow => 'Jaune';

  @override
  String get green => 'Vert';

  @override
  String get grey => 'Gris';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get instructionsContent =>
      'Glisser à Gauche : Marquer en Rouge (Difficile)\nGlisser vers le Bas : Marquer en Jaune (Moyen)\nGlisser à Droite : Marquer en Vert (Facile)\n\nAppuyez sur \'Retourner à Nouveau\' pour réessayer la carte.';

  @override
  String get result => 'Résultat';

  @override
  String get reviewAnswers => 'Revoir les Réponses';

  @override
  String get restartExam => 'Redémarrer l\'Examen';

  @override
  String get help => 'Aide';

  @override
  String get confirmRestart =>
      'Êtes-vous sûr de vouloir redémarrer l\'examen ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get unanswered => 'Sans Réponse';

  @override
  String get review => 'Revoir';

  @override
  String totalQuestions(Object total) {
    return 'Total des Questions : $total';
  }

  @override
  String get answered => 'Répondu';

  @override
  String unansweredCount(Object count) {
    return 'Sans Réponse : $count';
  }

  @override
  String get resultTitle => 'Résultats de l\'Examen';

  @override
  String get pass => 'Félicitations ! Vous avez réussi l\'examen.';

  @override
  String get fail =>
      'Vous n\'avez pas réussi l\'examen. Bonne chance la prochaine fois !';

  @override
  String percentage(Object percentage) {
    return 'Votre Score : $percentage%';
  }

  @override
  String get backToDeck => 'Retour au Deck';

  @override
  String get backToHome => 'Retour à l\'Accueil';

  @override
  String get yourAnswer => 'Votre Réponse';

  @override
  String get correctAnswer => 'Réponse Correcte';

  @override
  String get recommendedDeck => 'Deck Recommandé';

  @override
  String get yourScore => 'Score';

  @override
  String get settings => 'Paramètres';

  @override
  String get settingsContent => 'Ici, vous pouvez ajuster vos préférences.';

  @override
  String get logout => 'Se Déconnecter';

  @override
  String get choosePage => 'Choisir une Page';

  @override
  String get goExam => 'Aller à l\'Examen';

  @override
  String get selectLevel => 'Sélectionner les Niveaux';

  @override
  String get confirmLevels => 'Confirmer';

  @override
  String get firstTimeTitle => 'Sélectionner les Langues';

  @override
  String get firstTimeContent =>
      'Veuillez sélectionner votre langue maternelle et votre langue cible.';

  @override
  String get close => 'Fermer';

  @override
  String get weeklyProgress => 'Progression Hebdomadaire';

  @override
  String get monthlyProgress => 'Progression Mensuelle';

  @override
  String get chartWeekly => 'Graphique Hebdomadaire';

  @override
  String get chartMonthly => 'Graphique Mensuel';

  @override
  String get progression => 'Votre Progression';

  @override
  String get progress => 'Progression';

  @override
  String get changeLang => 'Changer de Langue';

  @override
  String get examIconTooltip => 'Passer un Examen';

  @override
  String get combinedDeck => 'Deck Combiné';

  @override
  String get newDeck => 'Nouveau Deck';

  @override
  String get levelsSelected => 'Niveaux Sélectionnés';

  @override
  String get proceed => 'Procéder';

  @override
  String get targetLanguage => 'Langue Cible';

  @override
  String get motherLanguage => 'Langue Maternelle';

  @override
  String get firstTimePromptTitle => 'Bienvenue !';

  @override
  String get firstTimePromptContent =>
      'Veuillez sélectionner votre langue maternelle et votre langue cible.';

  @override
  String get confirm => 'Confirmer';

  @override
  String get saveFailed => 'Échec de la sauvegarde des paramètres';

  @override
  String get selectLanguages => 'Veuillez sélectionner les langues.';

  @override
  String get decksPage => 'Decks Page';

  @override
  String get again => 'Encore';

  @override
  String get hard => 'Difficile';

  @override
  String get good => 'Bien';

  @override
  String get easy => 'Facile';

  @override
  String get srsSettings => 'Paramètres SRS';

  @override
  String get dailyLimits => 'Limites quotidiennes';

  @override
  String get globalSettings => 'Paramètres globaux';

  @override
  String get dangerZone => 'Zone dangereuse';

  @override
  String get loading => 'Chargement...';

  @override
  String get maxNewPerDay => 'Max nouvelles par jour';

  @override
  String get maxReviewsPerDay => 'Max révisions par jour';

  @override
  String get enableFuzz => 'Activer la variation aléatoire';

  @override
  String get fuzzDescription =>
      'Ajoute une variation aléatoire aux intervalles';

  @override
  String get requestRetention => 'Rétention souhaitée';

  @override
  String get resetAllSrsProgress => 'Réinitialiser tout le progrès SRS';

  @override
  String get resetSrsDescription =>
      'Réinitialise toutes les cartes à l\'état Nouveau. L\'historique des révisions est conservé dans le journal.';

  @override
  String get resetSrsStateTitle => 'Réinitialiser l\'état SRS ?';

  @override
  String get resetSrsConfirmation =>
      'Cela marquera toutes les cartes comme Nouvelles. Votre historique de révisions sera conservé. Continuer ?';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get cancel => 'Annuler';

  @override
  String get srsStateReset => 'L\'état SRS a été réinitialisé.';

  @override
  String level(Object level) {
    return 'Niveau $level';
  }

  @override
  String newReviewsPerDay(Object newCount, Object reviewCount) {
    return '$newCount nouvelles / $reviewCount révisions par jour';
  }

  @override
  String newCount(Object newCount, Object maxNew) {
    return '$newCount / $maxNew nouvelles';
  }

  @override
  String reviewCount(Object reviewCount, Object maxReviews) {
    return '$reviewCount / $maxReviews révisions';
  }
}
