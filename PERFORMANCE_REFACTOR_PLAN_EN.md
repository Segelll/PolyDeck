# PolyDeck Performance and Refactor Plan

Date: 2026-08-23
Goal: Turn PolyDeck into an offline, multilingual FSRS flashcard app that stays smooth even on low-end phones.

This document was prepared by scanning the current repository and checking the current official documentation for Flutter, Drift, Riverpod, SQLite, and related packages. The goal is not only "cleaner code"; it is measurable speed improvement in the user-visible paths: first launch, deck loading, card review, exam generation, progress screens, and settings.

## Short Summary

PolyDeck currently runs on Flutter 3.47.1 / Dart 3.13.1. The data layer uses Drift 2.34.3 and copies the single current SQLite schema from `assets/polydesk.db`. FSRS is provided by `package:fsrs` 2.0.1. State management uses Riverpod 2.6.1.

Primary performance risks:

1. The Drift connection is opened on the main isolate with `NativeDatabase(File(...))`. Drift documentation says SQLite is a synchronous C library, and IO on the main isolate can reduce UI responsiveness. `NativeDatabase.createInBackground` is the first major win candidate for this repository.
2. The new-card query uses `ORDER BY RANDOM()`. The SQLite query plan shows that this creates a temporary B-tree sort. As the word count grows, deck loading becomes expensive on low-end devices.
3. The due-card query uses an index, but still creates a temporary B-tree for `ORDER BY due`. Index order and the use of `IN (1,2,3)` should be reevaluated.
4. Progress queries do not use a suitable composite index for `date`; `GROUP BY date` and monthly count queries can be better indexed per language.
5. The active `assets/polydesk.db` contains `language_code` values `es` and `pt`, but `LanguageCodes` and some reset/export code still use the old `esp` and `pr` names. This is not a performance issue; it is a direct correctness issue.
6. The card review flow is not a single transaction: `fetchWordById -> updateSrsState -> insertRevlog`. This creates a risk of duplicate reviews for the same card and partial writes.
7. Exam generation performs many sequential DB queries. Question and distractor selection should move to batch queries.
8. In the UI layer, some places watch entire state objects with `ref.watch`, some lists use eager `ListView(children: map(...).toList())`, and animation subtrees can be isolated further.

## Repository Reality

### Technologies and Packages

According to `flutter pub deps --style=compact`:

- Flutter SDK: 3.47.1
- Dart SDK: 3.13.1
- `drift`: 2.34.3
- `drift_dev`: 2.34.5
- `sqlite3_flutter_libs`: 0.5.42
- `flutter_riverpod`: 2.6.1
- `fsrs`: 2.0.1
- `shared_preferences`: 2.5.5
- `share_plus`: 13.3.0
- `file_picker`: 12.0.0
- `flutter_lints`: 6.0.0

`flutter pub outdated` notes:

- Riverpod 3.x is available, but this repository keeps it as a separate upgrade because the provider API and test toolchain should move together.
- `share_plus` 13.3.0 and `file_picker` 12.0.0 are the current active targets.
- `flutter_lints` 6.0.0 is in use.
- `path_provider` 2.1.6 is in use.
- `sqlite3_flutter_libs` shows 0.6.0+eol as latest; do not automatically upgrade this package without checking the changelog and Drift compatibility.

### Database State

File sizes:

- `assets/polydesk.db`: about 5.1 MB
- `assets/language_data.db`: about 2.6 MB

Active `polydesk.db` tables:

- `words`
- `revlog`
- `deck_config`
- `user`

`words` has been migrated to a single-table model. Each language has the same CEFR distribution:

- A1: 703
- A2: 723
- B1: 738
- B2: 1377
- C1: 1258
- Total: 4799 rows per language, 33593 word rows across 7 languages

Active `words.language_code` values:

- `en`, `tr`, `de`, `fr`, `it`, `pt`, `es`

This is important: `lib/core/constants/language_codes.dart` still maps `pt -> pr` and `es -> esp`. `assets/language_data.db` might still contain the old table names (`pr`, `esp`), but the app now reads the unified `words` table in `polydesk.db`. In its current form, this mapping can break Spanish and Portuguese flows.

Current indexes:

- `idx_words_lang_level_state_due(language_code, level, card_state, due)`
- `idx_words_lang_level_state_seen(language_code, level, card_state, isSeen)`
- `idx_words_lang_level_isSeen(language_code, level, isSeen)`
- `idx_words_feedback(isSeen, feedback)`
- `idx_revlog_card(deck_table, card_id)`
- `idx_revlog_date(review_date)`
- `idx_revlog_deck_date_state(deck_table, review_date, state)`

