import 'package:flutter/material.dart';
import 'package:qnx/pages/aljabar_page.dart';
import '../pages/home_page.dart';
import '../pages/materi_page.dart';
import '../pages/quiz_page.dart';
import '../pages/aljabar_quiz.dart';
import '../pages/ulasan_page.dart';
import '../pages/aljabar_ulasan.dart';

// Import hanya AljabarQuizPage dari file ini
import '../pages/aljabar_quiz_page.dart' show AljabarQuizPage;

// Import VideoPage pakai alias supaya nggak tabrakan nama
import '../pages/video_page.dart' as video_page;

import '../pages/png_transisi_stage_route.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget? page;
    String? defaultTransisi;

    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case '/':
        page = const HomePage();
        // default: intro transisi pas buka app pertama
        defaultTransisi = 'transisi1';
        break;
      case '/materi':
        page = const MateriPage();
        defaultTransisi = null;
        break;
      case '/quiz':
        page = const QuizPage();
        defaultTransisi = null;
        break;
      case '/ulasan':
        page = const UlasanPage();
        defaultTransisi = null;
        break;
      case '/materi/aljabar':
        page = const AljabarPage();
        defaultTransisi = null;
        break;
      case '/quiz/aljabar':
        page = const AljabarQuiz();
        defaultTransisi = null;
        break;
      case '/ulasan/aljabar':
        page = const AljabarUlasan();
        defaultTransisi = null;
        break;

      // HALAMAN QUIZ PER SOAL
      case '/quiz/page':
        page = AljabarQuizPage(
          judullatihan: args?['judullatihan'] ?? 'Judul tidak tersedia',
          latihan: args?['latihan'] ?? 'Latihan tidak tersedia',
        );
        defaultTransisi = null;
        break;

      // HALAMAN VIDEO MATERI
      case '/materi/video':
        page = video_page.VideoPage(
          videoPath: args?['videoPath'] ?? '',
          judulMateri: args?['judulMateri'] ?? '',
          judullatihan: args?['judullatihan'] ?? '',
        );
        // boleh pakai intro kalau mau
        defaultTransisi = 'transisi1';
        break;

      default:
        page = const HomePage();
        defaultTransisi = null;
        break;
    }

    // ==== OVERRIDES DARI ARGS ====

    final bool forceNoTransisi = args?['forceNoTransisi'] == true;

    final String? explicitTransisi = (args?['transisi'] is String)
        ? args!['transisi'] as String
        : null;

    final String? customPngPattern = (args?['pngPattern'] is String)
        ? args!['pngPattern'] as String
        : null;

    final int? customPngFrameCount = (args?['pngFrameCount'] is int)
        ? args!['pngFrameCount'] as int
        : null;

    final int? customBufferSize = (args?['bufferSize'] is int)
        ? args!['bufferSize'] as int
        : null;

    final int? customTargetW = (args?['targetDisplayWidth'] is int)
        ? args!['targetDisplayWidth'] as int
        : null;

    final int? customTargetH = (args?['targetDisplayHeight'] is int)
        ? args!['targetDisplayHeight'] as int
        : null;

    final int endFrameDelayMs = (args?['endFrameDelayMs'] is int)
        ? args!['endFrameDelayMs'] as int
        : 140;

    // ==== PILIH TRANSISI YANG DIPAKAI ====

    String? selectedTransisi;
    if (forceNoTransisi) {
      selectedTransisi = null;
    } else if (explicitTransisi != null) {
      selectedTransisi = explicitTransisi == 'none' ? null : explicitTransisi;
    } else {
      selectedTransisi = defaultTransisi;
    }

    // ==== PILIH PNG PATTERN & FRAME COUNT ====

    String? chosenPngPattern;
    int chosenPngFrameCount = 0;

    if (customPngPattern != null && customPngPattern.isNotEmpty) {
      // caller override penuh
      chosenPngPattern = customPngPattern;
      chosenPngFrameCount = customPngFrameCount ?? 0;
    } else if (selectedTransisi == 'transisi1') {
      // hanya transisi1 (intro) yang ditangani di router
      chosenPngPattern = 'assets/frames/intro/intro_%04d.png';
      chosenPngFrameCount = 28;
    }

    // transisi1 → normal (0..27)
    const bool reverseFrames = false;

    // ==== KALAU ADA TRANSISI, PAKAI PngTransisiStageRoute ====

    if (selectedTransisi == 'transisi1') {
      return PngTransisiStageRoute(
        pageUnder: page, // halaman tujuan
        backgroundBytes: null,
        pngPattern: chosenPngPattern ?? 'assets/frames/intro/intro_%04d.png',
        pngFrameCount: chosenPngFrameCount,
        fps: args?['fps'] is int ? args!['fps'] as int : 24,
        loop: args?['loop'] == true,
        bufferSize: customBufferSize ?? 8,
        targetDisplayWidth: customTargetW,
        targetDisplayHeight: customTargetH,
        endFrameDelay: Duration(milliseconds: endFrameDelayMs),
        reverseFrames: reverseFrames,
        autoPopOnFinish: false,
      );
    }

    // ==== ROUTE BIASA TANPA TRANSISI ====
    return MaterialPageRoute(builder: (_) => page!);
  }
}
