# PolyDeck Performans ve Refactor Plani

Tarih: 2026-07-04  
Hedef: PolyDeck'i dusuk donanimli telefonlarda da akici calisan, offline, cok dilli FSRS flashcard uygulamasi haline getirmek.

Bu dokuman, mevcut repoyu tarayarak ve Flutter, Drift, Riverpod, SQLite ve ilgili paketlerin guncel resmi dokumanlarini kontrol ederek hazirlandi. Amac sadece "daha temiz kod" degil; ilk acilis, deste yukleme, kart review etme, sinav uretme, ilerleme ekranlari ve ayarlar gibi kullanicinin hissettigi yollarin olculebilir sekilde hizlanmasi.

## Kisa Ozet

PolyDeck su anda Flutter 3.44.2 / Dart 3.12.2 ile calisiyor. Veri katmani Drift 2.34.0 uzerinden `assets/polydesk.db` icindeki hazir SQLite veritabanini kopyalayip kullaniyor. FSRS icin `package:fsrs` 2.0.1 var. State yonetimi Riverpod 2.6.1.

Oncelikli performans riskleri:

1. Drift baglantisi ana isolate uzerinde `NativeDatabase(File(...))` ile aciliyor. Drift dokumanlari, SQLite'in senkron C kutuphanesi oldugunu ve ana isolate uzerindeki IO'nun UI responsiveness'i dusurebilecegini soyluyor. `NativeDatabase.createInBackground` bu repo icin ilk buyuk kazanim adayi.
2. Yeni kart sorgusu `ORDER BY RANDOM()` kullaniyor. SQLite query plan, bunun temp B-tree sort olusturdugunu gosteriyor. Kelime sayisi arttikca dusuk cihazlarda deste yukleme pahali hale gelir.
3. Due kart sorgusu indeks kullansa bile `ORDER BY due` icin temp B-tree olusturuyor. Indeks sirasi ve `IN (1,2,3)` kullanimi tekrar degerlendirilmeli.
4. Ilerleme sorgulari `date` icin uygun bilesik indeks kullanmiyor; `GROUP BY date` ve aylik count sorgulari dil bazinda daha iyi indekslenebilir.
5. Aktif `assets/polydesk.db` icinde `language_code` degerleri `es` ve `pt`, fakat `LanguageCodes` ve bazi reset/export kodlari hala eski `esp` ve `pr` adlarini kullaniyor. Bu performans degil, dogrudan dogruluk sorunu.
6. Kart review akisinda `fetchWordById -> updateSrsState -> insertRevlog` tek transaction degil. Ayni kart icin cift review yazma ve kismi yazim riski var.
7. Exam uretimi cok sayida ard arda DB sorgusu yapiyor. Soru ve distractor secimi batch sorguya tasinmali.
8. UI katmaninda bazi yerlerde `ref.watch` tum state'i dinliyor, `ListView` yerine eager `ListView(children: map(...).toList())` kullaniliyor ve animasyon subtree'leri daha fazla izole edilebilir.

## Repo Gercegi

### Teknoloji ve paketler

`flutter pub deps --style=compact` sonucuna gore:

- Flutter SDK: 3.44.2
- Dart SDK: 3.12.2
- `drift`: 2.34.0
- `drift_dev`: 2.34.0
- `sqlite3_flutter_libs`: 0.5.42
- `flutter_riverpod`: 2.6.1
- `fsrs`: 2.0.1
- `shared_preferences`: 2.5.5
- `share_plus`: 10.1.4
- `file_picker`: 8.3.7
- `flutter_lints`: 4.0.0

`flutter pub outdated` notlari:

- Riverpod 3.3.2 resolvable.
- `share_plus` 13.2.0 resolvable.
- `file_picker` icin stable latest 11.0.2; resolvable satiri beta 12.0.0-beta.7 gosteriyor, stable hedeflenmeli.
- `flutter_lints` 6.0.0 latest.
- `path_provider` 2.1.6 minor update.
- `sqlite3_flutter_libs` 0.6.0+eol latest olarak gorunuyor; bu paket icin changelog ve Drift uyumlulugu ayrica kontrol edilmeden otomatik major/minor update yapilmamali.

### Veritabani durumu

Dosya boyutlari:

- `assets/polydesk.db`: yaklasik 5.1 MB
- `assets/language_data.db`: yaklasik 2.6 MB

Aktif `polydesk.db` tablolari:

- `words`
- `revlog`
- `deck_config`
- `user`

`words` tek tablo modeline gecmis. Her dilde ayni CEFR dagilimi var:

- A1: 703
- A2: 723
- B1: 738
- B2: 1377
- C1: 1258
- Toplam: dil basina 4799, 7 dilde 33593 kelime satiri

Aktif `words.language_code` degerleri:

- `en`, `tr`, `de`, `fr`, `it`, `pt`, `es`

