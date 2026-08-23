import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/domain/state/language_preferences.dart';
import 'package:poly2/domain/enums/review_input_mode.dart';
import 'package:poly2/presentation/providers/database_provider.dart';

/// Manages user language preferences.
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, LanguagePreferences>(
      SettingsNotifier.new,
    );

class SettingsNotifier extends AsyncNotifier<LanguagePreferences> {
  @override
  Future<LanguagePreferences> build() async {
    final repo = ref.read(userRepositoryProvider);
    final choices = await repo.getUserChoices();

    if (choices == null) return LanguagePreferences.defaultPreferences;

    return LanguagePreferences(
      mainLanguage: choices['mainLanguage'] ?? 'en',
      targetLanguage: choices['targetLanguage'] ?? 'tr',
      isFirstTime: choices['firstTime'] == 'true',
      reviewInputMode: ReviewInputMode.fromStorage(choices['reviewMode']),
    );
  }

  Future<void> saveLanguages(
    String mainLanguage,
    String targetLanguage, {
    ReviewInputMode reviewInputMode = ReviewInputMode.buttons,
  }) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.saveUserChoices(
      mainLanguage,
      targetLanguage,
      reviewMode: reviewInputMode.storageValue,
    );
    state = AsyncData(
      LanguagePreferences(
        mainLanguage: mainLanguage,
        targetLanguage: targetLanguage,
        isFirstTime: false,
        reviewInputMode: reviewInputMode,
      ),
    );
  }

  /// Applies the review mode immediately so the card screen reflects a
  /// segmented-control selection even when the user leaves settings before
  /// pressing the general save button.
  Future<void> saveReviewInputMode(ReviewInputMode reviewInputMode) async {
    final current = state.valueOrNull ?? LanguagePreferences.defaultPreferences;
    final next = LanguagePreferences(
      mainLanguage: current.mainLanguage,
      targetLanguage: current.targetLanguage,
      isFirstTime: current.isFirstTime,
      reviewInputMode: reviewInputMode,
    );

    // Optimistic state update keeps the card screen responsive. The database
    // write below is still awaited so a failure is visible to the caller.
    state = AsyncData(next);
    final repo = ref.read(userRepositoryProvider);
    await repo.saveUserChoices(
      current.mainLanguage,
      current.targetLanguage,
      reviewMode: reviewInputMode.storageValue,
    );
  }
}
