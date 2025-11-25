// lib/pages/png_transisi_stage_route.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import '../widgets/alpha_video_player.dart';

/// Style untuk fullscreen immersive (status bar & nav bar transparan)
const _kFullscreenOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarContrastEnforced: false,
);

/// PngTransisiStageRoute — overlay-first mode
/// - Bisa dipakai untuk:
///   1) Intro: pageUnder = halaman baru (page tujuan), overlay animasi di atasnya.
///   2) Outro (tirai di current page): pageUnder = SizedBox.shrink(),
///      opaque = false, jadi yang kelihatan di bawah adalah halaman lama.
///
/// Stage (pageUnder) mulai dirender setelah N frame overlay (default 1).
class PngTransisiStageRoute extends PageRoute<void> {
  final Widget pageUnder;
  final Uint8List? backgroundBytes;
  final String pngPattern;
  final int pngFrameCount;
  final int fps;
  final bool loop;
  final int bufferSize;
  final int? targetDisplayWidth;
  final int? targetDisplayHeight;
  final VoidCallback? onTransitionFinished;

  /// Berapa frame overlay sebelum stage mulai (default 1).
  /// Untuk kasus outro (overlay-only), bisa di-set besar (misal 9999)
  /// supaya stage tidak pernah dimulai.
  final int stageStartFrames;

  final Duration initialDelay;
  final Duration endFrameDelay;
  final bool overlayFadeOut;
  final Duration overlayFadeDuration;
  final Duration initialFreeze;
  final bool reverseFrames;

  /// Jika true, route akan otomatis dipop ketika animasi selesai.
  /// - Intro page: biasanya false (route ini adalah page utamanya).
  /// - Outro overlay di current page: biasanya true (supaya await push(..) selesai).
  final bool autoPopOnFinish;

  /// audio support
  final String? audioAsset;
  final bool audioLoop;
  final bool initialAudioMuted;

  /// Jika diberikan, route akan menunggu future ini selesai sebelum menampilkan pageUnder.
  final Future<void>? pageReadyFuture;
  final Duration pageReadyTimeout;

  PngTransisiStageRoute({
    required this.pageUnder,
    this.backgroundBytes,
    required this.pngPattern,
    required this.pngFrameCount,
    this.fps = 24,
    this.loop = false,
    this.bufferSize = 8,
    this.targetDisplayWidth,
    this.targetDisplayHeight,
    this.stageStartFrames = 1,
    this.initialDelay = Duration.zero,
    this.endFrameDelay = const Duration(milliseconds: 140),
    this.overlayFadeOut = true,
    this.overlayFadeDuration = const Duration(milliseconds: 240),
    this.initialFreeze = const Duration(milliseconds: 500),
    this.reverseFrames = false,
    this.autoPopOnFinish = false,
    this.audioAsset,
    this.audioLoop = true,
    this.initialAudioMuted = false,
    this.pageReadyFuture,
    this.pageReadyTimeout = const Duration(milliseconds: 800),
    this.onTransitionFinished,
  });

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  bool get maintainState => true;

  /// Dibuat non-opaque supaya:
  /// - Kalau dipakai sebagai overlay-only, page lama tetap kelihatan di bawah.
  /// - Kalau dipakai sebagai intro, pageUnder sendiri menutupi area full.
  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> a1,
    Animation<double> a2,
  ) {
    final stageStartDelay = Duration(
      milliseconds: ((1000 / fps) * stageStartFrames).round(),
    );

    // Pastikan overlay benar-benar fullscreen:
    // buang semua padding dari MediaQuery (SafeArea, status bar, nav bar, dll).
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: _StageOverlayBody(
        pageUnder: pageUnder,
        backgroundBytes: backgroundBytes,
        pngPattern: pngPattern,
        pngFrameCount: pngFrameCount,
        fps: fps,
        loop: loop,
        bufferSize: bufferSize,
        targetDisplayWidth: targetDisplayWidth,
        targetDisplayHeight: targetDisplayHeight,
        initialDelay: initialDelay,
        stageStartDelay: stageStartDelay,
        endFrameDelay: endFrameDelay,
        initialFreeze: initialFreeze,
        pageReadyFuture: pageReadyFuture,
        pageReadyTimeout: pageReadyTimeout,
        audioAsset: audioAsset,
        audioLoop: audioLoop,
        initialAudioMuted: initialAudioMuted,
        reverseFrames: reverseFrames,
        autoPopOnFinish: autoPopOnFinish,
        onTransitionFinished: onTransitionFinished,
      ),
    );
  }
}

