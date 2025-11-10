// lib/utils/preload_all.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../utils/screenshot.dart';
import '../utils/memory_cache.dart';
import '../utils/screenshot_disk.dart'; // <-- added

// Pages used for previews (adjust paths if needed)
import '../pages/home_page.dart';
import '../pages/materi_page.dart';
import '../pages/aljabar_page.dart';
import '../pages/quiz_page.dart';
import '../pages/ulasan_page.dart';
import '../pages/video_page.dart';

// Page variants that expose previewWithMediaQuery(...)
import '../pages/aljabar_quiz_page.dart';
import '../pages/aljabar_ulasan_page.dart';

/// Capture widgets offstage and save into MemoryScreenshotCache and disk.
Future<void> preloadAllScreenshots(BuildContext context) async {
  debugPrint('PreloadAllScreenshots: START');
  final cache = MemoryScreenshotCache();

  // Capture MediaQueryData once (do not use BuildContext after awaits).
  final mq = MediaQuery.of(context);

  // base targets (use mq-based preview builders where necessary)
  final Map<String, Widget Function()> baseTargets = {
    'home': () => const HomePage(),
    'materi': () => const MateriPage(),
    'materi_aljabar': () => const AljabarPage(),
    'quiz': () => const QuizPage(),
    'ulasan': () => const UlasanPage(),
    // use previewWithMediaQuery (note: pass mq, not context)
    'quiz_aljabar': () =>
        AljabarQuizPage.previewWithMediaQuery(mq, 'Aljabar', 'Contoh soal'),
    'ulasan_aljabar': () => AljabarUlasanPage.previewWithMediaQuery(
      mq,
      judul: 'Aljabar',
      latihan: 'Contoh latihan',
      jawabansistempng: 'assets/images/default.png',
      jawabansistemteks: 'Contoh teks sistem',
      jawabanuser: 'Belum ada jawaban',
      jawabanuserpng: 'assets/images/default.png',
    ),
  };

  // Tunable params
  const double pixelRatio = 1.0;
  const Duration waitAfterFrame = Duration(milliseconds: 120);
  const Duration interCaptureDelay = Duration(milliseconds: 200);
  const int maxRetries = 1;

  Future<void> captureAndCache(String key, Widget widgetToCapture) async {
    if (cache.get(key) != null) {
      debugPrint('Preload: cache already exists for $key — skipping.');
      return;
    }

    bool success = false;
    for (int attempt = 0; attempt <= maxRetries && !success; attempt++) {
      try {
        debugPrint('Preload: capturing $key (attempt ${attempt + 1})');
        final Uint8List bytes = await captureWidgetAsPng(
          context,
          // wrap with saved MediaQueryData + Material to render correctly offstage
          MediaQuery(
            data: mq,
            child: Material(
              type: MaterialType.transparency,
              child: widgetToCapture,
            ),
          ),
          pixelRatio: pixelRatio,
          wait: waitAfterFrame,
        );

        if (bytes.isNotEmpty) {
          cache.save(key, bytes);
          // save to disk for persistence
          try {
            await saveScreenshotToDisk(key, bytes);
            debugPrint(
              'Preload: saved $key to disk and memory (${bytes.lengthInBytes} bytes)',
            );
          } catch (e) {
            debugPrint('Preload warning: failed to save $key to disk: $e');
          }
          success = true;
        } else {
          debugPrint('Preload warning: empty bytes for $key');
        }
      } catch (e) {
        debugPrint('Preload error for $key: $e');
        await Future.delayed(const Duration(milliseconds: 180));
      }
    }

    await Future.delayed(interCaptureDelay);
  }

  // 1) Preload base targets
  for (final entry in baseTargets.entries) {
    final key = entry.key;
    Widget widgetToCapture;
    try {
      widgetToCapture = entry.value();
    } catch (e) {
      debugPrint('Preload: failed to build widget for $key: $e');
      continue;
    }
    await captureAndCache(key, widgetToCapture);
  }

  // 2) Preload per-item targets from assets/materi.json
  try {
    final String jsonString = await rootBundle.loadString('assets/materi.json');
    final List<dynamic> materiList = json.decode(jsonString) as List<dynamic>;

    for (final item in materiList) {
      if (item == null) continue;
      final Map<String, dynamic> mat = item as Map<String, dynamic>;

      final String? judulRaw = mat['judullatihan'] is String
          ? mat['judullatihan'] as String
          : null;
      if (judulRaw == null || judulRaw.trim().isEmpty) continue;
      final String keySafe = judulRaw
          .replaceAll(RegExp(r'\s+'), '_')
          .toLowerCase();

      // a) Video preview
      try {
        final videoWidget = VideoPage(
          videoPath: mat['video'] ?? '',
          judullatihan: judulRaw,
        );
        await captureAndCache('video_$keySafe', videoWidget);
      } catch (e) {
        debugPrint('Preload video for $judulRaw failed: $e');
      }

      // b) Quiz preview via previewWithMediaQuery(mq,...)
      try {
        final quizPreviewWidget = AljabarQuizPage.previewWithMediaQuery(
          mq,
          judulRaw,
          mat['latihan'] ?? '',
        );
        await captureAndCache('quiz_$keySafe', quizPreviewWidget);
      } catch (e) {
        debugPrint('Preload quiz for $judulRaw failed: $e');
      }

      // c) Ulasan preview via previewWithMediaQuery(mq,...)
      try {
        final ulasanPreviewWidget = AljabarUlasanPage.previewWithMediaQuery(
          mq,
          judul: judulRaw,
          latihan: mat['latihan'] ?? '',
          jawabansistempng:
              mat['jawabansistempng'] ?? 'assets/images/default.png',
          jawabansistemteks: mat['jawabansistemteks'] ?? '',
          jawabanuser: 'Belum ada jawaban',
          jawabanuserpng: 'assets/images/default.png',
        );
        await captureAndCache('ulasan_$keySafe', ulasanPreviewWidget);
      } catch (e) {
        debugPrint('Preload ulasan for $judulRaw failed: $e');
      }
    }
  } catch (e) {
    debugPrint('PreloadAllScreenshots: failed to load/parse materi.json: $e');
  }

  debugPrint('PreloadAllScreenshots: finished.');
}