Bu onemli: `lib/core/constants/language_codes.dart` hala `pt -> pr`, `es -> esp` map ediyor. `assets/language_data.db` eski tablo adlarini (`pr`, `esp`) tasiyor olabilir, fakat uygulama artik `polydesk.db` icindeki birleşik `words` tablosunu okuyor. Bu map mevcut haliyle Ispanyolca ve Portekizce akislari bozabilir.

Mevcut indeksler:

- `idx_words_lang_level_state_due(language_code, level, card_state, due)`
- `idx_words_lang_level_state_seen(language_code, level, card_state, isSeen)`
- `idx_words_lang_level_isSeen(language_code, level, isSeen)`
- `idx_words_feedback(isSeen, feedback)`
- `idx_revlog_card(deck_table, card_id)`
- `idx_revlog_date(review_date)`
- `idx_revlog_deck_date_state(deck_table, review_date, state)`

Query plan bulgulari:

- Due kart sorgusu `idx_words_lang_level_state_due` kullaniyor ama `ORDER BY due` icin temp B-tree olusturuyor.
- Yeni kart sorgusu `idx_words_lang_level_state_seen` kullaniyor ama `ORDER BY RANDOM()` icin temp B-tree olusturuyor.
- Haftalik progress sorgusu dil primary key indeksini kullaniyor ama `GROUP BY date` icin temp B-tree olusturuyor.
- Aylik progress sorgusu sadece `language_code` uzerinden ariyor; `date` range'i indekslenmiyor.

### Kritik kod yolları

- DB acilisi: `lib/data/database/database.dart`
- Drift tablo tanimlari: `lib/data/database/tables.dart`
- Deste yukleme/review: `lib/presentation/providers/deck_provider.dart`
- Kart UI ve animasyon: `lib/pages/card_flip_page.dart`, `lib/presentation/widgets/card_flip_animation.dart`
- Exam uretimi: `lib/presentation/providers/exam_provider.dart`
- Progress sorgulari: `lib/data/repositories/progress_repository.dart`
- Ayarlar/import/export: `lib/pages/settings_page.dart`, `lib/pages/srs_settings_page.dart`
- Dil kodlari: `lib/core/constants/language_codes.dart`, `lib/core/constants/app_constants.dart`

## Arastirma Kaynaklari

Bu plan icin kullanilan temel kaynaklar:

- Flutter performance best practices: https://docs.flutter.dev/perf/best-practices
- Flutter DevTools Performance view: https://docs.flutter.dev/tools/devtools/performance
- Drift isolates: https://drift.simonbinder.eu/isolates/
- Drift existing/pre-populated databases: https://drift.simonbinder.eu/examples/existing_databases/
- Drift native VM setup and `NativeDatabase.createInBackground`: https://drift.simonbinder.eu/platforms/vm/
- Riverpod `select` ile rebuild azaltma: https://riverpod.dev/docs/how_to/select
- SQLite query planner: https://sqlite.org/queryplanner.html
- Dart-FSRS API docs: https://pub.dev/documentation/fsrs/latest/
- shared_preferences API notlari: https://pub.dev/packages/shared_preferences
- Dart linter rules: https://dart.dev/tools/linter-rules

Kaynaklardan cikan pratik kararlar:

- Flutter performansini debug build ile degerlendirme; profile build ve DevTools Performance view kullan.
- 60 fps icin 16 ms frame butcesini, dusuk cihazlarda ve pil/termal etki icin daha da dusuk render surelerini hedefle.
- `const` widget'lar, animasyon builder'larinda statik subtree'yi `child` olarak ayirma, gereksiz `Opacity`/clip animasyonlarindan kacinma gibi Flutter kurallarini otomatik lint ve review kriteri yap.
- Drift tarafinda ana isolate'i DB IO ile bloklama; `NativeDatabase.createInBackground` veya gerekli yerde Drift isolate kullan.
- Pre-populated DB icin asset kopyalama dogru yaklasim, ancak bunun `LazyDatabase` veya background acilis ile daha kontrollu yapilmasi gerekir.
- Riverpod `select` sadece gercekten sik degisen ve buyuk rebuild yaratan yerlerde kullanilmali; benchmark olmadan her yere yayilmamali.
- SQLite indeksleri hem filtreleme hem siralama icin tasarlanir; uygun indeks yoksa SQLite siralama/gruplama icin temp storage kullanabilir.

## Basari Metrikleri

Refactor baslamadan once ve her faz sonunda ayni metrikler alinmali.

### Hedef cihaz profili

Minimum test profili:

- 2-4 GB RAM Android telefon
- Dusuk/orta sinif CPU
- Gercek cihazda profile build
- Uygulama temiz kurulum ve dolu kullanici state'i ile test edilmeli

### Olculecek yollar