Query plan findings:

- The due-card query uses `idx_words_lang_level_state_due`, but creates a temporary B-tree for `ORDER BY due`.
- The new-card query uses `idx_words_lang_level_state_seen`, but creates a temporary B-tree for `ORDER BY RANDOM()`.
- The weekly progress query uses the language primary key index, but creates a temporary B-tree for `GROUP BY date`.
- The monthly progress query searches only by `language_code`; the `date` range is not indexed.

### Critical Code Paths

- DB opening: `lib/data/database/database.dart`
- Drift table definitions: `lib/data/database/tables.dart`
- Deck loading/review: `lib/presentation/providers/deck_provider.dart`
- Card UI and animation: `lib/pages/card_flip_page.dart`, `lib/presentation/widgets/card_flip_animation.dart`
- Exam generation: `lib/presentation/providers/exam_provider.dart`
- Progress queries: `lib/data/repositories/progress_repository.dart`
- Settings/import/export: `lib/pages/settings_page.dart`, `lib/pages/srs_settings_page.dart`
- Language codes: `lib/core/constants/language_codes.dart`, `lib/core/constants/app_constants.dart`

## Research Sources

Main sources used for this plan:

- Flutter performance best practices: https://docs.flutter.dev/perf/best-practices
- Flutter DevTools Performance view: https://docs.flutter.dev/tools/devtools/performance
- Drift isolates: https://drift.simonbinder.eu/isolates/
- Drift existing/pre-populated databases: https://drift.simonbinder.eu/examples/existing_databases/
- Drift native VM setup and `NativeDatabase.createInBackground`: https://drift.simonbinder.eu/platforms/vm/
- Riverpod rebuild reduction with `select`: https://riverpod.dev/docs/how_to/select
- SQLite query planner: https://sqlite.org/queryplanner.html
- Dart-FSRS API docs: https://pub.dev/documentation/fsrs/latest/
- shared_preferences API notes: https://pub.dev/packages/shared_preferences
- Dart linter rules: https://dart.dev/tools/linter-rules

Practical decisions from these sources:

- Do not evaluate Flutter performance with debug builds; use profile builds and the DevTools Performance view.
- Target the 16 ms frame budget for 60 fps, and aim for even lower render times on low-end devices for battery and thermal behavior.
- Make Flutter rules such as `const` widgets, extracting static subtrees from animation builders into `child`, and avoiding unnecessary `Opacity`/clip animations part of lint and review criteria.
- On the Drift side, avoid blocking the main isolate with DB IO; use `NativeDatabase.createInBackground` or Drift isolates where necessary.
- Copying the asset is the correct approach for a pre-populated DB, but it should be handled more deliberately with `LazyDatabase` or background opening.
- Riverpod `select` should only be used where state changes frequently and rebuilds are large; do not spread it everywhere without benchmarks.
- SQLite indexes are designed for both filtering and ordering; without the right index, SQLite can use temporary storage for sorting/grouping.

## Success Metrics

The same metrics should be collected before the refactor starts and after every phase.

### Target Device Profile

Minimum test profile:

- Android phone with 2-4 GB RAM
- Low/mid-range CPU
- Profile build on a real device
- Test both a clean install and a populated user state

### Flows to Measure

1. Cold start: first frame and Splash -> Decks transition.
2. First DB copy: asset copy + DB open time on a clean install.
3. Deck loading: `loadDeck()` duration for A1/A2/B1/B2/C1.
4. Card review: time from button press until the UI becomes interactive again.
5. Exam generation: total `loadQuestions()` duration.
6. Progress screens: weekly/monthly opening duration.
7. Animation: janky frame count during card flip and indicator animations.
8. Memory: heap growth while using a deck and generating an exam.

### Acceptance Thresholds

Initial targets:

- Deck loading p95: under 150 ms.
- Card review DB write p95: under 40 ms, without blocking the UI thread.
- Exam generation p95: under 300 ms.
- Weekly/monthly progress p95: under 100 ms.
- In profile build, near-zero frames over 16 ms during card flip.
- On clean install, DB copy should not feel frozen beyond a spinner/loading state.

These values can be revised after the first profile run; the important part is to repeat the same scenario in every PR.

## Phase 0: Correctness and Measurement Infrastructure

This phase should happen before performance refactoring. Optimizing on top of incorrect language codes and unmeasured performance is risky.

### 0.1 Fix the Language Code Mismatch

Files:

- `lib/core/constants/language_codes.dart`
- `lib/core/constants/app_constants.dart`
- `lib/pages/srs_settings_page.dart`
- Tests if needed

Tasks:

- Standardize DB codes for the active `polydesk.db` as `en`, `tr`, `de`, `fr`, `it`, `pt`, `es`.
- `LanguageCodes.tableNameFor('pt')` should now return `pt`, and `LanguageCodes.tableNameFor('es')` should now return `es`.
- Language-code conversion must not carry backward `pr`/`esp` compatibility; the active schema uses the ISO codes directly.
- `AppConstants.languageTables` should use `pt` and `es`.
- The SRS reset list should use `pt` and `es`.
- The old `tool/migrate_db.dart` was removed. `assets/polydesk.db` is the single current schema source; schema changes reset the development database.
- Verify that no runtime code path still reads `assets/language_data.db`. The current repository scan only found it in `pubspec.yaml`; if that remains true, remove it from the asset list to cut about 2.6 MB from the packaged asset payload.

Acceptance:

- `sqlite3 assets/polydesk.db "SELECT DISTINCT language_code FROM words"` matches the repository constants.
- Portuguese and Spanish deck loading tests do not produce empty results.
- Language-code unit tests cover the seven active ISO codes.

### 0.2 Add Performance Instrumentation

Files:

- New: `lib/core/performance/perf_trace.dart`
- `deck_provider.dart`
- `exam_provider.dart`
- `progress_repository.dart`
- `database.dart`

Tasks:

- Add a lightweight trace helper using `dart:developer` with `Timeline.timeSync` / async tracing.
- Add lightweight logs that run only in debug/profile modes.
- Labels to measure:
  - `db.open`
  - `db.copyAsset`
  - `deck.load`
  - `deck.fetchDue`
  - `deck.fetchNew`
  - `deck.fetchTranslations`
  - `deck.markSeen`
  - `deck.review`
  - `exam.loadQuestions`
  - `progress.weekly`
  - `progress.monthly`

Acceptance:

- These events appear in the DevTools Performance view in profile builds.
- Release builds do not produce noisy logs.

### 0.3 Run Test Commands Cleanly

Record the following commands as the baseline:

```bash
flutter analyze
flutter test
flutter pub outdated
```

Note: During this review, `flutter analyze` initially timed out due to Flutter startup lock from parallel Flutter commands. It should be run again by itself.

## Phase 1: Drift and SQLite Performance

This phase has the highest expected performance gain.

Execution note: make review writes transactional before index redesign work. A slow query is a performance problem; a crash between `updateSrsState` and `insertRevlog` is permanent user-data corruption.

### 1.1 Move the DB Connection to a Background Isolate

File:

- `lib/data/database/database.dart`

Current:

```dart
AppDatabase() : super(DatabaseConnection.delayed(_connect()));
...
return DatabaseConnection(NativeDatabase(File(dbPath), setup: ...));
```

Target:

- Use `NativeDatabase.createInBackground` according to Drift recommendations.
- Keep pre-populated DB copying inside `LazyDatabase` or the existing delayed connection, but after opening, run queries on a background isolate.
- Keep WAL setup.
- Be conservative with read pools for the low-end device target. Start by measuring `readPool: 1` or the default; on a small DB, 4 read isolates can add overhead.

Acceptance:

- UI-thread blocking decreases in DB open and deck loading profile traces.
- `flutter test` passes.
- DB copy and open work correctly on a clean Android real-device install.

### 1.2 Asset DB Copying and Schema Validation

File:

- `database.dart`

Tasks:

- Remove empty catch blocks; asset-copy failures should at least be logged in debug/profile and surfaced as meaningful errors.
- Drift requires a positive `schemaVersion`, so `schemaVersion => 1` remains; it is not a compatibility mechanism, only Drift's contract for the single current schema.
- `assets/polydesk.db` carries the same current schema with `PRAGMA user_version = 1`. There is no `onUpgrade`; schema changes during development require rebuilding the asset and resetting the local database.
- If `assets/language_data.db` is no longer used, decide whether to remove it from pubspec or document why it remains.
- After copy + open, run a lightweight integrity check: `words` must be non-empty, expected language codes must exist, and the five CEFR levels must be present. If this fails, show a blocking error dialog at startup (before the user can navigate to the decks screen) with a clear message like "Database could not be loaded. Please reinstall the app." Do not let the app proceed into a half-functional state where decks appear empty with no explanation.

Acceptance:

- On clean install, a DB copy failure does not silently continue with an empty DB.
- `beforeOpen` only verifies necessary indexes; heavy migration work does not run on every launch.

### 1.3 Redesign Indexes Around Query Patterns

Files:

- `tables.dart`
- `database.dart`
- Potentially `.drift` files

Current problems:

- `fetchDueCards(language, level, date, limit)` sorts with a temporary B-tree.
- `fetchNewCards` sorts with a temporary B-tree due to `ORDER BY RANDOM()`.
- Progress queries are not optimized for `date`.
- `fetchDueCards` also has a structural query-construction issue: it builds one query, then reassigns `q` when `level != null && level != 'fav'`, relying on multiple cascaded `where()` calls being AND-combined. Drift currently handles this, but the code is confusing and fragile. Build this query once with a conditional level predicate, or extract a private helper before changing indexes.

Suggested indexes:

```sql
CREATE INDEX IF NOT EXISTS idx_words_due_queue
ON words (language_code, level, due, card_state);

CREATE INDEX IF NOT EXISTS idx_words_new_queue
ON words (language_code, level, card_state, isSeen, id);

CREATE INDEX IF NOT EXISTS idx_words_progress_date
ON words (language_code, date);

CREATE INDEX IF NOT EXISTS idx_words_fav_word
ON words (language_code, word);

CREATE INDEX IF NOT EXISTS idx_revlog_today_counts
ON revlog (deck_table, review_date, state);
```

Notes:

- Index order is critical with `card_state IN (1,2,3)`. Try `(language_code, level, due, card_state)` to get range/order behavior through `due`. Always verify with `EXPLAIN QUERY PLAN`.
- The current index puts `card_state` before `due`, so after filtering `card_state IN (1,2,3)`, rows are not guaranteed to remain globally sorted by `due`. Moving `due` before `card_state` lets SQLite scan the due range in due order and can remove the temporary ORDER BY B-tree.
- `idx_words_feedback(isSeen, feedback)` does not cover language/level filters; reevaluate as `(language_code, level, isSeen, feedback)` if needed.
- Unnecessary/duplicate indexes add write cost. After new indexes are added, old indexes should be removed based on query plan and benchmark results.

Acceptance:

- `USE TEMP B-TREE FOR ORDER BY` should disappear for the due query, or become measurably irrelevant.
- Progress queries should reduce temporary group/sort cost.
- DB file size and write cost should be checked.

### 1.4 Replace `ORDER BY RANDOM()` with Deterministic Random Selection

Files:

- `database.dart`
- `word_repository.dart`
- `deck_provider.dart`

Current:

```dart
..orderBy([(u) => OrderingTerm.random()])
..limit(limit)
```

Problem:

- SQLite generates a random value for every candidate row and sorts them. This might be acceptable today for 700-1377 rows per level, but it is expensive and does not scale for the low-end device and larger-data target.

Suggested approaches:

1. Simple and safe approach:
   - Count candidates.
   - Pick a random offset.
   - Fetch a contiguous window with `ORDER BY id LIMIT ? OFFSET ?`.
   - Shuffle in Dart at the end of deck building.

2. More balanced approach:
   - Precompute a `random_bucket` or `shuffle_key` column per language/level.
   - Query with `WHERE shuffle_key >= seed ORDER BY shuffle_key LIMIT ?`, then wrap around if needed.
   - Index: `(language_code, level, card_state, isSeen, shuffle_key)`.

3. FSRS-compatible approach:
   - Due cards always come in due order.
   - New cards are not fully random; they are distributed with a stable daily seed. Reopening the same deck on the same day does not produce a completely different card set.

Acceptance:

- The `fetchNewCards` query plan has no random temporary sort.
- Reopening decks keeps card selection varied enough but stable enough.

### 1.5 Make Review Writes Transactional

Files:

- `database.dart`
- `word_repository.dart`
- `deck_provider.dart`

Current:

- `fetchWordById`
- Compute FSRS
- `updateSrsState`
- `insertRevlog`

Target:

- One repository-level method for card review:

```dart
Future<ReviewWriteResult> reviewWord({
  required String language,
  required int wordId,
  required Rating rating,
  required DateTime now,
});
```

- Use `transaction(() async { ... })` on the DB side.
- Add an optimistic guard if needed:
  - Update only if `last_review` still matches the value from the start of the review.
  - If a second tap arrives for the same card, reject the second write.

Acceptance:

- One rating action creates one revlog row.
- Double tap and swipe + button race conditions do not write duplicate reviews.
- Card state and revlog cannot become inconsistent.

### 1.6 Clarify the Date Storage Strategy

