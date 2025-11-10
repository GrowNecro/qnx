// lib/pages/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum SplashBackgroundMode { black, image }

/// Simplified SplashScreen (no preload, no fades, no visible buffer)
///
/// - When video not ready or buffering, show either a black screen or an image (configurable).
/// - When video ready and not buffering, show the video (cover).
/// - Skip button immediately navigates.
/// - No spinner / loading indicator visible (per request).
class SplashScreen extends StatefulWidget {
  /// kept for compatibility; not used in simplified flow
  final Future<void> Function()? onPreload;

  /// where to navigate after splash
  final String nextRouteName;

  /// how long to wait for initial video init before showing background (safety only)
  final Duration initTimeout;

  /// background mode while video not ready: black or image
  final SplashBackgroundMode backgroundMode;

  /// asset path used when backgroundMode == SplashBackgroundMode.image
  final String? backgroundImage;

  const SplashScreen({
    super.key,
    this.onPreload,
    this.nextRouteName = '/home',
    this.initTimeout = const Duration(seconds: 6),
    this.backgroundMode = SplashBackgroundMode.black,
    this.backgroundImage,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _navigated = false;
  Timer? _initTimer;
  bool _hasInitError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();

    // safety timer: informative only — we don't auto-navigate here
    _initTimer = Timer(widget.initTimeout, () {
      if (!_initialized && mounted) {
        debugPrint('Splash init timed out; video not available.');
        setState(() {
          _hasInitError = true;
        });
      }
    });
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/videos/intro.mp4');

      // initialize; if it throws we show background instead
      await _controller.initialize();
      _controller.setVolume(0.0);
      _controller.setLooping(false);

      // start playing and listen to state
      await _controller.play();
      _controller.addListener(_videoListener);

      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      debugPrint('Video init error: $e');
      if (mounted)
        setState(() {
          _initialized = false;
          _hasInitError = true;
        });
    }
  }

  void _videoListener() {
    if (_navigated) return;

    final value = _controller.value;
    if (value.hasError) {
      debugPrint('Video error: ${value.errorDescription}');
      // keep showing background; allow user to Skip
      return;
    }

    // If video finished, navigate immediately
    if (value.isInitialized && value.position >= value.duration) {
      _navigateNow();
    }

    // else: if buffering changes, UI will update because build reads controller.value.isBuffering
    if (mounted) setState(() {}); // update buffering state view
  }

  /// Immediately navigate to nextRouteName (used by Skip and by video-finish)
  void _navigateNow() {
    if (_navigated) return;
    _navigated = true;

    // stop listening and stop video
    try {
      _controller.removeListener(_videoListener);
      _controller.pause();
    } catch (_) {}

    // perform navigation only when mounted
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, widget.nextRouteName);
  }

  /// Called by Skip button
  void _forceNavigate() {
    _navigateNow();
  }

  @override
  void dispose() {
    _initTimer?.cancel();
    try {
      _controller.removeListener(_videoListener);
      _controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  Widget _buildBackground() {
    // If image mode and image provided, use it; otherwise fallback to black
    if (widget.backgroundMode == SplashBackgroundMode.image &&
        widget.backgroundImage != null &&
        widget.backgroundImage!.isNotEmpty) {
      return Image.asset(
        widget.backgroundImage!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) {
          // fallback to black if asset not found
          return Container(color: Colors.black);
        },
      );
    }

    return Container(color: Colors.black);
  }

  @override
  Widget build(BuildContext context) {
    final bool showVideo =
        _initialized &&
        _controller.value.isInitialized &&
        !_controller.value.isBuffering &&
        !_hasInitError;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Either show video when ready, else show configured background (black/image)
          if (showVideo) ...[
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ] else ...[
            // Background: black or image (no spinner, no buffering UI)
            _buildBackground(),
          ],

          // Keep Skip button (and don't show any spinner)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // left: nothing (reserved)
                  const SizedBox.shrink(),

                  // right: Skip button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      elevation: 0,
                    ),
                    onPressed: _forceNavigate,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