class _StageOverlayBody extends StatefulWidget {
  final Widget pageUnder;
  final Uint8List? backgroundBytes;
  final String pngPattern;
  final int pngFrameCount;
  final int fps;
  final bool loop;
  final int bufferSize;
  final int? targetDisplayWidth;
  final int? targetDisplayHeight;
  final VoidCallback? onTransitionFinished;

  /// Delay sebelum mulai overlay (biasanya zero).
  final Duration initialDelay;

  /// Kapan pageUnder mulai dirender (relatif ke start overlay).
  final Duration stageStartDelay;

  /// Delay kecil setelah overlay selesai sebelum disembunyikan.
  final Duration endFrameDelay;

  /// Masih disimpan untuk kompatibilitas.
  final Duration initialFreeze;

  /// Kalau true, urutan frame dibalik (dipakai buat tirai/outro).
  final bool reverseFrames;

  /// Kalau true, route akan Auto-pop ketika animasi selesai.
  final bool autoPopOnFinish;

  final Future<void>? pageReadyFuture;
  final Duration pageReadyTimeout;

  // audio
  final String? audioAsset;
  final bool audioLoop;
  final bool initialAudioMuted;

  const _StageOverlayBody({
    required this.pageUnder,
    this.backgroundBytes,
    required this.pngPattern,
    required this.pngFrameCount,
    required this.fps,
    required this.loop,
    required this.bufferSize,
    required this.targetDisplayWidth,
    required this.targetDisplayHeight,
    required this.initialDelay,
    required this.stageStartDelay,
    required this.endFrameDelay,
    this.initialFreeze = const Duration(milliseconds: 500),
    this.pageReadyFuture,
    this.pageReadyTimeout = const Duration(milliseconds: 800),
    this.audioAsset,
    this.audioLoop = true,
    this.initialAudioMuted = false,
    this.reverseFrames = false,
    this.autoPopOnFinish = false,
    this.onTransitionFinished,
  });

  @override
  State<_StageOverlayBody> createState() => _StageOverlayBodyState();
}

class _StageOverlayBodyState extends State<_StageOverlayBody> {
  // overlay visibility
  bool _showOverlay = true;

  // whether stage (pageUnder) has been started/rendered
  bool _stageStarted = false;

  // whether alpha sequence finished
  bool _finished = false;

  // whether preload event signaled by AlphaVideoPlayer happened
  bool _preloadReady = false;

  // whether pageUnder reported ready (via provided future) or default true
  bool _pageReady = false;

  // Completers used to coordinate readiness
  late final Completer<void> _preloadReadyCompleter;
  late final Completer<void> _stageDelayCompleter;

  // AUDIO
  VideoPlayerController? _audioController;
  bool _audioInitialized = false;
  bool _audioMuted = false;
  bool _audioAvailable = false;

  @override
  void initState() {
    super.initState();

    // Fullscreen immersive - sembunyikan status bar & navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _preloadReadyCompleter = Completer<void>();
    _stageDelayCompleter = Completer<void>();

    if (widget.audioAsset != null) {
      _initAudio(
        widget.audioAsset!,
        widget.audioLoop,
        widget.initialAudioMuted,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Optional initialDelay (retained for compatibility)
      if (widget.initialDelay > Duration.zero) {
        Future.delayed(widget.initialDelay, () {
          if (!mounted) return;
        });
      }

      // schedule stageStartDelay completer (frame-based small delay)
      if (widget.stageStartDelay > Duration.zero) {
        Future.delayed(widget.stageStartDelay, () {
          if (!mounted) return;
          if (!_stageDelayCompleter.isCompleted) {
            _stageDelayCompleter.complete();
          }
        });
      } else {
        if (!_stageDelayCompleter.isCompleted) {
          _stageDelayCompleter.complete();
        }
      }

      // wait for pageReadyFuture (with timeout) if provided
      if (widget.pageReadyFuture != null) {
        widget.pageReadyFuture!
            .then((_) {
              if (!mounted) return;
              _pageReady = true;
            })
            .catchError((_) {
              if (!mounted) return;
              _pageReady = true;
            });

        // timeout fallback
        Future.delayed(widget.pageReadyTimeout, () {
          if (!mounted) return;
          if (!_pageReady) _pageReady = true;
        });
      } else {
        _pageReady = true;
      }

      // Wait for preload readiness AND stage delay, then check page readiness before starting stage.
      Future.wait([
        _preloadReadyCompleter.future,
        _stageDelayCompleter.future,
      ]).then((_) async {
        // poll until pageReady or timeout
        final sw = Stopwatch()..start();
        while (!_pageReady &&
            sw.elapsed <
                widget.pageReadyTimeout + const Duration(milliseconds: 50)) {
          await Future.delayed(const Duration(milliseconds: 16));
          if (!mounted) return;
        }
        if (!mounted) return;

        setState(() {
          _stageStarted = true;
        });
      });
    });
  }

