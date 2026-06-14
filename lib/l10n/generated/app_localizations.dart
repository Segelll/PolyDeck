import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Polydeck Preview'**
  String get appTitle;

  /// No description provided for @cardFront.
  ///
  /// In en, this message translates to:
  /// **'Card Front'**
  String get cardFront;

  /// No description provided for @cardBack.
  ///
  /// In en, this message translates to:
  /// **'Card Back'**
  String get cardBack;

  /// No description provided for @flipRed.
  ///
  /// In en, this message translates to:
  /// **'Flip Red'**
  String get flipRed;

  /// No description provided for @flipYellow.
  ///
  /// In en, this message translates to:
  /// **'Flip Yellow'**
  String get flipYellow;

  /// No description provided for @flipGreen.
  ///
  /// In en, this message translates to:
  /// **'Flip Green'**
  String get flipGreen;

  /// No description provided for @reflip.
  ///
  /// In en, this message translates to:
  /// **'Reflip'**
  String get reflip;

  /// No description provided for @newCard.
  ///
  /// In en, this message translates to:
  /// **'New Card'**
  String get newCard;

  /// Displays the current card index and total number of cards
  ///
  /// In en, this message translates to:
  /// **'Card {index} / {total}'**
  String cardCount(Object index, Object total);

  /// No description provided for @analysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysis;

  /// No description provided for @analysisResults.
  ///
  /// In en, this message translates to:
  /// **'Analysis Results:'**
  String get analysisResults;

  /// Shows the name of the previous deck
  ///
  /// In en, this message translates to:
  /// **'Previous Deck: {deckName}'**
  String previousDeck(Object deckName);

  /// No description provided for @startNewDeck.
  ///
  /// In en, this message translates to:
  /// **'Start New Deck'**
  String get startNewDeck;

  /// Displays analysis of a card with its index and color
  ///
  /// In en, this message translates to:
  /// **'Card {index}: {color}'**
  String cardAnalysis(Object index, Object color);

  /// No description provided for @decks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get decks;

  /// No description provided for @deckPage.
  ///
  /// In en, this message translates to:
  /// **'Deck Page'**
  String get deckPage;

  /// No description provided for @a1Deck.
  ///
  /// In en, this message translates to:
  /// **'A1 Deck'**
  String get a1Deck;

  /// Deck label with index
  ///
  /// In en, this message translates to:
  /// **'Deck {index}'**
  String deck(Object index);

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// No description provided for @finishExam.
  ///
  /// In en, this message translates to:
  /// **'Finish Exam'**
  String get finishExam;

  /// No description provided for @exam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get exam;

  /// No description provided for @testResult.
  ///
  /// In en, this message translates to:
  /// **'Test Result'**
  String get testResult;

  /// No description provided for @recommendation.
  ///
  /// In en, this message translates to:
  /// **'Recommended Deck'**
  String get recommendation;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @grey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get grey;

  /// No description provided for @instructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructionsTitle;

  /// No description provided for @instructionsContent.
  ///
  /// In en, this message translates to:
  /// **'Tap card to flip, then choose a rating:\n◉ Again — reset & relearn\n◉ Hard — shorter interval\n◉ Good — standard interval\n◉ Easy — longer interval\n\nSwipe shortcuts: Left=Again, Down=Hard, Right=Good, Up=Easy'**
  String get instructionsContent;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @reviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get reviewAnswers;

  /// No description provided for @restartExam.
  ///
  /// In en, this message translates to:
  /// **'Restart Exam'**
  String get restartExam;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @confirmRestart.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restart the exam?'**
  String get confirmRestart;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @unanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get unanswered;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// Displays the total number of questions
  ///
  /// In en, this message translates to:
  /// **'Total Questions: {total}'**
  String totalQuestions(Object total);

  /// No description provided for @answered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get answered;

  /// Displays the count of unanswered questions
  ///
  /// In en, this message translates to:
  /// **'Unanswered: {count}'**
  String unansweredCount(Object count);

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam Results'**
  String get resultTitle;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You passed the exam.'**
  String get pass;

  /// No description provided for @fail.
  ///
  /// In en, this message translates to:
  /// **'You did not pass the exam. Better luck next time!'**
  String get fail;

  /// Displays the user's score as a percentage
  ///
  /// In en, this message translates to:
  /// **'Your Score: {percentage}%'**
  String percentage(Object percentage);

  /// No description provided for @backToDeck.
  ///
  /// In en, this message translates to:
  /// **'Back to Deck'**
  String get backToDeck;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct Answer'**
  String get correctAnswer;

  /// No description provided for @recommendedDeck.
  ///
  /// In en, this message translates to:
  /// **'Recommended Deck'**
  String get recommendedDeck;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get yourScore;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsContent.
  ///
  /// In en, this message translates to:
  /// **'Here you can adjust your preferences.'**
  String get settingsContent;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @choosePage.
  ///
  /// In en, this message translates to:
  /// **'Choose Page'**
  String get choosePage;

  /// No description provided for @goExam.
  ///
  /// In en, this message translates to:
  /// **'Go Exam'**
  String get goExam;

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select Levels'**
  String get selectLevel;

  /// No description provided for @confirmLevels.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmLevels;

  /// No description provided for @firstTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Languages'**
  String get firstTimeTitle;

  /// No description provided for @firstTimeContent.
  ///
  /// In en, this message translates to:
  /// **'Please select your mother tongue and target language.'**
  String get firstTimeContent;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @monthlyProgress.
  ///
  /// In en, this message translates to:
  /// **'Monthly Progress'**
  String get monthlyProgress;

  /// No description provided for @chartWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly Chart'**
  String get chartWeekly;

  /// No description provided for @chartMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Chart'**
  String get chartMonthly;

  /// No description provided for @progression.
  ///
  /// In en, this message translates to:
  /// **'Your Progression'**
  String get progression;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @changeLang.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLang;

  /// No description provided for @examIconTooltip.
  ///
  /// In en, this message translates to:
  /// **'Take an Exam'**
  String get examIconTooltip;

  /// No description provided for @combinedDeck.
  ///
  /// In en, this message translates to:
  /// **'Combined Deck'**
  String get combinedDeck;

  /// No description provided for @newDeck.
  ///
  /// In en, this message translates to:
  /// **'New Deck'**
  String get newDeck;

  /// No description provided for @levelsSelected.
  ///
  /// In en, this message translates to:
  /// **'Levels Selected'**
  String get levelsSelected;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @targetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Target Language'**
  String get targetLanguage;

  /// No description provided for @motherLanguage.
  ///
  /// In en, this message translates to:
  /// **'Mother Language'**
  String get motherLanguage;

  /// No description provided for @firstTimePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get firstTimePromptTitle;

  /// No description provided for @firstTimePromptContent.
  ///
  /// In en, this message translates to:
  /// **'Please select your mother language and target language.'**
  String get firstTimePromptContent;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings'**
  String get saveFailed;

  /// No description provided for @selectLanguages.
  ///
  /// In en, this message translates to:
  /// **'Please select languages.'**
  String get selectLanguages;

  /// No description provided for @decksPage.
  ///
  /// In en, this message translates to:
  /// **'Decks Page'**
  String get decksPage;

  /// No description provided for @again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get again;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @srsSettings.
  ///
  /// In en, this message translates to:
  /// **'SRS Settings'**
  String get srsSettings;

  /// No description provided for @dailyLimits.
  ///
  /// In en, this message translates to:
  /// **'Daily Limits'**
  String get dailyLimits;

  /// No description provided for @globalSettings.
  ///
  /// In en, this message translates to:
  /// **'Global Settings'**
  String get globalSettings;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @maxNewPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max new per day'**
  String get maxNewPerDay;

  /// No description provided for @maxReviewsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max reviews per day'**
  String get maxReviewsPerDay;

  /// No description provided for @enableFuzz.
  ///
  /// In en, this message translates to:
  /// **'Enable fuzz'**
  String get enableFuzz;

  /// No description provided for @fuzzDescription.
  ///
  /// In en, this message translates to:
  /// **'Adds random variance to intervals'**
  String get fuzzDescription;

  /// No description provided for @requestRetention.
  ///
  /// In en, this message translates to:
  /// **'Request retention'**
  String get requestRetention;

  /// No description provided for @resetAllSrsProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset All SRS Progress'**
  String get resetAllSrsProgress;

  /// No description provided for @resetSrsDescription.
  ///
  /// In en, this message translates to:
  /// **'Resets every card to New state. Review history is preserved in the log.'**
  String get resetSrsDescription;

  /// No description provided for @resetSrsStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset SRS State?'**
  String get resetSrsStateTitle;

  /// No description provided for @resetSrsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will mark all cards as New. Your review history will be kept. Continue?'**
  String get resetSrsConfirmation;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @srsStateReset.
  ///
  /// In en, this message translates to:
  /// **'SRS state has been reset.'**
  String get srsStateReset;

  /// Level label with code
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(Object level);

  /// Daily new/review counts
  ///
  /// In en, this message translates to:
  /// **'{newCount} new / {reviewCount} reviews per day'**
  String newReviewsPerDay(Object newCount, Object reviewCount);

  /// New cards count for the day
  ///
  /// In en, this message translates to:
  /// **'{newCount} / {maxNew} new'**
  String newCount(Object newCount, Object maxNew);

  /// Review cards count for the day
  ///
  /// In en, this message translates to:
  /// **'{reviewCount} / {maxReviews} reviews'**
  String reviewCount(Object reviewCount, Object maxReviews);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'pt',
        'tr'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
