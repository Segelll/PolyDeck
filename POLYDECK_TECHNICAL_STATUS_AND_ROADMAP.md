# PolyDeck Teknik Durum ve Yol Haritası

**Belge amacı:** Bu dosya, PolyDeck üzerinde çalışmaya yeni başlayan bir geliştiricinin veya agent'ın mevcut sistemi hızlı ve doğru biçimde anlayabilmesi için hazırlanmıştır. Mevcut mimariyi, tamamlanan refaktörleri, doğrulama sonuçlarını, bilinçli tasarım kararlarını ve sıradaki işleri tek yerde toplar.

**Son güncelleme:** 2026-08-23
**Ürün durumu:** Pre-production, tamamen offline Flutter uygulaması
**Ana hedef:** FSRS tabanlı flashcard deneyimini düşük donanımlı Android cihazlarda da hızlı, kararlı ve bakımı kolay tutmak.

## 1. Ürünün Kapsamı

PolyDeck, kullanıcının bir ana dil ve bir hedef dil seçerek kelime çalıştığı, yerel SQLite veritabanı kullanan bir flashcard uygulamasıdır.

- Desteklenen diller: `en`, `tr`, `de`, `fr`, `it`, `pt`, `es`
- CEFR seviyeleri: `A1`, `A2`, `B1`, `B2`, `C1`
- Kelime verisi uygulama ile birlikte `assets/polydesk.db` içinde gelir.
- Uygulama internetsiz çalışır; backend veya Firebase yoktur.
- Kart planlama FSRS ile yapılır.
- Kart değerlendirme yöntemleri birbirini dışlar: `Butonlar` veya `Kaydırma`.
- Kullanıcı bugün görülen kelime sayısını ana ekranda görür.
- Deste türleri:
  - Sanal CEFR desteleri: A1-C1
  - Kalıcı sistem destesi: `Favoriler`
  - Kullanıcının oluşturduğu kişisel desteler
- Kart kişisel desteye eklenirken o anda kullanılan `sourceLanguage` ve `targetLanguage` çifti saklanır. Sonradan global dil ayarı değişse bile deste kartı yanlış dilden çözülmez.

## 2. Teknoloji ve Sürüm Baseline'ı

Sürüm yükseltme yapılırken önce bu baseline ve ilgili changelog kontrol edilmelidir.

| Alan | Mevcut teknoloji/sürüm |
|---|---|
| UI/runtime | Flutter `3.47.1`, Dart `3.13.1` |
| State management | Riverpod / Flutter Riverpod `2.6.1` |
| Database | Drift `2.34.3`, SQLite, `sqlite3_flutter_libs` |
| Scheduler | `fsrs` `2.0.1` |
| File import | `file_picker` `12.0.0` |
| File export/share | `share_plus` `13.3.0` |
| Settings/dependency support | `path_provider` `2.1.6`, `intl` `0.20.2` |
| Android language/build | Java 17, Kotlin `2.3.21`, AGP `9.0.1`, Gradle `9.1.0` |
| Package id | `com.example.poly2` (production öncesi placeholder) |

Release derlemesi çalışmaktadır. Ancak Flutter'ın Kotlin Gradle Plugin'i Built-in Kotlin'a taşıma uyarısı devam eder. Bu uyarı şu anda derlemeyi bozmaz; üretim öncesi platform bakım işidir.

## 3. Mimari Harita

Kod dört ana katmanda tutulur. UI ekranları doğrudan SQL veya Drift tabloları ile çalışmamalıdır.

