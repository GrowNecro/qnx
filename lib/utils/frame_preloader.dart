// lib/utils/frame_preloader.dart
// Utility untuk preload PNG frames saat app start

import 'package:flutter/material.dart';

/// Global frame preloader untuk PNG transitions
class FramePreloader {
  static final FramePreloader _instance = FramePreloader._internal();
  factory FramePreloader() => _instance;
  FramePreloader._internal();

  bool _introPreloaded = false;
  bool _shortPreloaded = false;
  bool _isPreloading = false;

  bool get isIntroPreloaded => _introPreloaded;
  bool get isShortPreloaded => _shortPreloaded;
  bool get isPreloading => _isPreloading;

  /// Preload intro frames (28 frames)
  Future<void> preloadIntroFrames(BuildContext context) async {
    if (_introPreloaded || _isPreloading) return;
    _isPreloading = true;

    try {
      for (int i = 1; i <= 28; i++) {
        final path = 'assets/frames/intro/intro_${i.toString().padLeft(4, '0')}.png';
        await precacheImage(AssetImage(path), context);
        // Small delay to prevent UI blocking
        if (i % 7 == 0) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
      _introPreloaded = true;
    } catch (e) {
      debugPrint('Error preloading intro frames: $e');
    }

    _isPreloading = false;
  }

  /// Preload short frames (if exists)
  Future<void> preloadShortFrames(BuildContext context, int frameCount) async {
    if (_shortPreloaded || _isPreloading) return;
    _isPreloading = true;

    try {
      for (int i = 1; i <= frameCount; i++) {
        final path = 'assets/frames/short/short_${i.toString().padLeft(4, '0')}.png';
        await precacheImage(AssetImage(path), context);
        if (i % 7 == 0) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
      _shortPreloaded = true;
    } catch (e) {
      debugPrint('Error preloading short frames: $e');
    }

    _isPreloading = false;
  }

  /// Preload all transition frames
  Future<void> preloadAllFrames(BuildContext context) async {
    await preloadIntroFrames(context);
  }

  /// Reset preload status (for testing/debug)
  void reset() {
    _introPreloaded = false;
    _shortPreloaded = false;
    _isPreloading = false;
  }
}

// Global instance
final framePreloader = FramePreloader();
