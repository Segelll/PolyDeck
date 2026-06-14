import 'package:drift/drift.dart';

/// Unified vocabulary table — all languages in one table.
/// Replaces the old per-language tables (en, tr, de, fr, it, pr, esp).
@DataClassName('Word')
class Words extends Table {
  IntColumn get id => integer()();
  TextColumn get word => text()();
  TextColumn get sentence => text()();
  TextColumn get level => text()();
  TextColumn get languageCode => text().named('language_code')();
  IntColumn get isSeen => integer().named('isSeen').withDefault(const Constant(0))();
  IntColumn get feedback => integer().named('feedback').withDefault(const Constant(0))();
  TextColumn get date => text().nullable()();
  // FSRS
  IntColumn get cardState => integer().named('card_state').withDefault(const Constant(0))();
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  TextColumn get due => text().nullable()();
  IntColumn get elapsedDays => integer().named('elapsed_days').withDefault(const Constant(0))();
  IntColumn get scheduledDays => integer().named('scheduled_days').withDefault(const Constant(0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  TextColumn get lastReview => text().named('last_review').nullable()();
  // Fav-specific
  TextColumn get backword => text().nullable()();
  TextColumn get backsentence => text().nullable()();

  @override
  Set<Column> get primaryKey => {languageCode, id};
}

/// Review log table.
class RevlogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId => integer().named('card_id')();
  TextColumn get deckTable => text().named('deck_table')();
  IntColumn get rating => integer()();
  IntColumn get state => integer()();
  TextColumn get due => text()();
  RealColumn get stability => real()();
  RealColumn get difficulty => real()();
  IntColumn get elapsedDays => integer().named('elapsed_days')();
  IntColumn get lastElapsedDays => integer().named('last_elapsed_days').withDefault(const Constant(0))();
  IntColumn get scheduledDays => integer().named('scheduled_days')();
  TextColumn get reviewDate => text().named('review_date')();

  @override
  String get tableName => 'revlog';
}

/// Per-level SRS config.
class DeckConfigs extends Table {
  TextColumn get level => text()();
  IntColumn get maxNewPerDay => integer().named('max_new_per_day').withDefault(const Constant(10))();
  IntColumn get maxReviewsPerDay => integer().named('max_reviews_per_day').withDefault(const Constant(20))();
  TextColumn get learningSteps => text().named('learning_steps').withDefault(const Constant('[1,10]'))();
  IntColumn get enableFuzz => integer().named('enable_fuzz').withDefault(const Constant(1))();
  RealColumn get requestRetention => real().named('request_retention').withDefault(const Constant(0.9))();
  TextColumn get w => text().nullable()();

  @override
  Set<Column> get primaryKey => {level};

  @override
  String get tableName => 'deck_config';
}

/// User preferences.
class UserSettings extends Table {
  TextColumn get mainLanguage => text().named('mainLanguage')();
  TextColumn get targetLanguage => text().named('targetLanguage')();
  TextColumn get firstTime => text().named('firstTime')();

  @override
  String get tableName => 'user';
}