```text
lib/
├── core/
│   ├── constants/       # Dil ve uygulama sabitleri
│   ├── performance/     # PerfTrace ve ölçüm yardımcıları
│   ├── theme/           # AppPalette ve AppTheme
│   └── utils/           # Tarih ve random yardımcıları
├── data/
│   ├── database/        # Drift tabloları, database.g.dart, SQL ve transaction'lar
│   └── repositories/    # Word, Deck, Progress ve User repository'leri
├── domain/
│   ├── enums/            # Rating, CardState, ReviewInputMode vb.
│   ├── models/           # Word, CardModel, DeckSummary, ExamModel vb.
│   └── state/            # DeckState, ExamState, dil tercihleri
├── pages/                # Tam ekran kullanıcı akışları
├── presentation/
│   ├── providers/        # Riverpod provider/notifier'ları
│   └── widgets/          # Yeniden kullanılabilir UI parçaları
└── services/
    └── fsrs_service.dart # FSRS dış kütüphanesi ile domain adapter'ı
```

### Kritik dosyalar

| Sorumluluk | Dosya |
|---|---|
| Uygulama başlangıcı | `lib/main.dart`, `lib/pages/splash_screen.dart` |
| Ana shell ve yan menü | `lib/pages/app_shell.dart` |
| Ana ekran | `lib/pages/home_page.dart` |
| Deste kataloğu | `lib/pages/decks_page.dart` |
| Kart çalışma ekranı | `lib/pages/card_flip_page.dart` |
| Kart animasyonu ve sentence highlight | `lib/presentation/widgets/card_flip_animation.dart`, `highlighted_sentence.dart` |
| FSRS hesabı | `lib/services/fsrs_service.dart` |
| Deste yükleme/review state'i | `lib/presentation/providers/deck_provider.dart` |
| Sınav state'i | `lib/presentation/providers/exam_provider.dart` |
| Drift database | `lib/data/database/database.dart` |
| Drift tabloları | `lib/data/database/tables.dart` |
| Deck üyelikleri | `lib/data/repositories/deck_repository.dart` |
| Progress sorguları | `lib/data/repositories/progress_repository.dart` |
| Tema renkleri | `lib/core/theme/app_palette.dart`, `app_theme.dart` |

## 4. Veritabanı Sözleşmesi

### 4.1 Tek güncel şema politikası

Uygulama henüz production'a alınmadığı için geriye dönük migration dalları ve eski backup şemaları desteklenmez.

- Tek kaynak: `assets/polydesk.db`
- Şema değişirse asset yeniden üretilir ve lokal uygulama verisi sıfırlanır.
- Eski şemayı runtime'da migrate eden karmaşık uyumluluk kodu eklenmez.
- Drift API'si `schemaVersion` için pozitif bir değer gerektirdiğinden `schemaVersion => 1` teknik bir Drift sözleşmesidir; uygulama seviyesinde bir migration/uyumluluk politikası değildir.
- Şema değişiklikleri için yeni `onUpgrade` dalları veya eski kolon fallback'leri eklenmemelidir.
- Bu karar production'a geçişte yeniden değerlendirilir; o zamana kadar veri reset'i bilinçli geliştirme yöntemidir.

### 4.2 Tablolar

`lib/data/database/tables.dart` içindeki aktif tablolar:

- `words`: Tüm diller tek tabloda. Primary key `(language_code, id)`.
  - Kelime, cümle, CEFR seviyesi ve dil kodu
  - FSRS state: `card_state`, `stability`, `difficulty`, `due`, `reps`, `lapses`, `last_review` vb.
  - Günlük çalışma için `isSeen`, `date`, `feedback`
- `revlog`: Her review işleminin rating, önceki state, due ve FSRS çıktısını kaydeder.
- `deck_config`: CEFR seviyesine göre günlük yeni kart/review limiti, retention, fuzz ve learning step ayarları.
- `user`: Ana dil, hedef dil, ilk kullanım bilgisi ve tek review modu.
- `decks`: Sistem ve kullanıcı desteleri.
- `deck_cards`: Deste-kart üyeliği. `source_language` ve `target_language` burada zorunlu olarak saklanır.

### 4.3 DB açılışı ve doğrulama

`AppDatabase`:

1. Uygulama belgeleri klasöründe `polydesk.db` yoksa asset kopyalanır.
2. SQLite `NativeDatabase.createInBackground` ile UI isolate'ını bloklamadan açılır.
3. WAL, `synchronous=NORMAL`, cache, temp store ve mmap ayarları yapılır.
4. Preloaded veri için hafif bütünlük kontrolü yapılır.
5. Asset içindeki index'ler kullanılır; her uygulama açılışında `CREATE INDEX` çalıştırılmaz.

Bütünlük kontrolü şu anda kelime satırlarının, beklenen yedi dil kodunun ve CEFR seviye kümesinin mevcut olduğunu kontrol eder. İleride kontrolün her dil için her seviyeyi ayrı ayrı doğrulaması ve DB kopyalama hatasını kullanıcıya bloklayıcı bir hata olarak göstermesi gerekir.

## 5. Ana Kullanıcı Akışları

### 5.1 Başlangıç

`main.dart` bir `ProviderScope` ile `MyApp`'i başlatır. `SplashScreen`, settings provider'ını uygulama açılışındaki kısa splash süresiyle paralel başlatır. Dil seçimi tamamlanmışsa `AppShell`, ilk kullanımda `FirstTimeSelectionPage` açılır.

`AppShell` varsayılan olarak `initialIndex = 0` ile Ana Sayfa'yı açar. Kullanıcı yan menüden Ana Sayfa ve Destelerim arasında geçer. Daha önce ziyaret edilen shell sekmeleri korunur; shell dışı sayfalar geri dönerken shell'i kaybetmemelidir.

### 5.2 Deste yükleme

`DeckNotifier.loadDeck` genel olarak şu sırayı izler:

1. Kullanıcının ana/hedef dil çiftini okur.
2. Seviye destesi için config ve bugünkü limitleri paralel çeker.
3. Due ve new kart kuyruklarını paralel çeker.
4. Ana dil çevirilerini tek batch sorguyla getirir.
5. Kartları Dart tarafında birleştirip karıştırır.
6. Seçilen kartları tek/az sayıda batch yazma ile `isSeen` olarak işaretler.
7. Yeni bir load isteği daha başlamışsa eski isteğin sonucu state'e yazılmaz.

Favoriler ve kişisel desteler `deck_cards` üzerinden dil çifti bilgisiyle yüklenir. CEFR desteleri `level` üzerinden sanal olarak çalışır.

### 5.3 Kart review

Kartın arka yüzünde:

- hedef dilde kelime,
- hedef dilde cümle,
- ana dilde karşılık ve cümle,
- cümle içinde öğrenilen kelimenin underline vurgusu bulunur.

Kart numarası ve CEFR seviye etiketi gösterilmez. Uzun cümleler fontu anlamsız biçimde küçültmek yerine satır kırabilir.

Review sırası:

1. Kullanıcı kartı açar.
2. Seçilen `Rating` FSRS service'e gider.
3. Güncel kartın `last_review` değeri okunur.
4. FSRS sonucu hesaplanır.
5. `WordRepository.reviewWord` içinde kart update'i ve revlog insert'i tek transaction'da yapılır.
6. `guardLastReview` ile çift tıklama veya yarış durumunda ikinci yazma reddedilir.
7. Başarılı review sonrası analiz state'i ve ana ekran aktivite sayacı güncellenir.

### 5.4 Review giriş modu

`ReviewInputMode` yalnızca iki değere sahiptir: `buttons` ve `swipe`. Settings ekranındaki `SegmentedButton` tek seçimlidir ve seçilen değer `user.review_mode` alanına yazılır.

- `buttons`: Again, Hard, Good, Easy düğmeleri görünür.
- `swipe`: rating düğmeleri gizlenir; kart kaydırma gesture'ı kullanılır.
- İki mod aynı anda render edilmemelidir.

### 5.5 Sınav

`ExamNotifier` beş seviyenin ID'lerini tek batch sorguyla alır. Soru ve cevap kelime batch'leri `Future.wait` ile paralel getirilir. Sınav 20 soruya kadar oluşturulur ve sonuç ekranında puan ile önerilen seviye gösterilir.

