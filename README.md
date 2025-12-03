# QNX - Questions and X

<p align="center">
  <img src="assets/images/sugeng_rawuh.png" alt="QNX Logo" width="300"/>
</p>

<p align="center">
  <strong>Aplikasi Pembelajaran Matematika Berbasis Cerita Rakyat</strong><br>
  Belajar Matematika Melalui Cerita Rakyat Indonesia dengan Video, Quiz, dan Review
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" alt="Android"/>
  <img src="https://img.shields.io/badge/Language-EN%20%7C%20ID-orange" alt="Bilingual"/>
  <img src="https://img.shields.io/badge/Tests-214%20Passed-brightgreen" alt="Tests"/>
</p>

---

## 📖 Deskripsi

**QNX (Questions and X)** adalah aplikasi pembelajaran matematika berbasis Flutter yang menggunakan cerita rakyat Indonesia sebagai konteks pembelajaran. Aplikasi ini menggabungkan video animasi cerita rakyat dengan berbagai materi matematika (seperti Aljabar), quiz interaktif, dan sistem review untuk pengalaman belajar yang menyenangkan dan bermakna.

---

## ✨ Fitur Utama

### 📚 Materi Matematika dengan Cerita Rakyat
- Video animasi cerita rakyat Indonesia sebagai konteks pembelajaran
- Berbagai materi matematika (Aljabar, dll) yang terintegrasi dengan cerita
- Transisi animasi PNG yang smooth antar halaman
- Progress tracking otomatis

### 📝 Interactive Quiz
- Pertanyaan matematika berbasis cerita yang ditonton
- Input jawaban via kamera atau galeri
- Input jawaban teks
- Auto-save draft setiap 3 detik

### 📊 Review System
- Bandingkan jawaban user dengan jawaban yang benar
- Penjelasan detail tentang solusi matematika
- Dukungan bilingual (Indonesia & English)

### ⚙️ Settings
- Kontrol brightness layar
- Kontrol volume audio/video
- Toggle bahasa EN ↔ ID
- Progress indicator

### 🎨 UI/UX
- Fullscreen immersive mode
- Video background di home page
- Modern iOS-style icons
- Haptic feedback
- Smooth PNG transition animations

---

## 📱 Screenshots

| Home | Video | Quiz | Review |
|:----:|:-----:|:----:|:------:|
| Video BG | Player | Camera/Text | Compare |
| Settings | Controls | Auto-save | Bilingual |

---

## 🏗️ Struktur Project

```
lib/
├── main.dart                 # Entry point & global instances
├── l10n/                     # Localization (EN/ID)
│   ├── app_en.arb
│   ├── app_id.arb
│   └── app_localizations.dart
├── pages/                    # UI Pages
│   ├── home_page.dart
│   ├── materi_page.dart
│   ├── aljabar_page.dart
│   ├── video_page.dart
│   ├── quiz_page.dart
│   ├── aljabar_quiz_page.dart
│   ├── ulasan_page.dart
│   ├── aljabar_ulasan_page.dart
│   └── png_transisi_stage_route.dart
├── routes/                   # Navigation
│   └── app_routes.dart
├── utils/                    # Utilities
│   ├── app_utils.dart
│   ├── frame_preloader.dart
│   ├── language_manager.dart
│   ├── materi_localizer.dart
│   ├── progress_tracker.dart
│   └── theme_manager.dart
└── widgets/                  # Reusable Widgets
    ├── alpha_video_player.dart
    └── menu_button.dart

assets/
├── materi.json              # Database materi
├── frames/                  # PNG transition frames
│   └── intro/
├── images/                  # Static images
├── videos/                  # Video assets
└── icon/                    # App icons

test/
├── widget_test.dart         # Main test runner
├── utils/                   # Unit tests
│   ├── progress_tracker_test.dart
│   ├── language_manager_test.dart
│   ├── materi_localizer_test.dart
│   ├── app_utils_test.dart
│   ├── frame_preloader_test.dart
│   └── theme_manager_test.dart
└── routes/
    └── app_routes_test.dart
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code
- Android device atau emulator

### Installation

1. **Clone repository**
   ```bash
   git clone https://github.com/GrowNecro/qnx.git
   cd qnx
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localizations**
   ```bash
   flutter gen-l10n
   ```

4. **Run app**
   ```bash
   flutter run
   ```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter_localizations:
  shared_preferences:      # Local storage
  video_player:            # Video playback
  youtube_player_flutter:  # YouTube support
  image_picker:            # Camera & gallery

dev_dependencies:
  flutter_test:
  flutter_lints:
```

---

## 🌐 Localization

Aplikasi mendukung 2 bahasa:

| Language | Code | Status |
|----------|------|--------|
| English | `en` | ✅ Complete |
| Indonesian | `id` | ✅ Complete |

Untuk menambah bahasa baru, buat file `lib/l10n/app_XX.arb`.

---

## 🧪 Testing

| Test File | Coverage |
|-----------|----------|
| progress_tracker_test.dart | ✅ |
| language_manager_test.dart | ✅ |
| materi_localizer_test.dart | ✅ |
| app_utils_test.dart | ✅ |
| frame_preloader_test.dart | ✅ |
| theme_manager_test.dart | ✅ |
| app_routes_test.dart | ✅ |

**Total: 214 tests passed** ✅

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 👨‍💻 Developer

Developed with ❤️ using Flutter

---

## 📞 Support

Untuk pertanyaan atau dukungan, hubungi developer.