Current:

- `due`: `YYYY-MM-DD` string
- `last_review`: ISO string
- `date`: `YYYY-MM-DD` string
- `review_date`: written like an ISO string, while the daily count query performs a string range.

Plan:

- Short term, normalize string formats:
  - Day-level fields: `YYYY-MM-DD`
  - Timestamps: UTC ISO-8601
- Medium term, consider integer epoch day or Unix millis for performance:
  - `due_day INTEGER`
  - `seen_day INTEGER`
  - `reviewed_at_ms INTEGER`
- Under the single-schema policy, this format change rebuilds the development asset and resets the local database; no runtime migration is added.

Acceptance:

- `getTodayCounts` is not affected by timezone and format drift.
- `review_date` daily range queries use an index.

## Phase 2: Deck and FSRS Flow

### 2.1 Reduce Query Count and State Updates in `DeckNotifier.loadDeck`

File:

- `deck_provider.dart`

Current flow:

- Read user settings
- Read deck config
- Read today counts
- Fetch due cards
- Fetch new cards
- Fetch fillers if missing
- Fetch mother-language translations
- Mark selected cards as seen
- One state update

This flow is not bad; the main problems are query optimization and missing transactions. Still, the following improvements should be made:

- Await independent parts such as `userSettings`, `deckConfig`, and `todayCounts` in parallel where possible.
- Move `fetchDueCards`, `fetchNewCards`, and `fetchFillers` into a repository-level `buildDeckQueue` method.
- Consider moving the translation lookup to SQL:
  - `words target`
  - `words mother ON target.id = mother.id AND mother.language_code = ?`
- Select only the columns required for cards. Avoid `SELECT *`.

Acceptance:

- `loadDeck` reads like a single repository call.
- Substeps appear in traces.
- Unnecessary intermediate lists and maps are reduced.

### 2.2 Make FSRS Settings Actually Affect the Scheduler

Files:

- `fsrs_service.dart`
- `deck_provider.dart`
- `deck_config_provider.dart`
- `srs_settings_page.dart`

Current:

- `fsrsServiceProvider` creates a default `FsrsService()`.
- Deck config is read from the DB, but `FsrsService` can remain on default retention/fuzz.

Target:

- Read `requestRetention`, `enableFuzz`, `learningSteps`, and `w` from level/default deck config and apply them during review.
- `FsrsService` can become a stateless helper; scheduler config can be parameterized per review call.
- Add validation for `w` JSON/list parsing.
- If `w` is invalid, fall back to default parameters and log it.

Acceptance:

- Changing retention/fuzz in SRS Settings changes due results for new reviews.
- Unit tests verify retention differences.

### 2.3 Make the Card State Model Fully Compatible with FSRS

Files:

- `fsrs_service.dart`
- `card_state.dart`
- `deck_provider.dart`

Things to check:

- `CardState.new_` is currently mapped as `fsrs.State.learning`. Verify the new-card semantics and the `Card(cardId)` default with the FSRS package documentation.
- `createDefaultCard` might not be used; when a new card is reviewed with DB state=0, the correct FSRS card must be created.
- `elapsedDays` is currently written as 0 on update. Align it with the FSRS package's log and elapsed calculation semantics.
- `scheduledDays` is calculated with `due.difference(now).inDays` and clamp; timezone and day-start behavior must be explicit.
- `legacyFeedback` currently collapses `Rating.good` and `Rating.easy` into the same value. Either expand `feedback` to four distinct values (1-4), or explicitly document it as a coarse legacy bin that must not be used for precise analytics or scheduling.

Acceptance:

- New -> Learning/Review transitions are verified by unit tests.
- Again/Hard/Good/Easy mappings are compatible with revlog state.

### 2.4 Review Idempotency and UI Guard

Files:

- `deck_state.dart`
- `deck_provider.dart`
- `card_flip_page.dart`

Tasks:

- Add `isReviewing` or current-card review status to `DeckState`.
- Rating buttons and swipe should be disabled while `isReviewing` is true.
- `reviewCard` should return early if called again for the same card.
- Check `isReviewing` at the top of both `flipCard` and `reviewCard`. The existing `flipCard` guard partially prevents a second swipe after `isFlipped` becomes true, but rating buttons call `reviewCard` directly and can still pass the `isFlipped` guard during an in-flight DB write.
- Simplify the split between `_isFlippedLocally` and provider `isFlipped`; test double-review and reflip behavior.

Acceptance:

- Fast double tapping creates one revlog record.
- Swipe + button race accepts only one rating.