1. Cold start: ilk frame ve Splash -> Decks gecisi.
2. Ilk DB kopyalama: temiz kurulumda asset kopyalama + DB acilis suresi.
3. Deste yukleme: A1/A2/B1/B2/C1 icin `loadDeck()` suresi.
4. Kart review: butona basildiktan sonra UI'nin tekrar interaktif hale gelme suresi.
5. Exam uretimi: `loadQuestions()` toplam suresi.
6. Progress ekranlari: weekly/monthly acilis suresi.
7. Animasyon: kart flip ve indicator animasyonlarinda jank frame sayisi.
8. Memory: deste calisirken ve exam uretilirken heap artisi.

### Kabul esikleri

Ilk hedefler:

- Deste yukleme p95: 150 ms altinda.
- Kart review DB yazimi p95: 40 ms altinda, UI thread'i bloklamadan.
- Exam uretimi p95: 300 ms altinda.
- Weekly/monthly progress p95: 100 ms altinda.
- Profile build'de kart flip sirasinda 16 ms ustu frame sayisi sifira yakin.
- Temiz kurulumda DB kopyalama kullaniciya spinner disinda takilma hissettirmemeli.

Bu degerler ilk profil sonucuna gore revize edilebilir; onemli olan her PR'da ayni senaryoyu tekrar olcmek.

## Faz 0: Dogruluk ve Olcum Altyapisi

Bu faz performans refactor'undan once yapilmali. Cunku dogru olmayan dil kodlari ve olculmeyen performans uzerine optimizasyon yapmak risklidir.

### 0.1 Dil kodu uyumsuzlugunu duzelt

Dosyalar:

- `lib/core/constants/language_codes.dart`
- `lib/core/constants/app_constants.dart`
- `lib/pages/srs_settings_page.dart`
- `tool/migrate_db.dart`
- Gerekirse testler

Yapilacaklar:

- Aktif `polydesk.db` icin DB kodlarini `en`, `tr`, `de`, `fr`, `it`, `pt`, `es` olarak standartlastir.
- `LanguageCodes.tableNameFor('pt')` artik `pt`, `LanguageCodes.tableNameFor('es')` artik `es` donmeli.
- `displayCodeFor` icinde eski `pr`/`esp` sadece legacy import/migration uyumlulugu icin desteklenebilir.
- `AppConstants.languageTables` `pt` ve `es` kullanmali.
- SRS reset listesi `pt` ve `es` kullanmali.
- `tool/migrate_db.dart` eski tek tablo oncesi DB'ler icin tutulacaksa adi ve kapsamı netlestirilmeli; aktif DB migrator'u gibi algilanmamali.

Kabul:

- `sqlite3 assets/polydesk.db "SELECT DISTINCT language_code FROM words"` ile kod listesi repo sabitleriyle ayni.
- Portekizce ve Ispanyolca deste yukleme testleri bos sonuc uretmiyor.
- Dil kodu unit testleri hem modern hem legacy mapping'i kapsiyor.

### 0.2 Performans instrumentation ekle

Dosyalar:

- Yeni: `lib/core/performance/perf_trace.dart`
- `deck_provider.dart`
- `exam_provider.dart`
- `progress_repository.dart`
- `database.dart`

Yapilacaklar:

- `dart:developer` ile `Timeline.timeSync` / async trace helper ekle.
- Sadece debug/profile modda calisan hafif loglar ekle.
- Olculecek label'lar:
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

Kabul:

- Profile build DevTools Performance view'da bu event'ler gorunmeli.
- Release build'de noisy log olmamali.

### 0.3 Test komutlarini temiz calistir

Su komutlar baseline olarak kaydedilmeli:

```bash
flutter analyze
flutter test
flutter pub outdated
```

Not: Bu incelemede `flutter analyze` paralel Flutter komutlari yuzunden startup lock'a takilip zaman asimina dustu. Tek basina tekrar calistirilmali.

## Faz 1: Drift ve SQLite Performansi

Bu faz en yuksek beklenen performans kazancini verir.

### 1.1 DB baglantisini background isolate'a tasi

Dosya:

- `lib/data/database/database.dart`

Mevcut:

```dart
AppDatabase() : super(DatabaseConnection.delayed(_connect()));
...
return DatabaseConnection(NativeDatabase(File(dbPath), setup: ...));
```

Hedef:

- Drift'in onerisine uygun olarak `NativeDatabase.createInBackground` kullan.
- Pre-populated DB kopyalama asamasini `LazyDatabase` veya mevcut delayed connection icinde koru, ama acilis sonrasi sorgular background isolate'ta calissin.
- WAL setup'i koru.
- Read pool'u dusuk cihaz hedefi icin temkinli kullan. Baslangic icin `readPool: 1` veya default olculsun; cok kucuk DB'de 4 read isolate ek maliyet olabilir.

Kabul:

- DB acilis ve deste yukleme profile trace'lerinde UI thread bloklanmasi azalir.
- `flutter test` gecmeli.
- Android gercek cihazda temiz kurulumda DB kopyalama ve acilis sorunsuz.

### 1.2 Asset DB kopyalama ve schema dogrulama

Dosya:

- `database.dart`

Yapilacaklar:

- Bos catch bloklarini kaldir; asset kopyalama hatasi en azindan debug/profile loglanmali ve kullaniciya anlamli hata tasinmali.
- Kopyalanan DB icin `PRAGMA user_version` veya `schemaVersion` ile uygulama versiyonu arasinda net sozlesme kur.
- `schemaVersion => 1` aktif pre-populated DB ile uyumlu ama gelecekte asset DB degisirse migration stratejisi gerekiyor.
- `assets/language_data.db` artik kullanilmiyorsa pubspec'ten kaldirma veya neden tutuldugunu README'de aciklama karari ver.

Kabul:

- Temiz kurulumda DB kopyalama basarisiz olursa sessizce bos DB ile devam edilmez.
- `beforeOpen` sadece gerekli indeksleri dogrular; agir migration isleri her acilista calismaz.

### 1.3 Indeksleri query pattern'lara gore yeniden tasarla

Dosyalar:

- `tables.dart`
- `database.dart`
- Gerekirse `.drift` dosyalarina gecis

Mevcut problemler:

- `fetchDueCards(language, level, date, limit)` temp B-tree ile sort ediyor.
- `fetchNewCards` `ORDER BY RANDOM()` ile temp B-tree sort ediyor.
- Progress sorgulari `date` icin optimize degil.

Onerilen indeksler:

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

Notlar:

- `card_state IN (1,2,3)` ile indeks sirasi kritik. `due` uzerinden range ve order almak icin `(language_code, level, due, card_state)` denenmeli. Query plan mutlaka `EXPLAIN QUERY PLAN` ile dogrulanmali.
- `idx_words_feedback(isSeen, feedback)` dil/level filtresini kapsamadigi icin gerekirse `(language_code, level, isSeen, feedback)` olarak yeniden degerlendir.
- Gereksiz/duplicate indeksler yazma maliyeti yaratir. Yeni indeksler eklendikten sonra eski indeksler query plan ve benchmark'a gore kaldirilmali.

Kabul:

- Due sorgusu icin `USE TEMP B-TREE FOR ORDER BY` kalkmali veya olculebilir olarak anlamsiz hale gelmeli.
- Progress sorgulari temp group/sort maliyetini azaltmali.
- DB dosya boyutu ve write maliyeti kontrol edilmeli.

### 1.4 `ORDER BY RANDOM()` yerine deterministic random secim

Dosyalar:

- `database.dart`
- `word_repository.dart`
- `deck_provider.dart`

Mevcut:

```dart
..orderBy([(u) => OrderingTerm.random()])
..limit(limit)
```

Problem:

- SQLite her aday satira random deger uretip siralar. 700-1377 satirlik seviye setlerinde bugun kabul edilebilir olabilir, ama dusuk cihaz ve daha buyuk veri hedefinde pahali ve olceksiz.

Onerilen yaklasimlar:

1. Basit ve guvenli yaklasim:
   - Aday count al.
   - Random offset sec.
   - `ORDER BY id LIMIT ? OFFSET ?` ile ardışık pencere al.
   - Deste sonunda Dart tarafinda shuffle et.

2. Daha dengeli yaklasim:
   - Her dil/level icin `random_bucket` veya `shuffle_key` kolonu precompute et.
   - `WHERE shuffle_key >= seed ORDER BY shuffle_key LIMIT ?`, yetmezse bastan tamamla.
   - Indeks: `(language_code, level, card_state, isSeen, shuffle_key)`.

3. FSRS uyumlu yaklasim:
   - Due kartlar her zaman due order ile gelir.
   - New kartlar random degil, gunluk stabil bir seed ile dagitilir. Ayni gun icinde tekrar girince kullanici tamamen farkli kart seti gormez.

Kabul:

- `fetchNewCards` query planinda random temp sort yok.
- Deste tekrar acilislarinda kart secimi yeterince cesitli ama tutarli.

### 1.5 Review yazimini transaction yap

Dosyalar:

- `database.dart`
- `word_repository.dart`
- `deck_provider.dart`

Mevcut:

- `fetchWordById`
- FSRS hesapla
- `updateSrsState`
- `insertRevlog`

Hedef:

- `reviewCard` icin repository seviyesinde tek metod:

```dart
Future<ReviewWriteResult> reviewWord({
  required String language,
  required int wordId,
  required Rating rating,
  required DateTime now,
});
```

- DB tarafinda `transaction(() async { ... })` kullan.
- Gerekirse optimistic guard ekle:
  - `last_review` review basindaki degerle ayniysa update et.
  - Ayni kart icin ayni anda ikinci tap gelirse ikinci yazim reddedilir.

Kabul:

- Tek rating aksiyonu tek revlog satiri uretir.
- UI'da cift tap, swipe + button yaris durumlari cift review yazmaz.
- Kart state ve revlog tutarsiz kalmaz.

### 1.6 Tarih saklama stratejisini netlestir

Mevcut:

- `due`: `YYYY-MM-DD` string
- `last_review`: ISO string
- `date`: `YYYY-MM-DD` string
- `review_date`: ISO string gibi yaziliyor, gunluk count query'si string range yapiyor.

Plan:

- Kisa vadede string formatlari normalize et:
  - Gun bazli alanlar: `YYYY-MM-DD`
  - Zaman damgalari: UTC ISO-8601
- Orta vadede performans icin integer epoch day veya unix millis dusun:
  - `due_day INTEGER`
  - `seen_day INTEGER`
  - `reviewed_at_ms INTEGER`
- Migration maliyeti nedeniyle bu degisim Faz 1 sonrasina alinabilir.

Kabul:

- `getTodayCounts` timezone ve format sapmalarindan etkilenmez.
- `review_date` gunluk range sorgulari indeks kullanir.

## Faz 2: Deste ve FSRS Akisi

### 2.1 `DeckNotifier.loadDeck` sorgu sayisini ve state update sayisini azalt

Dosya:

- `deck_provider.dart`

Mevcut akis:

- user settings oku
- deck config oku
- today counts oku
- due cards oku
- new cards oku
- eksik varsa fillers oku
- mother language translations oku
- selected kartlari seen isaretle
- tek state update

Bu akis fena degil; asil sorun query optimizasyonu ve transaction eksikligi. Yine de su iyilestirmeler yapilmali:

- `userSettings`, `deckConfig`, `todayCounts` bagimsiz kisimlarini mumkun oldugunca paralel bekle.
- `fetchDueCards`, `fetchNewCards`, `fetchFillers` sorgularini repository seviyesinde `buildDeckQueue` metodunda topla.
- Translation join'i SQL seviyesine almayi degerlendir:
  - `words target`
  - `words mother ON target.id = mother.id AND mother.language_code = ?`
- Deste icin gereken sadece kolonlari sec. `SELECT *` yerine kartta kullanilan alanlar.

Kabul:

- `loadDeck` tek repository cagrisi gibi okunur.
- Trace'te alt adimlar gorunur.
- Gereksiz ara listeler ve map'ler azalir.

### 2.2 FSRS ayarlari gercekten scheduler'a yansisin

Dosyalar:

- `fsrs_service.dart`
- `deck_provider.dart`
- `deck_config_provider.dart`
- `srs_settings_page.dart`

Mevcut:

- `fsrsServiceProvider` default `FsrsService()` uretiyor.
- Deck config DB'den okunuyor ama `FsrsService` default retention/fuzz ile kalabilir.

Hedef:

- Level/default deck config'ten `requestRetention`, `enableFuzz`, `learningSteps`, `w` okunup review sirasinda scheduler'a uygulanmali.
- `FsrsService` stateless helper'a cevrilebilir; scheduler config review cagrisinda parametrelenebilir.
- `w` JSON/list parse validasyonu eklenmeli.
- Invalid `w` durumunda default parameters'a dus ve logla.

Kabul:

- SRS Settings'te retention/fuzz degisince yeni review'larin due sonucu degisir.
- Unit test retention farkini dogrular.

### 2.3 Kart state modelini FSRS ile tam uyumlu hale getir

Dosyalar:

- `fsrs_service.dart`
- `card_state.dart`
- `deck_provider.dart`

Kontrol edilecekler:

- `CardState.new_` su anda `fsrs.State.learning` olarak map ediliyor. FSRS paketinde yeni kart yaratma semantigi ve `Card(cardId)` varsayimi dokumandan kontrol edilmeli.
- `createDefaultCard` kullanilmiyor olabilir; yeni kart review edilirken DB state=0 iken dogru FSRS card uretilmeli.
- `elapsedDays` su anda update'te 0 yaziliyor. FSRS paketinin log ve elapsed hesaplariyla uyumlu hale getirilmeli.
- `scheduledDays` `due.difference(now).inDays` clamp ile hesaplanıyor; timezone ve gun baslangici netlestirilmeli.

Kabul:

- New -> Learning/Review gecisleri unit test ile dogrulanir.
- Again/Hard/Good/Easy mapping testleri revlog state'iyle uyumlu.

### 2.4 Review idempotency ve UI guard

Dosyalar:

- `deck_state.dart`
- `deck_provider.dart`
- `card_flip_page.dart`

Yapilacaklar:

- `DeckState` icine `isReviewing` veya current card review status ekle.
- Rating butonlari ve swipe, `isReviewing` true iken disabled olmali.
- `reviewCard` ayni kart icin ikinci kez cagrilirsa erken donmeli.
- `_isFlippedLocally` ile provider `isFlipped` ayrimi sadeleştirilmeli; cift review ve reflip davranisi test edilmeli.

Kabul:

- Hizli cift tiklama tek revlog kaydi uretir.
- Swipe + button yarisinda tek rating kabul edilir.

## Faz 3: Exam ve Progress Optimizasyonu

### 3.1 Exam uretimini batch hale getir

Dosya:

- `exam_provider.dart`
- `database.dart`
- `word_repository.dart`

