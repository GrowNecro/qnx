import 'package:flutter/material.dart';
import '../pages/png_transisi_stage_route.dart';

/// Mainkan tirai (transisi2) di atas halaman SEKARANG,
/// setelah selesai, ganti ke [routeName] tanpa transisi lain.
Future<void> playCurtainOutroAndNavigate(
  BuildContext context, {
  required String routeName,
  Map<String, dynamic>? arguments,
}) async {
  // 1. Push overlay tirai di atas current page
  await Navigator.of(context).push(
    PngTransisiStageRoute(
      // Karena ini OUTRO di current page:
      // pageUnder tidak dipakai, biarkan kosong.
      pageUnder: const SizedBox.shrink(),

      pngPattern: 'assets/frames/intro/intro_%04d.png',
      pngFrameCount: 28,
      fps: 24,
      loop: false,

      // jalankan mundur: tirai menutup
      reverseFrames: true,

      // jangan pernah mulai pageUnder
      stageStartFrames: 9999,

      // overlay-only: setelah animasi selesai, route ini POP sendiri
      autoPopOnFinish: true,
    ),
  );

  // 2. Setelah overlay pop (tirai selesai), baru ganti page tanpa transisi
  Navigator.of(context).pushReplacementNamed(
    routeName,
    arguments: {
      ...?arguments,
      'forceNoTransisi': true, // pastikan AppRoutes tidak kasih intro lagi
    },
  );
}
