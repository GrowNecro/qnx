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

  /// Jika true, stage (pageUnder) akan mulai ditampilkan saat overlay
  /// masuk fase akhir (terakhir N frame). Berguna untuk mode normal/intro
  /// agar pageUnder tidak tampil terlalu cepat.
  final bool stageStartOnFinalPhase;

  /// Berapa frame dari akhir dianggap "fase akhir".
  /// Default 10 frame.
  final int finalPhaseFrameCount;

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
    this.bufferSize = 4,
    this.targetDisplayWidth,
    this.targetDisplayHeight,
    this.stageStartFrames = 1,
    this.stageStartOnFinalPhase = false,
    this.finalPhaseFrameCount = 10,
    this.initialDelay = Duration.zero,
    this.endFrameDelay = const Duration(milliseconds: 80),
    this.overlayFadeOut = true,
    this.overlayFadeDuration = const Duration(milliseconds: 150),
    this.initialFreeze = const Duration(milliseconds: 100),
    this.reverseFrames = false,
    this.autoPopOnFinish = false,
    this.audioAsset,
    this.audioLoop = true,
    this.initialAudioMuted = false,
    this.pageReadyFuture,
    this.pageReadyTimeout = const Duration(milliseconds: 300),
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
        stageStartOnFinalPhase: stageStartOnFinalPhase,
        finalPhaseFrameCount: finalPhaseFrameCount,
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

  /// Jika true, stage dimulai saat masuk fase akhir animasi.
  final bool stageStartOnFinalPhase;

  /// Berapa frame dari akhir dianggap "fase akhir".
  final int finalPhaseFrameCount;

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
    this.stageStartOnFinalPhase = false,
    this.finalPhaseFrameCount = 10,
    required this.endFrameDelay,
    this.initialFreeze = const Duration(milliseconds: 100),
    this.pageReadyFuture,
    this.pageReadyTimeout = const Duration(milliseconds: 300),
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

  // whether pageUnder reported ready (via provided future) or default true
  bool _pageReady = false;

  // Key untuk AlphaVideoPlayer (tidak perlu akses state lagi, tapi tetap simpan untuk rebuild)
  final GlobalKey _playerKey = GlobalKey();

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

    if (widget.audioAsset != null) {
      _initAudio(
        widget.audioAsset!,
        widget.audioLoop,
        widget.initialAudioMuted,
      );
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
  }

  // Called when initial preload is ready - playback auto-starts
  void _onPreloadReady() {
    if (!mounted) return;

    // Jika tidak pakai stageStartOnFinalPhase, langsung tampilkan stage
    if (!widget.stageStartOnFinalPhase) {
      setState(() {
        _stageStarted = true;
      });
    }
  }

  // Called when AlphaVideoPlayer enters final phase (last N frames)
  void _onEnteringFinalPhase() {
    if (!mounted) return;
    if (_stageStarted) return; // already started

    // Only trigger if stageStartOnFinalPhase is enabled
    if (widget.stageStartOnFinalPhase) {
      setState(() {
        _stageStarted = true;
      });
    }
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
      key: _playerKey,
      webmAsset: '',
      pngPattern: widget.pngPattern,
      pngFrameCount: widget.pngFrameCount,
      fps: widget.fps,
      loop: widget.loop,
      forceUseWebm: false,
      onFinished: _onAlphaFinished,
      onPreloadReady: _onPreloadReady,
      onEnteringFinalPhase: _onEnteringFinalPhase,
      finalPhaseFrameCount: widget.finalPhaseFrameCount,
      fit: BoxFit.cover,
      bufferSize: widget.bufferSize,
      targetDisplayWidth: widget.targetDisplayWidth,
      targetDisplayHeight: widget.targetDisplayHeight,
      reverseFrames: widget.reverseFrames,
      initialPreloadFrames: 24, // preload 24 frame dulu sebelum playback
    );

    // Fullscreen dengan Scaffold yang extend ke belakang status bar
    // Untuk outro (stageStartFrames sangat besar), buat transparent agar current page terlihat
    final isOverlayOnly = widget.stageStartDelay.inMilliseconds > 5000;
    return Scaffold(
      backgroundColor: isOverlayOnly ? Colors.transparent : Colors.black,
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
