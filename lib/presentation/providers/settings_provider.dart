import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poly2/data/repositories/user_repository.dart';

/// Provides the [UserRepository] instance.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Holds the user's language preferences as a simple state class.
class LanguagePreferences {
  final String mainLanguage;
  final String targetLanguage;
  final bool isFirstTime;

  const LanguagePreferences({
    required this.mainLanguage,
    required this.targetLanguage,
    required this.isFirstTime,
  });

  static const defaultPreferences = LanguagePreferences(
    mainLanguage: 'en',
    targetLanguage: 'tr',
    isFirstTime: true,
  );
}

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
    );
  }

  Future<void> saveLanguages(String mainLanguage, String targetLanguage) async {
    final repo = ref.read(userRepositoryProvider);
    await repo.saveUserChoices(mainLanguage, targetLanguage);
    state = AsyncData(LanguagePreferences(
      mainLanguage: mainLanguage,
      targetLanguage: targetLanguage,
      isFirstTime: false,
    ));
  }
}