Sonuç ekranının geri düğmesi bare `DecksPage` açmaz; `AppShell(initialIndex: 1)` açar. Böylece yan menü ve shell navigasyonu kaybolmaz.

### 5.6 İstatistik ve ayarlar

- Ana sayfa bugünkü görülen kelime sayısını çalışma aktivitesi provider'ı ile yeniler.
- Haftalık grafik geçersiz tarihleri `DateTime.tryParse` ile güvenli ele alır.
- Aylık grafik geçersiz/sentinel tarihleri filtreler; `0` veya boş tarih `FormatException` üretmez.
- SRS ayarlarında seviye limitleri, retention, fuzz ve SRS sıfırlama bulunur.
- Export Android paylaşım seçicisini açar.
- Import Android dosya seçicisini açar.
- Reset işlemleri onay diyaloğu gösterir.

## 6. Tamamlanan Refaktörler

### 6.1 Performans ve veri katmanı

- DB açılışı arka plan isolate'ına taşındı.
- Startup'ta tekrar tekrar index oluşturan ve favorite deck'i zorla yazan işlemler kaldırıldı.
- DB bütünlük kontrolü ayrı sorgular yerine grouped read ile azaltıldı.
- `ORDER BY RANDOM()` yerine random başlangıç ID'si + ID aralığı + Dart shuffle kullanıldı.
- Due/new sorguları, config ve günlük sayaçlar mümkün olan yerlerde paralel çalışıyor.
- Sınav soruları için seviyeler tek batch sorguda çekiliyor.
- Sınav soru/cevap kelimeleri paralel batch sorgularla getiriliyor.
- Progress aylık sorgusu dört ayrı/UNION bucket yerine tek date range scan kullanıyor.
- Review update + revlog insert transaction içinde ve optimistic guard ile yapılıyor.
- Stale deck load sonuçlarının yeni state'i ezmesi engellendi.
- Deste üyeliği ve dil çifti repository katmanında açıkça taşınıyor.

### 6.2 UI ve tema

- Pantone referansındaki düşük doygunluklu renkler `AppPalette` içinde merkezileştirildi.
- Ekranlarda doğrudan kırmızı/mor/mavi gibi dağınık renk kullanımı azaltıldı.
- Açık pastel yüzeylerde okunabilir koyu semantic text color kullanıldı.
- Ana ekran, drawer, deste listesi, ayarlar, sınav, istatistik ve kart ekranları aynı tema sözleşmesini kullanıyor.
- Deste kartları iki sütun yerine bir satırda bir deste olacak şekilde sadeleştirildi.
- Kart animasyonu Transform alignment'ı merkezlendi.
- Kart review düğmeleri pastel yüzeylerde koyu ve okunabilir foreground kullanıyor.
- Add-to-deck sheet, yavaş DB sorgusu bitene kadar tıklamayı kilitlemek yerine hemen açılıyor ve yükleniyor state'i gösteriyor.

### 6.3 Testler ve doğrulama

`test/regression_test.dart` içine şu kritik korumalar eklendi veya güçlendirildi:

- Geçersiz/sentinel tarihlerin earliest/monthly sonuçları bozmaması
- Toplu seviye ID sorgusunun deterministik ve eksiksiz olması
- Sınavın 20 soruya kadar option üretmesi
- Günlük limitlerin seviye bazında uygulanması
- Review transaction ve SRS reset davranışı
- Ana dil cümlesinin karta gelmesi
- Card face üzerinde numara/seviye gösterilmemesi
- Cümle kelime vurgusunun tam eşleşmesi
- Uzun cümlelerin satır kırması
- Kart transform alignment'ının merkezde kalması
- Analysis sonrası yeni destenin gerçekten başlaması
- Exam result dönüşünün shell'e yapılması