## Phase 3: Exam and Progress Optimization

### 3.1 Make Exam Generation Batch-Based

File:

- `exam_provider.dart`
- `database.dart`
- `word_repository.dart`

Current:

- Generate random ids per level.
- Query question language for each id.
- Query answer language for each id.
- Query distractors for each question.
- Word id boundaries are hardcoded in `AppConstants.maxWordId` and `AppConstants.levelIdRanges`. If `polydesk.db` is regenerated with different ordering or new rows, exam generation can silently miss valid words or pick ids that do not exist.

This means dozens of DB round trips for 20 questions.

Target:

- Replace hardcoded id ranges with DB-derived level bounds. At exam generation time, query `MIN(id), MAX(id)` per `(language_code, level)` and cache those bounds for the session, or better, sample ids from actual rows for that level.
- Generate all question ids first.
- `fetchWordsByIds(questionLang, allQuestionIds)`
- `fetchWordsByIds(answerLang, allQuestionIds)`
- Fetch the distractor pool with one/few batch queries per level or across the whole language.
- Build questions from maps in Dart.
- Inject `Random()` to make the code testable.

Acceptance:

- Query count in `exam.loadQuestions` drops dramatically.
- Exam generation preserves the same question count and correct-answer mapping.

### 3.2 Make Progress Queries Single and Indexed

Files:

- `progress_repository.dart`
- `database.dart`

Current:

- Weekly: fetches all date counts and maps them to the week list in Dart.
- Monthly: runs 4 separate count queries for 4 months.

Target:

- For weekly, query only the required date range.
- For monthly, use one SQL query with `strftime('%Y-%m', date)` or an integer month bucket.
- Use `idx_words_progress_date(language_code, date)`.
- Normalize `date != "0"` into a clear null/empty distinction.

Acceptance:

- Weekly/monthly screens open with one query or a small number of queries.
- Query plan uses the date index.

### 3.3 Clarify the Favorites Model

Current:

- Favorites are stored in the `words` table as rows where `language_code = 'fav'`.
- Since the primary key is `(language_code, id)`, favorite ids progress separately.
- `isFavorite(word)` only checks word text.

Risks:

- The same word in different languages or with different meanings can create favorite conflicts.
- If `idx_words_fav_word(language_code, word)` is missing, favorite checks can become expensive as favorites grow.
- The favorite deck currently fetches all favorites into memory and then samples in Dart. For a power user with hundreds or thousands of favorites, this creates unnecessary memory and latency.

Target:

- Short term, add the index.
- Add a bounded favorite-card query. Use `LIMIT`, or reuse the count + random offset / shuffle-key strategy from new-card selection instead of loading every favorite row.
- Medium term, move to a separate `favorites` table:
  - `source_language`
  - `source_word_id`
  - `front_word`
  - `back_word`
  - unique `(source_language, source_word_id)`

Acceptance:

- Favorite toggle is fast and correct.
- The same word text on different cards does not produce an incorrect favorite state.

## Phase 4: Flutter UI Performance

### 4.1 Shrink Build Scopes

Files:

- `card_flip_page.dart`
- `exam_page.dart`
- `decks_page.dart`
- `srs_settings_page.dart`
- `weekly_page.dart`
- `monthly_page.dart`

Current good point:

- `CardFlipPage` already uses `deckProvider.select`.

Problem areas:

- `ExamPage` watches the entire `examProvider` state in build and again inside `_buildOption`.
- `DecksPage` mixes local state with async `FutureBuilder`.
- Some lists eagerly create children.

Tasks:

- Split the exam screen into smaller watched values:
  - current question
  - answered
  - selected answer
  - progress
- Pass required primitive values from the parent into `_buildOption` instead of calling `ref.watch(examProvider)` inside it.
- Use `ListView.builder` for lists that can grow.
- Prefer small `const` widget classes over stateless helper functions where appropriate.
- Enforce `const` constructor opportunities with linting.

Acceptance:

- Flutter inspector rebuild counts decrease during card flip and exam answer selection.
- `flutter analyze` remains clean with the new lint rules.

### 4.2 Isolate Animation Subtrees

Files:

- `card_flip_animation.dart`
- `card_flip_page.dart`

Tasks:

- Check whether animation-independent static subtrees inside `AnimatedBuilder` can be moved to the `child` parameter.
- Avoid rebuilding text widgets when card content has not changed.
- Try `RepaintBoundary` for the card animation and indicator row; do not keep it permanently unless DevTools shows a UI/raster frame improvement.
- Measure BoxShadow and 3D transform cost on low-end devices. If needed, reduce shadow blur or use shadows only in static state.

