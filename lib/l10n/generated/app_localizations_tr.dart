// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Polydeck Önizleme';

  @override
  String get cardFront => 'Kart Önü';

  @override
  String get cardBack => 'Kart Arkası';

  @override
  String get flipRed => 'Kırmızı Çevir';

  @override
  String get flipYellow => 'Sarı Çevir';

  @override
  String get flipGreen => 'Yeşil Çevir';

  @override
  String get reflip => 'Tekrar Çevir';

  @override
  String get newCard => 'Yeni Kart';

  @override
  String cardCount(Object index, Object total) {
    return 'Kart $index / $total';
  }

  @override
  String get analysis => 'Analiz';

  @override
  String get analysisResults => 'Analiz Sonuçları:';

  @override
  String previousDeck(Object deckName) {
    return 'Önceki Deste: $deckName';
  }

  @override
  String get startNewDeck => 'Yeni Deste Başlat';

  @override
  String cardAnalysis(Object index, Object color) {
    return 'Kart $index: $color';
  }

  @override
  String get decks => 'Desteler';

  @override
  String get deckPage => 'Desteler Sayfası';

  @override
  String get a1Deck => 'A1 Destesi';

  @override
  String deck(Object index) {
    return 'Deste $index';
  }

  @override
  String get question => 'Soru';

  @override
  String get nextQuestion => 'Sonraki Soru';

  @override
  String get finishExam => 'Sınavı Bitir';

  @override
  String get exam => 'Sınav';

  @override
  String get testResult => 'Test Sonucu';

  @override
  String get recommendation => 'Önerilen Deste';

  @override
  String get score => 'Sonuç';

  @override
  String get red => 'Kırmızı';

  @override
  String get yellow => 'Sarı';

  @override
  String get green => 'Yeşil';

  @override
  String get grey => 'Gri';

  @override
  String get instructionsTitle => 'Talimatlar';

  @override
  String get instructionsContent =>
      'Karta dokunup çevirin, sonra bir derecelendirme seçin:\n◉ Tekrar — sıfırla ve yeniden öğren\n◉ Zor — daha kısa aralık\n◉ İyi — standart aralık\n◉ Kolay — daha uzun aralık\n\nKaydırma kısayolları: Sol=Tekrar, Aşağı=Zor, Sağ=İyi, Yukarı=Kolay';

  @override
  String get result => 'Sonuç';

  @override
  String get reviewAnswers => 'Cevapları Gözden Geçir';

  @override
  String get restartExam => 'Sınavı Yeniden Başlat';

  @override
  String get help => 'Yardım';

  @override
  String get confirmRestart =>
      'Sınavı yeniden başlatmak istediğinizden emin misiniz?';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get correct => 'Doğru';

  @override
  String get incorrect => 'Yanlış';

  @override
  String get unanswered => 'Yanıtlanmamış';

  @override
  String get review => 'Gözden Geçir';

  @override
  String totalQuestions(Object total) {
    return 'Toplam Soru: $total';
  }

  @override
  String get answered => 'Yanıtlandı';

  @override
  String unansweredCount(Object count) {
    return 'Yanıtlanmamış: $count';
  }

  @override
  String get resultTitle => 'Sınav Sonuçları';

  @override
  String get pass => 'Tebrikler! Sınavı geçtiniz.';

  @override
  String get fail => 'Sınavı geçemediniz. Bir dahaki sefere daha iyi!';

  @override
  String percentage(Object percentage) {
    return 'Puanınız: $percentage%';
  }

  @override
  String get backToDeck => 'Desteye Dön';

  @override
  String get backToHome => 'Ana Sayfaya Dön';

  @override
  String get yourAnswer => 'Cevabınız';

  @override
  String get correctAnswer => 'Doğru Cevap';

  @override
  String get recommendedDeck => 'Önerilen Deste';

  @override
  String get yourScore => 'Skor';

  @override
  String get settings => 'Ayarlar';

  @override
  String get settingsContent => 'Ayarlar buraya.';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get choosePage => 'Gitmek İstediğiniz Sayfayı Seçin';

  @override
  String get goExam => 'Sınava Git';

  @override
  String get selectLevel => 'Seviyeleri Seç';

  @override
  String get confirmLevels => 'Onayla';

  @override
  String get firstTimeTitle => 'Dilleri Seçin';

  @override
  String get firstTimeContent =>
      'Lütfen anadilinizi ve hedef dilinizi seçiniz.';

  @override
  String get close => 'Kapat';

  @override
  String get weeklyProgress => 'Haftalık İlerleme';

  @override
  String get monthlyProgress => 'Aylık İlerleme';

  @override
  String get chartWeekly => 'Haftalık Grafik';

  @override
  String get chartMonthly => 'Aylık Grafik';

  @override
  String get progression => 'İlerlemeniz';

  @override
  String get progress => 'İlerleme';

  @override
  String get changeLang => 'Dili Değiştir';

  @override
  String get examIconTooltip => 'Sınava Gir';

  @override
  String get combinedDeck => 'Birleşik Deste';

  @override
  String get newDeck => 'Yeni Deste';

  @override
  String get levelsSelected => 'Seçilen Seviyeler';

  @override
  String get proceed => 'İlerle';

  @override
  String get targetLanguage => 'Hedef Dil';

  @override
  String get motherLanguage => 'Anadil';

  @override
  String get firstTimePromptTitle => 'Hoş Geldiniz!';

  @override
  String get firstTimePromptContent =>
      'Lütfen anadilinizi ve hedef dilinizi seçiniz.';

  @override
  String get confirm => 'Onayla';

  @override
  String get saveFailed => 'Ayarlar kaydedilemedi';

  @override
  String get selectLanguages => 'Lütfen dilleri seçiniz.';

  @override
  String get decksPage => 'Desteler Sayfası';

  @override
  String get again => 'Tekrar';

  @override
  String get hard => 'Zor';

  @override
  String get good => 'İyi';

  @override
  String get easy => 'Kolay';

  @override
  String get srsSettings => 'SRS Ayarları';

  @override
  String get dailyLimits => 'Günlük Limitler';

  @override
  String get globalSettings => 'Genel Ayarlar';

  @override
  String get dangerZone => 'Tehlikeli Bölge';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get maxNewPerDay => 'Günlük maks. yeni';

  @override
  String get maxReviewsPerDay => 'Günlük maks. tekrar';

  @override
  String get enableFuzz => 'Rastgelelik ekle';

  @override
  String get fuzzDescription => 'Aralıklara rastgele sapma ekler';

  @override
  String get requestRetention => 'Hedef hatırlama';

  @override
  String get resetAllSrsProgress => 'Tüm SRS İlerlemesini Sıfırla';

  @override
  String get resetSrsDescription =>
      'Tüm kartları Yeni durumuna döndürür. Gözden geçirme geçmişi logda korunur.';

  @override
  String get resetSrsStateTitle => 'SRS Durumu Sıfırlansın mı?';

  @override
  String get resetSrsConfirmation =>
      'Bu işlem tüm kartları Yeni olarak işaretler. Gözden geçirme geçmişiniz korunur. Devam edilsin mi?';

  @override
  String get reset => 'Sıfırla';

  @override
  String get cancel => 'İptal';

  @override
  String get srsStateReset => 'SRS durumu sıfırlandı.';

  @override
  String level(Object level) {
    return 'Seviye $level';
  }

  @override
  String newReviewsPerDay(Object newCount, Object reviewCount) {
    return '$newCount yeni / $reviewCount tekrar/gün';
  }

  @override
  String newCount(Object newCount, Object maxNew) {
    return '$newCount / $maxNew yeni';
  }

  @override
  String reviewCount(Object reviewCount, Object maxReviews) {
    return '$reviewCount / $maxReviews tekrar';
  }
}
