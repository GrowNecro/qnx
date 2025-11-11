import 'package:flutter/material.dart';
import 'package:qnx/pages/aljabar_page.dart';
import '../pages/home_page.dart';
// import '../pages/splash_screen.dart';
import '../pages/materi_page.dart';
import '../pages/quiz_page.dart';
import '../pages/aljabar_quiz.dart';
import '../pages/aljabar_quiz_page.dart';
import '../pages/jawaban_page.dart';
import '../pages/ulasan_page.dart';
import '../pages/aljabar_ulasan.dart';
import '../pages/aljabar_ulasan_page.dart';
import '../pages/video_page.dart';
// import '../pages/video_transisi_png.dart';
// import '../utils/preload_all.dart.dart';

// Import route baru untuk stage-continued transition
import '../pages/png_transisi_stage_route.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget? page;
    String? defaultTransisi;

    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      // case '/':
      //   // create a MaterialPageRoute so we can pass the BuildContext into preload
      //   return MaterialPageRoute(
      //     builder: (ctx) => SplashScreen(
      //       onPreload: () async {
      //         // call the preload util with the context used to build the splash,
      //         // so MediaQuery.of(ctx) inside preloadAllScreenshots works
      //         await preloadAllScreenshots(ctx);
      //       },
      //       nextRouteName: '/home',
      //       backgroundMode: SplashBackgroundMode.image,
      //       backgroundImage: 'assets/images/splash_bg.png',
      //     ),
      //   );
      // case '/home':
      //   page = const HomePage();
      //   // defaultTransisi = null;
      //   defaultTransisi = 'transisi2';
      //   break;
      case '/':
        page = const HomePage();
        defaultTransisi = 'transisi2';
        break;
      case '/materi':
        page = const MateriPage();
        defaultTransisi = 'transisi2';
        break;
      case '/quiz':
        page = const QuizPage();
        defaultTransisi = 'transisi2';
        break;
      case '/ulasan':
        page = const UlasanPage();
        defaultTransisi = 'transisi2';
        break;
      case '/materi/aljabar':
        page = const AljabarPage();
        defaultTransisi = 'transisi2';
        break;
      case '/quiz/aljabar':
        page = const AljabarQuiz();
        defaultTransisi = 'transisi2';
        break;
      case '/ulasan/aljabar':
        page = const AljabarUlasan();
        defaultTransisi = 'transisi2';
        break;
      case '/quiz/page':
        page = AljabarQuizPage(
          judullatihan: args?['judullatihan'] ?? 'Judul tidak tersedia',
          latihan: args?['latihan'] ?? 'Latihan tidak tersedia',
        );
        defaultTransisi = 'transisi2';
        break;
      case '/quiz/jawaban':
        page = JawabanPage(
          judullatihan: args?['judullatihan'] ?? 'Judul tidak tersedia',
        );
        defaultTransisi = 'transisi2';
        break;
      case '/ulasan/page':
        final String userImagePath =
            args?['jawabanuserpng'] ?? 'assets/images/default.png';
        page = AljabarUlasanPage(
          judullatihan: args?['judullatihan'] ?? 'Judul tidak tersedia',
          latihan: args?['latihan'] ?? 'soal tidak tersedia',
          jawabansistempng:
              args?['jawabansistempng'] ?? 'assets/images/default.png',
          jawabansistemteks:
              args?['jawabansistemteks'] ?? 'Belum ada jawaban sistem',
          jawabanuserpng: userImagePath,
          jawabanuser: args?['jawabanuser'] ?? 'Belum ada jawaban pengguna',
        );
        defaultTransisi = 'transisi2';
        break;
      case '/materi/video':
        page = VideoPage(
          videoPath: args?['videoPath'] ?? '',
          judullatihan: args?['judullatihan'] ?? '',
        );
        defaultTransisi = 'transisi2';
        break;
      default:
        page = const HomePage();
        defaultTransisi = null;
        break;
    }

    // Overrides
    final bool forceNoTransisi = args?['forceNoTransisi'] == true;
    final String? explicitTransisi = (args?['transisi'] is String)
        ? args!['transisi'] as String
        : null;
    // allow caller to override which pngPattern/framecount to use
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
    // optional timing overrides (ms)
    final int initialBlackMs = (args?['initialBlackMs'] is int)
        ? args!['initialBlackMs'] as int
        : 200;
    final int endFrameDelayMs = (args?['endFrameDelayMs'] is int)
        ? args!['endFrameDelayMs'] as int
        : 140;

    String? selectedTransisi;
    if (forceNoTransisi) {
      selectedTransisi = null;
    } else if (explicitTransisi != null) {
      selectedTransisi = explicitTransisi == 'none' ? null : explicitTransisi;
    } else {
      selectedTransisi = defaultTransisi;
    }

    // Choose defaults (we'll prefer png sequences for these transitions)
    String? chosenPngPattern;
    int chosenPngFrameCount = 0;

    if (customPngPattern != null && customPngPattern.isNotEmpty) {
      chosenPngPattern = customPngPattern;
      chosenPngFrameCount = customPngFrameCount ?? 0;
    } else if (selectedTransisi == 'transisi1') {
      chosenPngPattern = 'assets/frames/intro/intro_%04d.png';
      chosenPngFrameCount = 167;
    } else if (selectedTransisi == 'transisi2') {
      chosenPngPattern = 'assets/frames/short/short_%04d.png';
      chosenPngFrameCount = 64;
    }

    // If a transisi is selected, route via stage-continued transition route (NEW)
    if (selectedTransisi == 'transisi1' || selectedTransisi == 'transisi2') {
      // --- OLD (kept as comment for reference): Using PngTransisiPage via PageRouteBuilder
      /*
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PngTransisiPage(
          // gunakan builder agar halaman target dibuat hanya saat diperlukan
          nextPageBuilder: (_) => page!,
          pngPattern: chosenPngPattern ?? 'assets/frames/short/short_%04d.png',
          pngFrameCount: chosenPngFrameCount > 0 ? chosenPngFrameCount : 120,
          fps: args?['fps'] is int ? args!['fps'] as int : 24,
          loop: args?['loop'] == true,
          bufferSize: customBufferSize ?? 8,
          targetDisplayWidth: customTargetW,
          targetDisplayHeight: customTargetH,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        transitionsBuilder: (context, anim, secAnim, child) => child,
      );
      */

      // --- NEW: gunakan PngTransisiStageRoute (stage-continued, preserve instance)
      return PngTransisiStageRoute(
        pageUnder:
            page!, // gunakan instance page yang sudah dibuat di switch-case
        backgroundBytes:
            null, // tetap hitam di awal; ubah kalau mau screenshot image
        pngPattern: chosenPngPattern ?? 'assets/frames/short/short_%04d.png',
        pngFrameCount: chosenPngFrameCount > 0 ? chosenPngFrameCount : 120,
        fps: args?['fps'] is int ? args!['fps'] as int : 24,
        loop: args?['loop'] == true,
        bufferSize: customBufferSize ?? 8,
        targetDisplayWidth: customTargetW,
        targetDisplayHeight: customTargetH,
        // initialBlackDuration: Duration(milliseconds: initialBlackMs),
        endFrameDelay: Duration(milliseconds: endFrameDelayMs),
      );
    }

    // normal route
    return MaterialPageRoute(builder: (_) => page!);
  }
}
