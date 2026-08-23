import 'package:poly2/domain/enums/review_input_mode.dart';

/// Immutable value object for user language preferences.
class LanguagePreferences {
  final String mainLanguage;
  final String targetLanguage;
  final bool isFirstTime;
  final ReviewInputMode reviewInputMode;

  const LanguagePreferences({
    required this.mainLanguage,
    required this.targetLanguage,
    required this.isFirstTime,
    this.reviewInputMode = ReviewInputMode.buttons,
  });

  static const defaultPreferences = LanguagePreferences(
    mainLanguage: 'en',
    targetLanguage: 'tr',
    isFirstTime: true,
    reviewInputMode: ReviewInputMode.buttons,
  );
}
