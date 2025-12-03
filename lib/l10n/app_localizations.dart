import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// App localization class for managing translations
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Questions and X',
      'welcome': 'Welcome',
      'learningMaterials': 'Learning Materials',
      'questions': 'Questions',
      'reviews': 'Reviews',
      'settings': 'Settings',
      'brightness': 'Brightness',
      'volume': 'Volume',
      'language': 'Language',
      'theme': 'Theme',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'exitApp': 'Exit App',
      'exitConfirm': 'Are you sure you want to exit?',
      'cancel': 'Cancel',
      'exit': 'Exit',
      'exercise': 'Exercise',
      'readyToPractice': 'Ready to practice?',
      'loading': 'Loading...',
      'algebra': 'Algebra',
      'comingSoon': 'COMING SOON',
      'back': 'Back',
      'submit': 'Submit',
      'next': 'Next',
      'previous': 'Previous',
      'yourAnswer': 'Your Answer',
      'takePhoto': 'Take Photo',
      'chooseFromGallery': 'Choose from Gallery',
      'progress': 'Progress',
      'completed': 'Completed',
      'notStarted': 'Not Started',
      'inProgress': 'In Progress',
      'reset': 'Reset',
      'save': 'Save',
      'close': 'Close',
      'error': 'Error',
      'retry': 'Retry',
      'noInternet': 'No internet connection',
      'exerciseNotFound': 'Exercise not found in materi.json',
      'materialNotFound': 'Material not found',
      'congratulations': 'Congratulations!',
      'quizCompleted': 'You have completed this quiz!',
      'continueText': 'Continue',
      'home': 'Home',
      'selectLanguage': 'Select Language',
      'english': 'English',
      'indonesian': 'Indonesian',
      'materialsAlgebra': 'Materials - Algebra',
      'quizAlgebra': 'Quiz: Algebra',
      'reviewAlgebra': 'Review: Algebra',
      'exerciseQuestion': 'Exercise Question:',
      'yourAnswerText': 'Your Answer (Text):',
      'yourAnswerImage': 'Your Answer (Image):',
      'systemAnswerText': 'System Answer (Text):',
      'systemAnswerStep': 'System Answer (Step):',
      'noTextAnswerProvided': '(No text answer provided)',
      'exerciseNotAvailable': 'Exercise question not available.',
      'noSystemTextAvailable': 'No system text available.',
      'errorLoadingMaterial': 'Error loading material',
      'emptyAnswer': 'Answer is empty!',
      'allMaterialsCompleted': 'Congratulations, all materials completed!',
      'idNotValid': 'Material ID not valid',
      'exerciseNotYetAvailable': 'Exercise not yet available',
      'removeImage': 'Remove Image',
      'removeImageConfirm': 'Are you sure you want to remove this image?',
      'delete': 'Delete',
      'unsavedChanges': 'Unsaved Changes',
      'unsavedChangesConfirm':
          'You have unsaved changes. Are you sure you want to exit?',
      'stay': 'Stay',
      'exitAnyway': 'Exit Anyway',
      'answerSaved': 'Answer saved!',
      'noAnswerYet': 'No answer yet',
      'writeAnswerHere': 'Write your answer here...',
      'help': 'Help',
      'welcomeToApp': 'Welcome to QNX!',
      'welcomeDescription':
          'QNX (Questions and X) is an interactive math learning app that uses Indonesian folktales as a learning context, making math fun and meaningful.',
      'howToUse': 'How to Use',
      'step1Title': 'Choose Material',
      'step1Desc':
          'Tap "Learning Materials" on the home page, then select the math topic (e.g., Algebra) with folktale context.',
      'step2Title': 'Watch Story Video',
      'step2Desc':
          'Watch the animated folktale video with math concepts. The video will automatically proceed to quiz when finished.',
      'step3Title': 'Answer Math Questions',
      'step3Desc':
          'Answer math questions based on the story with photos (camera/gallery) or type your answer. Answers are saved automatically.',
      'step4Title': 'View Reviews',
      'step4Desc':
          'Compare your answers with the correct solutions in the "Reviews" menu for learning.',
      'features': 'App Features',
      'materialsDesc': 'Math materials with Indonesian folktale context.',
      'questionsDesc': 'Interactive math quizzes based on stories.',
      'reviewsDesc': 'Compare your answers with the correct solutions.',
      'languageDesc': 'Available in Indonesian and English.',
      'autoSave': 'Auto-Save',
      'autoSaveDesc':
          'Answers are saved automatically, no need to worry about losing them.',
      'settingsGuide': 'Settings',
      'brightnessDesc': 'Adjust screen brightness for your comfort.',
      'volumeDesc': 'Adjust audio and video volume.',
      'languageSwitch': 'Change Language',
      'languageSwitchDesc': 'Tap EN or ID to switch language.',
      'tips': 'Tips',
      'tip1':
          '💡 Watch the story video until the end to understand the math concepts.',
      'tip2': '📸 Use camera with good lighting for photo answers.',
      'tip3': '✏️ Write your solution steps clearly.',
      'tip4': '🔄 Check reviews to learn from your mistakes.',
      'tip5': '⚙️ Customize settings for comfortable learning.',
    },
    'id': {
      'appTitle': 'Questions and X',
      'welcome': 'Selamat Datang',
      'learningMaterials': 'Materi Pembelajaran',
      'questions': 'Pertanyaan',
      'reviews': 'Ulasan',
      'settings': 'Pengaturan',
      'brightness': 'Kecerahan',
      'volume': 'Volume',
      'language': 'Bahasa',
      'theme': 'Tema',
      'darkMode': 'Mode Gelap',
      'lightMode': 'Mode Terang',
      'exitApp': 'Keluar Aplikasi',
      'exitConfirm': 'Apakah Anda yakin ingin keluar?',
      'cancel': 'Batal',
      'exit': 'Keluar',
      'exercise': 'Latihan',
      'readyToPractice': 'Siap untuk berlatih?',
      'loading': 'Memuat...',
      'algebra': 'Aljabar',
      'comingSoon': 'SEGERA HADIR',
      'back': 'Kembali',
      'submit': 'Kirim',
      'next': 'Selanjutnya',
      'previous': 'Sebelumnya',
      'yourAnswer': 'Jawaban Anda',
      'takePhoto': 'Ambil Foto',
      'chooseFromGallery': 'Pilih dari Galeri',
      'progress': 'Progres',
      'completed': 'Selesai',
      'notStarted': 'Belum Dimulai',
      'inProgress': 'Sedang Berlangsung',
      'reset': 'Reset',
      'save': 'Simpan',
      'close': 'Tutup',
      'error': 'Error',
      'retry': 'Coba Lagi',
      'noInternet': 'Tidak ada koneksi internet',
      'exerciseNotFound': 'Latihan tidak ditemukan di materi.json',
      'materialNotFound': 'Materi tidak ditemukan',
      'congratulations': 'Selamat!',
      'quizCompleted': 'Anda telah menyelesaikan kuis ini!',
      'continueText': 'Lanjutkan',
      'home': 'Beranda',
      'selectLanguage': 'Pilih Bahasa',
      'english': 'Inggris',
      'indonesian': 'Indonesia',
      'materialsAlgebra': 'Materi - Aljabar',
      'quizAlgebra': 'Kuis: Aljabar',
      'reviewAlgebra': 'Ulasan: Aljabar',
      'exerciseQuestion': 'Soal Latihan:',
      'yourAnswerText': 'Jawaban Anda (Teks):',
      'yourAnswerImage': 'Jawaban Anda (Gambar):',
      'systemAnswerText': 'Jawaban Sistem (Teks):',
      'systemAnswerStep': 'Jawaban Sistem (Langkah):',
      'noTextAnswerProvided': '(Tidak ada jawaban teks)',
      'exerciseNotAvailable': 'Soal latihan tidak tersedia.',
      'noSystemTextAvailable': 'Tidak ada teks sistem tersedia.',
      'errorLoadingMaterial': 'Error memuat materi',
      'emptyAnswer': 'Jawaban kosong!',
      'allMaterialsCompleted': 'Selamat, semua materi sudah selesai!',
      'idNotValid': 'ID materi tidak valid',
      'exerciseNotYetAvailable': 'Latihan belum tersedia',
      'removeImage': 'Hapus Gambar',
      'removeImageConfirm': 'Apakah Anda yakin ingin menghapus gambar ini?',
      'delete': 'Hapus',
      'unsavedChanges': 'Perubahan Belum Disimpan',
      'unsavedChangesConfirm':
          'Anda memiliki perubahan yang belum disimpan. Apakah Anda yakin ingin keluar?',
      'stay': 'Tetap',
      'exitAnyway': 'Keluar Saja',
      'answerSaved': 'Jawaban disimpan!',
      'noAnswerYet': 'Belum ada jawaban',
      'writeAnswerHere': 'Tulis jawaban Anda di sini...',
      'help': 'Bantuan',
      'welcomeToApp': 'Selamat Datang di QNX!',
      'welcomeDescription':
          'QNX (Questions and X) adalah aplikasi pembelajaran matematika interaktif yang menggunakan cerita rakyat Indonesia sebagai konteks pembelajaran, membuat matematika jadi menyenangkan dan bermakna.',
      'howToUse': 'Cara Menggunakan',
      'step1Title': 'Pilih Materi',
      'step1Desc':
          'Tekan tombol "Materi Pembelajaran" di halaman utama, lalu pilih topik matematika (mis. Aljabar) dengan konteks cerita rakyat.',
      'step2Title': 'Tonton Video Cerita',
      'step2Desc':
          'Tonton video animasi cerita rakyat dengan konsep matematika. Video akan otomatis lanjut ke quiz setelah selesai.',
      'step3Title': 'Jawab Soal Matematika',
      'step3Desc':
          'Jawab soal matematika berdasarkan cerita dengan foto (kamera/galeri) atau ketik jawabanmu. Jawaban akan tersimpan otomatis.',
      'step4Title': 'Lihat Ulasan',
      'step4Desc':
          'Bandingkan jawabanmu dengan solusi yang benar di menu "Ulasan" untuk pembelajaran.',
      'features': 'Fitur Aplikasi',
      'materialsDesc':
          'Materi matematika dengan konteks cerita rakyat Indonesia.',
      'questionsDesc': 'Quiz matematika interaktif berbasis cerita.',
      'reviewsDesc': 'Bandingkan jawabanmu dengan solusi yang benar.',
      'languageDesc': 'Tersedia dalam Bahasa Indonesia dan English.',
      'autoSave': 'Auto-Save',
      'autoSaveDesc': 'Jawaban tersimpan otomatis, tidak perlu takut hilang.',
      'settingsGuide': 'Pengaturan',
      'brightnessDesc': 'Atur kecerahan layar sesuai kenyamananmu.',
      'volumeDesc': 'Atur volume audio dan video.',
      'languageSwitch': 'Ganti Bahasa',
      'languageSwitchDesc': 'Tekan EN atau ID untuk mengganti bahasa.',
      'tips': 'Tips',
      'tip1':
          '💡 Tonton video cerita sampai selesai untuk memahami konsep matematikanya.',
      'tip2':
          '📸 Gunakan kamera dengan pencahayaan yang baik untuk foto jawaban.',
      'tip3': '✏️ Tulis langkah-langkah penyelesaian dengan rapi.',
      'tip4': '🔄 Cek ulasan untuk belajar dari kesalahanmu.',
      'tip5': '⚙️ Sesuaikan pengaturan untuk kenyamanan belajar.',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get welcome => _localizedValues[locale.languageCode]!['welcome']!;
  String get learningMaterials => _localizedValues[locale.languageCode]!['learningMaterials']!;
  String get questions => _localizedValues[locale.languageCode]!['questions']!;
  String get reviews => _localizedValues[locale.languageCode]!['reviews']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get brightness => _localizedValues[locale.languageCode]!['brightness']!;
  String get volume => _localizedValues[locale.languageCode]!['volume']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get lightMode => _localizedValues[locale.languageCode]!['lightMode']!;
  String get exitApp => _localizedValues[locale.languageCode]!['exitApp']!;
  String get exitConfirm => _localizedValues[locale.languageCode]!['exitConfirm']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get exit => _localizedValues[locale.languageCode]!['exit']!;
  String get exercise => _localizedValues[locale.languageCode]!['exercise']!;
  String get readyToPractice => _localizedValues[locale.languageCode]!['readyToPractice']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get algebra => _localizedValues[locale.languageCode]!['algebra']!;
  String get comingSoon => _localizedValues[locale.languageCode]!['comingSoon']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get submit => _localizedValues[locale.languageCode]!['submit']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get previous => _localizedValues[locale.languageCode]!['previous']!;
  String get yourAnswer => _localizedValues[locale.languageCode]!['yourAnswer']!;
  String get takePhoto => _localizedValues[locale.languageCode]!['takePhoto']!;
  String get chooseFromGallery => _localizedValues[locale.languageCode]!['chooseFromGallery']!;
  String get progress => _localizedValues[locale.languageCode]!['progress']!;
  String get completed => _localizedValues[locale.languageCode]!['completed']!;
  String get notStarted => _localizedValues[locale.languageCode]!['notStarted']!;
  String get inProgress => _localizedValues[locale.languageCode]!['inProgress']!;
  String get reset => _localizedValues[locale.languageCode]!['reset']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get noInternet => _localizedValues[locale.languageCode]!['noInternet']!;
  String get exerciseNotFound => _localizedValues[locale.languageCode]!['exerciseNotFound']!;
  String get materialNotFound => _localizedValues[locale.languageCode]!['materialNotFound']!;
  String get congratulations => _localizedValues[locale.languageCode]!['congratulations']!;
  String get quizCompleted => _localizedValues[locale.languageCode]!['quizCompleted']!;
  String get continueText => _localizedValues[locale.languageCode]!['continueText']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get selectLanguage => _localizedValues[locale.languageCode]!['selectLanguage']!;
  String get english => _localizedValues[locale.languageCode]!['english']!;
  String get indonesian => _localizedValues[locale.languageCode]!['indonesian']!;
  String get materialsAlgebra =>
      _localizedValues[locale.languageCode]!['materialsAlgebra']!;
  String get quizAlgebra =>
      _localizedValues[locale.languageCode]!['quizAlgebra']!;
  String get reviewAlgebra =>
      _localizedValues[locale.languageCode]!['reviewAlgebra']!;
  String get exerciseQuestion =>
      _localizedValues[locale.languageCode]!['exerciseQuestion']!;
  String get yourAnswerText =>
      _localizedValues[locale.languageCode]!['yourAnswerText']!;
  String get yourAnswerImage =>
      _localizedValues[locale.languageCode]!['yourAnswerImage']!;
  String get systemAnswerText =>
      _localizedValues[locale.languageCode]!['systemAnswerText']!;
  String get systemAnswerStep =>
      _localizedValues[locale.languageCode]!['systemAnswerStep']!;
  String get noTextAnswerProvided =>
      _localizedValues[locale.languageCode]!['noTextAnswerProvided']!;
  String get exerciseNotAvailable =>
      _localizedValues[locale.languageCode]!['exerciseNotAvailable']!;
  String get noSystemTextAvailable =>
      _localizedValues[locale.languageCode]!['noSystemTextAvailable']!;
  String get emptyAnswer =>
      _localizedValues[locale.languageCode]!['emptyAnswer']!;
  String get allMaterialsCompleted =>
      _localizedValues[locale.languageCode]!['allMaterialsCompleted']!;
  String get idNotValid =>
      _localizedValues[locale.languageCode]!['idNotValid']!;
  String get exerciseNotYetAvailable =>
      _localizedValues[locale.languageCode]!['exerciseNotYetAvailable']!;
  String get removeImage =>
      _localizedValues[locale.languageCode]!['removeImage']!;
  String get removeImageConfirm =>
      _localizedValues[locale.languageCode]!['removeImageConfirm']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get unsavedChanges =>
      _localizedValues[locale.languageCode]!['unsavedChanges']!;
  String get unsavedChangesConfirm =>
      _localizedValues[locale.languageCode]!['unsavedChangesConfirm']!;
  String get stay => _localizedValues[locale.languageCode]!['stay']!;
  String get exitAnyway =>
      _localizedValues[locale.languageCode]!['exitAnyway']!;
  String get answerSaved =>
      _localizedValues[locale.languageCode]!['answerSaved']!;
  String get noAnswerYet =>
      _localizedValues[locale.languageCode]!['noAnswerYet']!;
  String get writeAnswerHere =>
      _localizedValues[locale.languageCode]!['writeAnswerHere']!;
  String get help => _localizedValues[locale.languageCode]!['help']!;
  String get welcomeToApp =>
      _localizedValues[locale.languageCode]!['welcomeToApp']!;
  String get welcomeDescription =>
      _localizedValues[locale.languageCode]!['welcomeDescription']!;
  String get howToUse => _localizedValues[locale.languageCode]!['howToUse']!;
  String get step1Title =>
      _localizedValues[locale.languageCode]!['step1Title']!;
  String get step1Desc => _localizedValues[locale.languageCode]!['step1Desc']!;
  String get step2Title =>
      _localizedValues[locale.languageCode]!['step2Title']!;
  String get step2Desc => _localizedValues[locale.languageCode]!['step2Desc']!;
  String get step3Title =>
      _localizedValues[locale.languageCode]!['step3Title']!;
  String get step3Desc => _localizedValues[locale.languageCode]!['step3Desc']!;
  String get step4Title =>
      _localizedValues[locale.languageCode]!['step4Title']!;
  String get step4Desc => _localizedValues[locale.languageCode]!['step4Desc']!;
  String get features => _localizedValues[locale.languageCode]!['features']!;
  String get materialsDesc =>
      _localizedValues[locale.languageCode]!['materialsDesc']!;
  String get questionsDesc =>
      _localizedValues[locale.languageCode]!['questionsDesc']!;
  String get reviewsDesc =>
      _localizedValues[locale.languageCode]!['reviewsDesc']!;
  String get languageDesc =>
      _localizedValues[locale.languageCode]!['languageDesc']!;
  String get autoSave => _localizedValues[locale.languageCode]!['autoSave']!;
  String get autoSaveDesc =>
      _localizedValues[locale.languageCode]!['autoSaveDesc']!;
  String get settingsGuide =>
      _localizedValues[locale.languageCode]!['settingsGuide']!;
  String get brightnessDesc =>
      _localizedValues[locale.languageCode]!['brightnessDesc']!;
  String get volumeDesc =>
      _localizedValues[locale.languageCode]!['volumeDesc']!;
  String get languageSwitch =>
      _localizedValues[locale.languageCode]!['languageSwitch']!;
  String get languageSwitchDesc =>
      _localizedValues[locale.languageCode]!['languageSwitchDesc']!;
  String get tips => _localizedValues[locale.languageCode]!['tips']!;
  String get tip1 => _localizedValues[locale.languageCode]!['tip1']!;
  String get tip2 => _localizedValues[locale.languageCode]!['tip2']!;
  String get tip3 => _localizedValues[locale.languageCode]!['tip3']!;
  String get tip4 => _localizedValues[locale.languageCode]!['tip4']!;
  String get tip5 => _localizedValues[locale.languageCode]!['tip5']!;

  /// Helper to get current locale name
  String get currentLanguageName {
    return locale.languageCode == 'id' ? 'Indonesia' : 'English';
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'id'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    Intl.defaultLocale = locale.languageCode;
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Supported locales
const supportedLocales = [
  Locale('en', 'US'),
  Locale('id', 'ID'),
];
