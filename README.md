# PolyDeck

A fully offline, multi-language vocabulary learning app built with Flutter. 
Study words using swipeable flashcards, take exams to test your level, and track your progress over time.

## Features

- **Flashcard Decks** — Swipe right (easy), left (hard), or down (medium) to rate words
- **CEFR Levels** — A1 through C1 decks plus a favourites list
- **Exam Mode** — 20-question multi-level test with score-based level recommendation
- **Progress Tracking** — Weekly and monthly bar charts
- **7 Languages** — English, Turkish, German, French, Italian, Portuguese, Spanish
- **Fully Offline** — All word data stored locally in SQLite, no internet required
- **Data Portability** — Export/import your progress and favourites as JSON

## Architecture

```
lib/
├── core/           # App-wide constants, theme, utilities
├── data/           # Repository layer (data access abstraction)
├── domain/         # Business models and enums
├── presentation/   # UI layer
│   ├── pages/      # Full-screen pages
│   ├── providers/  # Riverpod state management
│   └── widgets/    # Reusable widgets
└── services/       # Low-level services (database helper)

test/               # Unit and widget tests
```

### Tech Stack

- **Flutter** — Cross-platform UI
- **Riverpod** — State management
- **SQLite (sqflite)** — Local database (~4800 words per language)
- **flutter_localizations** — i18n with 7 languages

## Getting Started

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

## Project Status

- ✅ Firebase removed — fully offline
- ✅ Repository pattern
- ✅ Riverpod state management
- ✅ Clean architecture
- ✅ Data export/import
- ✅ Proper error handling