Acceptance:

- Janky frames decrease during flip animation.
- Visual behavior does not change.

### 4.3 Layout and Text Overflow Safety

Files:

- `card_flip_animation.dart`
- `analysis_page.dart`
- `decks_page.dart`
- `srs_settings_page.dart`
- l10n ARB files

Tasks:

- Add responsive constraints for card text:
  - Use `FittedBox` or a maxLines/overflow strategy for long words.
  - Use scroll or dynamic font fallback for sentences.
- On small screens, Analysis buttons should switch to `Wrap` or a vertical layout.
- Check whether localization text fits in buttons.

Acceptance:

- No text overlap at 320 dp width.
- Core screens pass render test or manual smoke test in all 7 languages.

## Phase 5: State, Cache, and Repository Architecture

### 5.1 Make Repository APIs Use-Case Oriented

Current repositories mostly expose DB methods one-to-one. This is simple, but it forces screens to know the query strategy.

Target:

- `WordRepository.buildDeckQueue(...)`
- `WordRepository.reviewCard(...)`
- `WordRepository.buildExam(...)`
- `ProgressRepository.fetchWeeklyProgress(...)`
- `ProgressRepository.fetchMonthlyProgress(...)`

These methods should hide transactions, batching, index-friendly SQL, and domain mapping internally.

Acceptance:

- Provider files orchestrate screen state instead of data-fetching algorithms.
- DB optimization can happen without touching UI files.

### 5.2 Clarify Riverpod Lifecycles

Files:

- `database_provider.dart`
- provider files

Tasks:

- Define the lifecycle of `appDatabaseProvider`:
  - If it lives for the whole app, do not make it autoDispose.
  - It should be easy to override in tests.
  - Evaluate whether `ref.onDispose(db.close)` is appropriate.
- Decide whether screen-to-screen caching is desired for progress providers using `FutureProvider.autoDispose`.
- `deckConfigProvider` is invalidated after saving; slider `onChanged` writes to DB on every movement. Move this to debounce or `onChangeEnd`.
- Saving deck config uses `insertOnConflictUpdate`, so every slider tick can become an UPSERT with unique-key conflict checks. At 60 fps slider updates, this can mean dozens of SQLite writes per second. Even after moving DB work to a background isolate, the write volume is wasteful; prefer `onChangeEnd` for persistence and keep transient slider state local.

Acceptance:

- Dragging sliders in SRS settings does not create many DB writes.
- Provider overrides become easier in tests.

### 5.3 Simplify the Settings Storage Decision

Current:

- The `shared_preferences` dependency exists, but user settings are stored in the DB `user` table.

Decision:

- If all settings stay in the Drift DB, remove the `shared_preferences` dependency.
- If SharedPreferences will be used for lightweight app settings, choose the current API deliberately:
  - `SharedPreferencesAsync` or `SharedPreferencesWithCache`.

Acceptance:

- No unused dependency remains.
- The settings source is single and documented.

## Phase 6: Import/Export and Data Portability

### 6.1 Complete Export

File:

- `settings_page.dart`
- repository/database export methods

Current:

- Export only writes favorites and userChoices.
- `seenWords` is an empty placeholder.
- FSRS state, revlog, and deck_config are not exported.

Target:

- Single current JSON format:
  - `exportedAt`
  - `userChoices`
  - `srsProgress`
  - `revlog`
  - `deckConfig`
  - `decks`
  - `deckCards` (including favorites)
- For large exports, consider streaming or chunking; for the current data size, normal JSON is probably enough.

Acceptance:

- Export -> reset -> import restores progress, favorites, SRS due state, and settings.

### 6.2 Make Import Transactional and Validated

Tasks:

- Validate the JSON schema.
- Accept only the active ISO language codes; do not migrate old backup formats.
- Import should be one transaction.
- Define duplicate favorite and revlog id conflict strategy.

Acceptance:

- Broken JSON does not write partial data.
- Old backup files are outside the backward-compatibility scope.

## Phase 7: Tooling, Lint, and Test Strategy

### 7.1 Update the Lint Set

Files:

- `analysis_options.yaml`
- `pubspec.yaml`

Tasks:

- `flutter_lints` 6.0.0 is already in use; keep the lint set clean in CI.
- Additional rules:
  - `prefer_const_constructors`
  - `prefer_const_literals_to_create_immutables`
  - `avoid_print`
  - clarify policy for `unawaited_futures`
  - `discarded_futures`
  - `use_build_context_synchronously`