Mevcut:

- Her level icin random id uretiliyor.
- Her id icin question language sorgusu.
- Her id icin answer language sorgusu.
- Her soru icin distractor sorgusu.

Bu, 20 soru icin onlarca DB round-trip demek.

Hedef:

- Tum question id'lerini bastan uret.
- `fetchWordsByIds(questionLang, allQuestionIds)`
- `fetchWordsByIds(answerLang, allQuestionIds)`
- Distractor pool'u level veya tum dil icin tek/birkac batch sorgu ile al.
- Sorular Dart tarafinda map'lerden olusturulsun.
- `Random()` injection ile test edilebilir hale gelsin.

Kabul:

- `exam.loadQuestions` sorgu sayisi dramatik azalir.
- Sinav uretimi ayni soru sayisini ve dogru cevap mapping'ini korur.

### 3.2 Progress sorgularini tek ve indeksli yap

Dosyalar:

- `progress_repository.dart`
- `database.dart`

Mevcut:

- Weekly: tum tarih countlarini cekip Dart tarafinda hafta listesine map'liyor.
- Monthly: 4 ay icin 4 ayri count sorgusu.

Hedef:

- Weekly icin sadece gereken date range'i sorgula.
- Monthly icin tek SQL ile `strftime('%Y-%m', date)` veya integer month bucket uzerinden group et.
- `idx_words_progress_date(language_code, date)` kullan.
- `date != "0"` yerine null/empty ayrimi normalize edilsin.

Kabul:

- Weekly/monthly ekranlari tek sorgu veya az sayida sorgu ile acilir.
- Query plan date indeksini kullanir.

### 3.3 Favorites modelini netlestir

Mevcut:

- Favoriler `words` tablosunda `language_code = 'fav'` satirlari olarak tutuluyor.
- Primary key `(language_code, id)` oldugu icin fav id ayri ilerliyor.
- `isFavorite(word)` sadece word text'e bakiyor.

Riskler:

- Ayni kelime farkli dillerde veya farkli anlamlarda favorite conflict yaratabilir.
- `idx_words_fav_word(language_code, word)` yoksa favori kontrolu buyudukce pahali olur.

Hedef:

- Kisa vadede indeks ekle.
- Orta vadede `favorites` ayri tablo olsun:
  - `source_language`
  - `source_word_id`
  - `front_word`
  - `back_word`
  - unique `(source_language, source_word_id)`

Kabul:

- Favori toggle hizli ve dogru.
- Ayni word text farkli kartlarda yanlis favori durumu uretmez.

## Faz 4: Flutter UI Performansi

### 4.1 Build scope'lari kucult

Dosyalar:

- `card_flip_page.dart`
- `exam_page.dart`
- `decks_page.dart`
- `srs_settings_page.dart`
- `weekly_page.dart`
- `monthly_page.dart`

Mevcut iyi nokta:

- `CardFlipPage` zaten `deckProvider.select` kullaniyor.

Sorunlu noktalar:

- `ExamPage` tum `examProvider` state'ini build ve `_buildOption` icinde tekrar tekrar watch ediyor.
- `DecksPage` icinde local state + async FutureBuilder karisik.
- Bazi listeler eager children uretiyor.

Yapilacaklar:

- Exam ekraninda ana state'i parcalara bol:
  - current question
  - answered
  - selected answer
  - progress
- `_buildOption` icinde `ref.watch(examProvider)` yerine parent'tan gerekli primitive degerleri parametre olarak gec.
- Buyuyen listelerde `ListView.builder` kullan.
- Stateless helper function yerine mumkun yerde kucuk `const` widget siniflari kullan.
- `const` constructor firsatlarini lint ile zorunlu hale getir.

Kabul:

- Flutter inspector rebuild count'lari kart flip ve exam seciminde azalir.
- `flutter analyze` yeni lint kurallariyla temiz kalir.

### 4.2 Animasyon subtree'lerini izole et

Dosyalar:

- `card_flip_animation.dart`
- `card_flip_page.dart`

Yapilacaklar:

- `AnimatedBuilder` icinde animasyondan bagimsiz statik subtree'leri `child` parametresine tasima imkani kontrol edilsin.
- Kart icerigi degismedikce text widget'lari yeniden kurulmasin.
- `RepaintBoundary` kart animasyonu ve indicator row icin denenmeli; DevTools raster/UI frame etkisi olculmeden kalici yapilmasin.
- BoxShadow ve 3D transform dusuk cihazda olculmeli. Gerekirse shadow blur azaltilir veya sadece static state'te kullanilir.

Kabul:

- Flip animasyonunda jank frame azalir.
- Gorsel davranis degismez.

### 4.3 Layout ve text overflow guvenligi

Dosyalar:

- `card_flip_animation.dart`
- `analysis_page.dart`
- `decks_page.dart`
- `srs_settings_page.dart`
- l10n ARB dosyalari

Yapilacaklar:

- Kart metinleri icin responsive constraint:
  - Uzun kelimelerde `FittedBox` veya maxLines/overflow stratejisi.
  - Cumleler icin scroll veya dynamic font fallback.
- Analysis butonlari kucuk ekranlarda `Wrap` veya vertical layout'a gecsin.
- Lokalizasyon metinleri butonlara sigiyor mu kontrol edilsin.

Kabul:

- 320 dp genislikte text overlap yok.
- 7 dilde temel ekranlar render test veya manuel smoke testten gecer.

## Faz 5: State, Cache ve Repository Mimarisi

### 5.1 Repository API'larini use-case odakli yap

Mevcut repository'ler DB metodlarini neredeyse bire bir expose ediyor. Bu basit ama ekranlarin sorgu stratejisini bilmesine neden oluyor.

Hedef:

- `WordRepository.buildDeckQueue(...)`
- `WordRepository.reviewCard(...)`
- `WordRepository.buildExam(...)`
- `ProgressRepository.fetchWeeklyProgress(...)`
- `ProgressRepository.fetchMonthlyProgress(...)`

Bu metodlar transaction, batch, indeks dostu SQL ve domain mapping'i iceride saklamali.

Kabul:

- Provider dosyalari veri cekme algoritmasi yerine ekran state orkestrasyonu yapar.
- DB optimizasyonu UI dosyalarina dokunmadan yapilabilir.

### 5.2 Riverpod yasam dongusunu netlestir

Dosyalar:

- `database_provider.dart`
- provider dosyalari

Yapilacaklar:

- `appDatabaseProvider` singleton kapanis davranisi tanimlanmali:
  - App boyunca yasayacaksa autoDispose olmasin.
  - Testlerde override edilebilir olmali.
  - `ref.onDispose(db.close)` uygun mu degerlendir.
- `FutureProvider.autoDispose` kullanilan progress provider'larda ekranlar arasi cache isteniyor mu karar ver.
- `deckConfigProvider` save sonrasi invalidate ediliyor; slider onChanged her hareketinde DB yaziyor. Bunu debounce veya onChangeEnd'e tasimak daha iyi.

Kabul:

- SRS ayarlarinda slider suruklerken cok sayida DB write olmaz.
- Testlerde provider override kolaylasir.

### 5.3 Settings storage kararini sadeleştir

Mevcut:

- `shared_preferences` dependency var ama user settings DB'de `user` tablosunda tutuluyor.

Karar:

- Eger tum ayarlar Drift DB'de tutulacaksa `shared_preferences` dependency kaldirilabilir.
- Eger lightweight app settings icin SharedPreferences kullanilacaksa guncel API secilmeli:
  - Yeni kodda `SharedPreferencesAsync` veya `SharedPreferencesWithCache` secimi bilincli yapilmali.

Kabul:

- Kullanilmayan dependency yok.
- Ayar kaynagi tek ve belgelenmis.

## Faz 6: Import/Export ve Veri Tasima

### 6.1 Export'u tamamla

Dosya:

- `settings_page.dart`
- repository/database export metodlari

Mevcut:

- Export sadece favorites ve userChoices yaziyor.
- `seenWords` bos placeholder.
- FSRS state, revlog, deck_config export edilmiyor.

Hedef:

- Versiyonlu JSON schema:
  - `schemaVersion`
  - `exportedAt`
  - `userChoices`
  - `favorites`
  - `srsProgress`
  - `revlog`
  - `deckConfig`
- Buyuk export icin streaming veya chunk dusunulebilir; mevcut veri boyutunda normal JSON yeterli olabilir.

Kabul:

- Export -> reset -> import sonrasi progress, favorites, SRS due state ve ayarlar geri gelir.

### 6.2 Import'u transaction ve validate ile yap

Yapilacaklar:

- JSON schema validate et.
- Legacy `pr`/`esp` kodlarini `pt`/`es` olarak normalize et.
- Import tek transaction olmali.
- Duplicate favorites ve revlog id conflict stratejisi tanimli olmali.

Kabul:

- Bozuk JSON kismi veri yazmaz.
- Eski backup dosyalari kontrollu migrate edilir.

## Faz 7: Tooling, Lint ve Test Stratejisi

### 7.1 Lint setini guncelle

Dosyalar:

- `analysis_options.yaml`
- `pubspec.yaml`

Yapilacaklar:

- `flutter_lints` 6.0.0'a gecis icin ayri PR.
- Ek kurallar:
  - `prefer_const_constructors`
  - `prefer_const_literals_to_create_immutables`
  - `avoid_print`
  - `unawaited_futures` politikasini netlestir
  - `discarded_futures`
  - `use_build_context_synchronously`
- Otomatik fix:

```bash
dart fix --apply
dart format .
flutter analyze
```

Kabul:

- Analyze temiz.
- Lint degisikligi davranis refactor'u ile ayni PR'a karismasin.

### 7.2 Veritabani testleri

Eklenecek testler:

- Dil kodu mapping testi: `es`/`pt` aktif DB ile uyumlu.
- `fetchDueCards` due order ve limit testi.
- `fetchNewCards` random olmayan secim stratejisi testi.
- `reviewCard` transaction/idempotency testi.
- `getTodayCounts` timezone ve state filtresi testi.
- Import/export roundtrip testi.

Test DB:

- In-memory Drift DB.
- Kucuk fixture dataset.
- Gerekirse asset DB smoke testi ayri integration test.

### 7.3 Performance regression testi

Eklenecek:

- `integration_test/perf_deck_flow_test.dart`
- `integration_test/perf_exam_flow_test.dart`

Senaryolar:

- App ac.
- Dil sec.
- A1 deste ac.
- 10 kart review et.
- Exam ac.
- Weekly/monthly progress ac.

Kabul:

- Timeline summary CI artifact olarak kaydedilir.
- En azindan lokal olarak release/profile build komutlari dokumante edilir.

## Faz 8: Paket ve Platform Guncellemeleri

Bu faz performans refactor'undan sonra veya ayrik PR'larla yapilmali.

### 8.1 Riverpod 3 gecisi

Neden:

- Riverpod 3.x mevcut ve async provider yasam dongusunde iyilestirmeler var.

Risk:

- API degisiklikleri ve davranis farklari olabilir.

Plan:

- Once Riverpod changelog okunur.
- Provider testleri eklenmeden gecilmez.
- `flutter_riverpod` ve `riverpod` birlikte upgrade edilir.

### 8.2 share_plus, file_picker ve path_provider

Plan:

- `path_provider` minor update dusuk riskli.
- `share_plus` major update import/export akisini etkileyebilir; manuel Android/iOS test gerekir.
- `file_picker` stable 11.0.2 hedeflenmeli; beta resolvable surume gecilmemeli.

### 8.3 Android build ayarlari

Dosya:

- `android/app/build.gradle`

Yapilacaklar:

- `applicationId = "com.example.poly2"` release oncesi degismeli.
- `targetSdkVersion 33` ve `targetSdk = flutter.targetSdkVersion` birlikte kullanilmis; tek kaynak secilmeli.
- `multiDexEnabled true` ihtiyac var mi olculmeli; gereksizse kaldir.
- Release signing debug key ile kalmamali.

Kabul:

- Android release/profile build sorunsuz.
- Play Store hedefleri icin target SDK guncel.

## Uygulama Sirasi

Onerilen PR sirasi:

1. Dil kodu uyumsuzlugu fix'i ve testler.
2. Performance trace helper ve baseline olcum.
3. Drift `createInBackground` gecisi.
4. Query indeksleri ve `ORDER BY RANDOM()` kaldirma.
5. Review transaction/idempotency.
6. Exam batch refactor.
7. Progress query refactor.
8. UI rebuild/animation optimizasyonlari.
9. Import/export tamamlamasi.
10. Lint ve dependency upgrade PR'lari.

Bu siralama bilincli: once dogruluk, sonra olcum, sonra en buyuk DB/IO kazanimlari, sonra UI ve paket modernizasyonu.

## Her PR Icin Kontrol Listesi

- `flutter analyze`
- `flutter test`
- Degisen DB sorgulari icin `EXPLAIN QUERY PLAN`
- Profile build ile ilgili flow'un DevTools trace'i
- 320 dp kucuk ekran smoke test
- En az bir dusuk/orta Android cihaz testi
- Turkish/English UI smoke test; dil kodu degisikliklerinde tum 7 dil
- Import/export veya migration degisirse eski veri koruma testi

## Acik Sorular

1. `assets/language_data.db` artik kullaniliyor mu? Kullanilmiyorsa kaldirilmasi app size ve kafa karisikligi acisindan iyi olur.
2. `fav` kayitlari `words` icinde kalmaya devam edecek mi, yoksa ayri `favorites` tablosuna tasinacak mi?
3. FSRS `w` parametreleri kullanici bazinda optimize edilecek mi, yoksa sadece manuel ayar mi olacak?
4. Web/desktop hedefleri aktif mi? Aktifse Drift web/desktop acilis stratejisi mobil optimizasyonundan ayri planlanmali.
5. Export/import geriye donuk uyumluluk icin eski backup formati var mi?

## Son Durum Tanimi

Bu plan tamamlandiginda beklenen mimari:

- Tek aktif pre-populated DB: `polydesk.db`
- Standart dil kodlari: `en`, `tr`, `de`, `fr`, `it`, `pt`, `es`
- Drift background isolate uzerinde calisir.
- Deste queue sorgulari indeks dostudur ve random sort yapmaz.
- FSRS review yazimi transaction ve idempotenttir.
- Exam/progress ekranlari batch ve range query kullanir.
- UI rebuild scope'lari kucuktur, animasyon subtree'leri izoledir.
- Import/export FSRS state dahil tam roundtrip yapar.
- Performans regressions olculebilir hale gelmistir.