`test/theme_test.dart`, `AppPalette` renklerinin ve `AppTheme` bağlantılarının merkezi olduğunu doğrular.

## 7. Doğrulama Kanıtı

Son uygulama turunda aşağıdakiler çalıştırıldı:

```powershell
flutter test --no-pub
flutter analyze lib test
flutter build apk --release
```

Sonuçlar:

- Flutter testleri: `42` test başarılı.
- Static analysis: `No issues found!`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`, yaklaşık `61.4 MB`.
- APK Android emülatöre kurulup yeniden başlatıldı; Ana Sayfa, drawer ve bugünkü sayaç smoke testinden geçti.

Android emülatörde manuel olarak şu akışlar çalıştırıldı:

- Ana Sayfa ve yan menü
- Destelerim sekmeleri: Varsayılan, Kişiselleştirilmiş, Kategoriler
- Favoriler ve CEFR deste açılışı
- Yeni kişisel deste oluşturma
- Plus ile karta deste ekleme ve dil çiftiyle saklama
- Kart açma, hedef dil cümlesi, ana dil cümlesi, underline ve rating
- Butonlar/Kaydırma modlarının birbirini dışlaması
- Analysis sonrası aynı desteyi doğrudan yeniden başlatma
- Haftalık, aylık ve SRS ekranları
- Export paylaşım seçicisi ve Import dosya seçicisi
- Genel veri ve SRS reset onaylarının iptali
- 20 soruluk sınav ve sonuçtan Destelerim shell'ine dönüş

## 8. Değişiklik Commit Haritası

Son refaktör serisinin anlamlı parçaları:

| Commit | İçerik |
|---|---|
| `ffe06e3` | Database, progress ve exam batch/performance sorguları |
| `26d290b` | Review, add-to-deck ve navigation akış düzeltmeleri |
| `d7d8cde` | Merkezi Pantone palette ve UI theme refaktörü |
| `ea1f4fd` | Regression ve palette testleri |

Commit başına tek bir sorumluluk tutulmalıdır. Büyük bir değişiklikte önce test, sonra uygulama, sonra doğrulama ve ayrı commit yaklaşımı kullanılmalıdır.

## 9. Bilinen Kalan Riskler ve Backlog

Aşağıdaki işler tamamlanmış gibi kabul edilmemelidir.

### P0 - Üretim öncesi doğruluk

- [ ] DB asset kopyalama hatasını yalnızca debug loglamak yerine kullanıcıya açık, bloklayıcı bir hata ekranı göstermek.
- [ ] DB bütünlük kontrolünü her dil-seviye kombinasyonu için ayrı doğrulamak.
- [ ] Import/export için tam round-trip testi eklemek: SRS state, revlog, deck config, custom decks ve deck cards birlikte geri gelmeli.
- [ ] Import bozuksa transaction tamamlanmadan hiçbir kısmi veri yazılmamasını doğrulamak.
- [ ] Export formatının tek ve güncel JSON sözleşmesini belgelendirmek. Eski format uyumluluğu eklememek.

### P1 - Gerçek cihaz performans ölçümü

- [ ] Debug yerine profile build ile düşük/orta seviye Android cihazta baseline toplamak.
- [ ] `PerfTrace` olaylarını DevTools Performance timeline'ında ölçmek.
- [ ] Cold start, DB copy/open, deck load, review write, exam generation, weekly/monthly açılışlarını ayrı ölçmek.
- [ ] İlk hedefler: deck load p95 `<150 ms`, review write p95 `<40 ms`, exam p95 `<300 ms`, progress p95 `<100 ms`.
- [ ] Kart flip sırasında 16 ms üzeri frame sayısını ve memory growth'u ölçmek.
- [ ] Ölçüm sonucu olmadan C/Rust/native modül eklememek. Mevcut darboğaz kanıtlanırsa yalnızca izole, küçük bir algoritmik parça taşınabilir.

### P1 - SQLite ve Drift

- [ ] `EXPLAIN QUERY PLAN` ile due/new/progress sorgularını gerçek asset üzerinde tekrar ölçmek.
- [ ] Asset index'lerinin güncel sorgularla uyumlu olduğunu doğrulamak.
- [ ] ID aralığı random seçiminde sparse ID, çok küçük aday kümesi ve limit sınırlarını test etmek.
- [ ] Gerekirse due sıralaması ve progress date aralığı için composite index düzenlemek; gereksiz index eklememek.
- [ ] Her açılışta yazma işlemi olmadığı prensibini korumak.

### P2 - Modülerlik ve bakım

- [ ] `DeckNotifier` içindeki load, review, queue ve mapping sorumluluklarını use-case/repository metotlarına bölmek.
- [ ] Provider'ların SQL veya veri seçme algoritmasını bilmesini azaltmak.
- [ ] `WordRepository.buildDeckQueue`, `reviewCard`, `buildExam` gibi domain'e yakın API'ler tasarlamak.
- [ ] UI'da `ref.watch` kapsamını küçültmek; sık değişen primitive state için gerektiğinde `select` kullanmak.
- [ ] Her yeni abstraction gerçek bir karmaşıklık azaltmalı; sırf katman sayısını artırmak için wrapper eklenmemeli.

### P2 - Flutter UI performansı

- [ ] Exam option widget'larının tüm provider state'ini tekrar tekrar watch etmesini azaltmak.
- [ ] Büyük listelerde `ListView.builder`/`ListView.separated` kullanmaya devam etmek.
- [ ] Animasyonlarda sabit subtree'leri `AnimatedBuilder.child` ile dışarı almak.
- [ ] `RepaintBoundary`, shadow blur ve transform maliyetini profile ölçümüyle değerlendirmek.
- [ ] 320 dp genişlikte ve 7 dilde text overflow smoke testleri eklemek.
- [ ] Ayar slider'larında her `onChanged` hareketinde DB write yerine `onChangeEnd` veya debounce düşünmek.

### P2 - Toolchain ve release

- [ ] Flutter'ın Built-in Kotlin migration'ını tamamlamak.
- [ ] `applicationId` değerini production package id ile değiştirmek.
- [ ] Debug signing yerine release keystore/signing config kullanmak.
- [ ] `targetSdk`, minSdk ve `multiDexEnabled` ayarlarını gerçek ihtiyaçla yeniden değerlendirmek.
- [ ] CI'da `flutter analyze`, `flutter test`, profile/release build ve mümkünse asset DB smoke test çalıştırmak.

## 10. Agent ve Geliştirici Çalışma Protokolü

Bu repo üzerinde yeni bir iş başlatan kişi şu sırayı izlemelidir:

### Değişiklikten önce

1. Bu belgeyi ve ilgili `PERFORMANCE_REFACTOR_PLAN.md` / `PERFORMANCE_REFACTOR_PLAN_EN.md` dosyalarını oku.
2. `git status --short` ve son commitleri kontrol et.
3. Mevcut kullanıcı değişikliklerini geri alma veya `reset --hard` kullanma.
4. Değişikliğin hangi katmana ait olduğunu belirle: domain, data, provider, page veya shared widget.
5. Önce davranışı testle sabitle. DB/FSRS değişikliğinde in-memory Drift test DB kullan.

### Kod yazarken

- UI ekranı doğrudan DB sorgulamaz; repository/provider sınırını korur.
- FSRS hesaplaması `FsrsService` dışına dağılmaz.
- Review update ve revlog insert transaction dışında yapılmaz.
- Dil çifti global ayardan sonradan tekrar türetilmez; `deck_cards` üzerindeki pair kullanılır.
- Tek şema politikasına aykırı migration/fallback/legacy parser eklenmez.
- `AppPalette` dışında yeni renk sabiti eklenmez; semantic color adı tercih edilir.
- Asenkron işlemlerde `mounted`, request id ve yarış koşulları düşünülür.
- `const`, lazy listeler, sınırlı rebuild ve batch DB sorguları varsayılan tercihtir.
- Performans iddiası profile ölçümüyle desteklenmeden native/C/Rust taşıması yapılmaz.

### Değişiklikten sonra

```powershell
dart format <değişen dosyalar>
flutter analyze lib test
flutter test --no-pub
```

UI, DB veya navigation değiştiyse ayrıca:

```powershell
flutter build apk --release
adb install -r build\app\outputs\flutter-apk\app-release.apk
adb shell am force-stop com.example.poly2
adb shell monkey -p com.example.poly2 1
```

Manuel testte en az şu yollar tekrar edilmelidir: başlangıç, drawer, deste açma, kart flip, review, yeni deste, ayarlar, istatistik ve sınav.

### Commit kuralları

Commitler görev bazlı ve küçük olmalıdır:

- `perf: ...` veri/sorgu veya ölçülebilir hız değişikliği
- `fix: ...` kullanıcıya görünen hata veya regresyon düzeltmesi
- `refactor: ...` davranış değiştirmeden mimari/tema düzeni
- `test: ...` test ve regresyon kapsamı
- `docs: ...` teknik dokümantasyon

Bir commit'in doğrulaması commit mesajından veya değişen dosyalardan anlaşılmalıdır. İlgisiz generated dosyalar, format farkları veya kullanıcı değişiklikleri otomatik olarak commit'e alınmamalıdır.

## 11. Mimari Karar Günlüğü

### Flutter'da kalma kararı

Java, Rust veya C ile sıfırdan yazmak teorik olarak bazı CPU işlerini hızlandırabilir; ancak PolyDeck'in ana maliyeti UI, SQLite I/O, state rebuild ve sorgu stratejisidir. Flutter zaten native SQLite ve Dart isolate kullanabiliyor. UI'ı yeniden yazmanın maliyeti yüksek, beklenen kazanç ise ölçülmemiştir.

Karar: Flutter korunur. Önce isolate, batch sorgu, transaction, rebuild sınırı ve profile ölçümü uygulanır. Native/C/Rust yalnızca profile sonucu tek ve belirgin CPU darboğazı kanıtlanırsa küçük bir modül olarak değerlendirilir.

### Tek şema kararı

Uygulama production öncesi olduğu için migration ağacı yerine tek güncel `polydesk.db` asset'i kullanılır. Geliştirme sırasında schema değişikliği uygulama verisi sıfırlanarak çözülür. Bu, kod karmaşıklığını ve eski format dallarını düşük tutar.

### Palet kararı

Pantone referansındaki Lemon Icing, Nimbus Cloud, Raindrops on Roses, Cloud Dancer, Ice Melt, Peach Dust, Almost Aqua ve Orchid Tint renkleri `AppPalette` içinde sabitlenmiştir. Ekranlar bu sınıfı doğrudan veya `AppTheme` semantic alanları üzerinden kullanır. Yeni renk eklemek yerine mevcut semantic karşılıkların yeniden kullanılması tercih edilir.

## 12. Yeni Agent İçin Kısa Başlangıç

Bir agent bu repoya ilk kez geliyorsa:

1. Bu dosyanın 1-5. bölümlerini okuyarak ürün ve akışları anla.
2. 6-7. bölümlerden hangi işlerin tamamlandığını ve hangi kanıtların bulunduğunu kontrol et.
3. 9. bölümden tek bir backlog maddesi seç; kapsamı büyütme.
4. 10. bölümdeki test ve commit protokolünü uygula.
5. Bir davranış mevcut dokümandan farklıysa önce kod ve testleri doğrula, sonra bu belgeyi aynı commit veya ayrı `docs:` commit ile güncelle.

Bu belge planın yerine geçen soyut bir liste değildir; mevcut kod davranışının ve kabul edilen mühendislik kararlarının çalışma sözleşmesidir.
