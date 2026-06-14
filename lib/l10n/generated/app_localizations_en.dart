// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Polydeck Preview';

  @override
  String get cardFront => 'Card Front';

  @override
  String get cardBack => 'Card Back';

  @override
  String get flipRed => 'Flip Red';

  @override
  String get flipYellow => 'Flip Yellow';

  @override
  String get flipGreen => 'Flip Green';

  @override
  String get reflip => 'Reflip';

  @override
  String get newCard => 'New Card';

  @override
  String cardCount(Object index, Object total) {
    return 'Card $index / $total';
  }

  @override
  String get analysis => 'Analysis';

  @override
  String get analysisResults => 'Analysis Results:';

  @override
  String previousDeck(Object deckName) {
    return 'Previous Deck: $deckName';
  }

  @override
  String get startNewDeck => 'Start New Deck';

  @override
  String cardAnalysis(Object index, Object color) {
    return 'Card $index: $color';
  }

  @override
  String get decks => 'Decks';

  @override
  String get deckPage => 'Deck Page';

  @override
  String get a1Deck => 'A1 Deck';

  @override
  String deck(Object index) {
    return 'Deck $index';
  }

  @override
  String get question => 'Question';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get finishExam => 'Finish Exam';

  @override
  String get exam => 'Exam';

  @override
  String get testResult => 'Test Result';

  @override
  String get recommendation => 'Recommended Deck';

  @override
  String get score => 'Score';

  @override
  String get red => 'Red';

  @override
  String get yellow => 'Yellow';

  @override
  String get green => 'Green';

  @override
  String get grey => 'Grey';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get instructionsContent =>
      'Tap card to flip, then choose a rating:\n◉ Again — reset & relearn\n◉ Hard — shorter interval\n◉ Good — standard interval\n◉ Easy — longer interval\n\nSwipe shortcuts: Left=Again, Down=Hard, Right=Good, Up=Easy';

  @override
  String get result => 'Result';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String get restartExam => 'Restart Exam';

  @override
  String get help => 'Help';

  @override
  String get confirmRestart => 'Are you sure you want to restart the exam?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get unanswered => 'Unanswered';

  @override
  String get review => 'Review';

  @override
  String totalQuestions(Object total) {
    return 'Total Questions: $total';
  }

  @override
  String get answered => 'Answered';

  @override
  String unansweredCount(Object count) {
    return 'Unanswered: $count';
  }

  @override
  String get resultTitle => 'Exam Results';

  @override
  String get pass => 'Congratulations! You passed the exam.';

  @override
  String get fail => 'You did not pass the exam. Better luck next time!';

  @override
  String percentage(Object percentage) {
    return 'Your Score: $percentage%';
  }

  @override
  String get backToDeck => 'Back to Deck';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get yourAnswer => 'Your Answer';

  @override
  String get correctAnswer => 'Correct Answer';

  @override
  String get recommendedDeck => 'Recommended Deck';

  @override
  String get yourScore => 'Score';

  @override
  String get settings => 'Settings';

  @override
  String get settingsContent => 'Here you can adjust your preferences.';

  @override
  String get logout => 'Logout';

  @override
  String get choosePage => 'Choose Page';

  @override
  String get goExam => 'Go Exam';

  @override
  String get selectLevel => 'Select Levels';

  @override
  String get confirmLevels => 'Confirm';

  @override
  String get firstTimeTitle => 'Select Languages';

  @override
  String get firstTimeContent =>
      'Please select your mother tongue and target language.';

  @override
  String get close => 'Close';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get monthlyProgress => 'Monthly Progress';

  @override
  String get chartWeekly => 'Weekly Chart';

  @override
  String get chartMonthly => 'Monthly Chart';

  @override
  String get progression => 'Your Progression';

  @override
  String get progress => 'Progress';

  @override
  String get changeLang => 'Change Language';

  @override
  String get examIconTooltip => 'Take an Exam';

  @override
  String get combinedDeck => 'Combined Deck';

  @override
  String get newDeck => 'New Deck';

  @override
  String get levelsSelected => 'Levels Selected';

  @override
  String get proceed => 'Proceed';

  @override
  String get targetLanguage => 'Target Language';

  @override
  String get motherLanguage => 'Mother Language';

  @override
  String get firstTimePromptTitle => 'Welcome!';

  @override
  String get firstTimePromptContent =>
      'Please select your mother language and target language.';

  @override
  String get confirm => 'Confirm';

  @override
  String get saveFailed => 'Failed to save settings';

  @override
  String get selectLanguages => 'Please select languages.';

  @override
  String get decksPage => 'Decks Page';

  @override
  String get again => 'Again';

  @override
  String get hard => 'Hard';

  @override
  String get good => 'Good';

  @override
  String get easy => 'Easy';

  @override
  String get srsSettings => 'SRS Settings';

  @override
  String get dailyLimits => 'Daily Limits';

  @override
  String get globalSettings => 'Global Settings';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get loading => 'Loading...';

  @override
  String get maxNewPerDay => 'Max new per day';

  @override
  String get maxReviewsPerDay => 'Max reviews per day';

  @override
  String get enableFuzz => 'Enable fuzz';

  @override
  String get fuzzDescription => 'Adds random variance to intervals';

  @override
  String get requestRetention => 'Request retention';

  @override
  String get resetAllSrsProgress => 'Reset All SRS Progress';

  @override
  String get resetSrsDescription =>
      'Resets every card to New state. Review history is preserved in the log.';

  @override
  String get resetSrsStateTitle => 'Reset SRS State?';

  @override
  String get resetSrsConfirmation =>
      'This will mark all cards as New. Your review history will be kept. Continue?';

  @override
  String get reset => 'Reset';

  @override
  String get cancel => 'Cancel';

  @override
  String get srsStateReset => 'SRS state has been reset.';

  @override
  String level(Object level) {
    return 'Level $level';
  }

  @override
  String newReviewsPerDay(Object newCount, Object reviewCount) {
    return '$newCount new / $reviewCount reviews per day';
  }

  @override
  String newCount(Object newCount, Object maxNew) {
    return '$newCount / $maxNew new';
  }

  @override
  String reviewCount(Object reviewCount, Object maxReviews) {
    return '$reviewCount / $maxReviews reviews';
  }
}