  Future<void> _initAudio(String asset, bool loop, bool initialMuted) async {
    try {
      _audioController = VideoPlayerController.asset(asset);
      await _audioController!.initialize();
      _audioController!.setLooping(loop);
      _audioMuted = initialMuted;
      _audioInitialized = true;
      _audioAvailable = true;
      await _audioController!.setVolume(_audioMuted ? 0.0 : 1.0);
      _audioController!.play();
    } catch (e) {
      _audioAvailable = false;
      _audioInitialized = false;
    }
    if (mounted) setState(() {});
  }

  // Called when AlphaVideoPlayer signals finished
  Future<void> _onAlphaFinished() async {
    if (_finished) return;
    _finished = true;

    await Future.delayed(widget.endFrameDelay);
    if (!mounted) return;

    if (_audioController != null && _audioAvailable) {
      try {
        await _audioController!.pause();
        await _audioController!.seekTo(Duration.zero);
      } catch (_) {}
    }

    // 1) panggil callback dulu untuk ganti halaman (kalau ada)
    if (widget.onTransitionFinished != null) {
      widget.onTransitionFinished!();
    }

    // 2) baru hilangkan overlay dari tree
    setState(() {
      _showOverlay = false;
    });

    // 3) kalau masih mau auto-pop untuk kasus lain, boleh tetap:
    if (widget.autoPopOnFinish) {
      Future.microtask(() {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  // Called when AlphaVideoPlayer reports preload ready or first frame rendered
  void _onPreloadReady() {
    if (!mounted) return;
    if (_preloadReady) return;
    _preloadReady = true;
    if (!_preloadReadyCompleter.isCompleted) {
      _preloadReadyCompleter.complete();
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    if (_audioController != null) {
      try {
        _audioController!.dispose();
      } catch (_) {}
      _audioController = null;
    }
    super.dispose();
  }

  void _toggleAudioMute() async {
    if (!_audioAvailable || _audioController == null) return;
    setState(() {
      _audioMuted = !_audioMuted;
    });
    try {
      await _audioController!.setVolume(_audioMuted ? 0.0 : 1.0);
      if (!_audioMuted && !_audioController!.value.isPlaying) {
        await _audioController!.play();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final alphaPlayer = AlphaVideoPlayer(
      webmAsset: '',
      pngPattern: widget.pngPattern,
      pngFrameCount: widget.pngFrameCount,
      fps: widget.fps,
      loop: widget.loop,
      forceUseWebm: false,
      onFinished: _onAlphaFinished,
      initialPreloadFrames: 24,
      loadRestAfterPreload: true,
      onPreloadReady: _onPreloadReady,
      onFirstFrameRendered: _onPreloadReady,
      fit: BoxFit.cover,
      bufferSize: widget.bufferSize,
      targetDisplayWidth: widget.targetDisplayWidth,
      targetDisplayHeight: widget.targetDisplayHeight,
      reverseFrames: widget.reverseFrames,
    );

    // Fullscreen dengan Scaffold yang extend ke belakang status bar
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _kFullscreenOverlayStyle,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1) pageUnder - instantiate & show only when _stageStarted && _pageReady
              if (_stageStarted && _pageReady)
                Positioned.fill(child: widget.pageUnder),

              // 2) overlay group (player)
              if (_showOverlay)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: false,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // alphaPlayer full screen
                        Positioned.fill(child: alphaPlayer),

                        // optional audio control while overlay visible
                        if (_audioAvailable)
                          Positioned(
                            top: 18,
                            right: 12,
                            child: Material(
                              color: Colors.black.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                padding: const EdgeInsets.all(6),
                                iconSize: 20,
                                tooltip: _audioMuted ? 'Unmute' : 'Mute',
                                icon: Icon(
                                  _audioMuted
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: Colors.white,
                                ),
                                onPressed: _audioInitialized
                                    ? _toggleAudioMute
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