- Automatic fix:

```bash
dart fix --apply
dart format .
flutter analyze
```

Acceptance:

- Analyze is clean.
- Lint changes do not mix with behavior refactors in the same PR.

### 7.2 Database Tests

Tests to add:

- Language-code mapping test: `es`/`pt` compatible with active DB.
- `fetchDueCards` due order and limit test.
- `fetchNewCards` non-random selection strategy test.
- `reviewCard` transaction/idempotency test.
- `getTodayCounts` timezone and state filter test.
- Import/export roundtrip test.

Test DB:

- In-memory Drift DB.
- Small fixture dataset.
- If needed, asset DB smoke test as a separate integration test.

### 7.3 Performance Regression Test

Add:

- `integration_test/perf_deck_flow_test.dart`
- `integration_test/perf_exam_flow_test.dart`

Scenarios:

- Open app.
- Select languages.
- Open A1 deck.
- Review 10 cards.
- Open exam.
- Open weekly/monthly progress.

Acceptance:

- Timeline summary is saved as a CI artifact.
- At minimum, local release/profile build commands are documented.

## Phase 8: Package and Platform Updates

This phase should happen after the performance refactor or in separate PRs.

### 8.1 Riverpod 3 Migration

Why:

- Riverpod 3.x is available and includes async provider lifecycle improvements.

Risk:

- API changes and behavior differences are possible.

Plan:

- Read the Riverpod changelog first.
- Do not migrate without provider tests.
- Upgrade `flutter_riverpod` and `riverpod` together.

### 8.2 share_plus, file_picker, and path_provider

Plan:

- `path_provider` minor update is low risk.
- `share_plus` 13.3.0 and `file_picker` 12.0.0 are in use; the import/export flow needs an Android device smoke test.

### 8.3 Dependency Placement

Plan:

- `sqflite_common_ffi` is kept in `dev_dependencies` for tests only; it is not part of the shipped runtime.
- Keep production dependencies limited to packages required by the shipped app. This reduces dependency surface and avoids accidental mobile build weight from tooling-only packages.

### 8.4 Android Build Settings

File:

- `android/app/build.gradle`

Tasks:

- `applicationId = "com.example.poly2"` should change before release.
- `targetSdkVersion 33` and `targetSdk = flutter.targetSdkVersion` are both used; choose one source of truth.
- Measure whether `multiDexEnabled true` is needed; remove it if unnecessary.
- Release signing must not stay on the debug key.

Acceptance:

- Android release/profile build works.
- Target SDK is current for Play Store requirements.

## Implementation Order

Recommended PR order:

1. Language-code mismatch fix and tests.
2. Performance trace helper and baseline measurement.
3. Drift `createInBackground` adoption.
4. Review transaction/idempotency.
5. Query indexes and removal of `ORDER BY RANDOM()`.
6. Exam batch refactor.
7. Progress query refactor.
8. UI rebuild/animation optimizations.
9. Import/export completion.
10. Lint and dependency upgrade PRs.

This order is deliberate: correctness first, then measurement, then the biggest DB/IO gains, then UI and package modernization.

## Checklist for Every PR

- `flutter analyze`
- `flutter test`
- `EXPLAIN QUERY PLAN` for changed DB queries
- DevTools trace for the relevant flow in profile build
- 320 dp small-screen smoke test
- At least one low/mid-range Android device test
- Turkish/English UI smoke test; all 7 languages for language-code changes
- Current-format round-trip test if import/export or schema/format changes

## Open Questions

1. After verifying no runtime references, remove `assets/language_data.db` from the asset bundle; the current repository scan only found it in `pubspec.yaml`.
2. Favorites should remain as language-aware `deck_cards` memberships in the single deck model.
3. Will FSRS `w` parameters be optimized per user, or only manually configured?
4. Are web/desktop targets active? If yes, Drift web/desktop opening strategy should be planned separately from mobile optimization.
5. Should a dedicated asset-schema validation command be added to CI before the next content refresh?

## Definition of Done

When this plan is complete, the expected architecture is:

- One active pre-populated DB: `polydesk.db`
- Standard language codes: `en`, `tr`, `de`, `fr`, `it`, `pt`, `es`
- Drift runs on a background isolate.
- Deck queue queries are index-friendly and do not use random sorting.
- FSRS review writes are transactional and idempotent.
- Exam/progress screens use batch and range queries.
- UI rebuild scopes are small, and animation subtrees are isolated.
- Import/export performs a full roundtrip including FSRS state.
- Performance regressions are measurable.
