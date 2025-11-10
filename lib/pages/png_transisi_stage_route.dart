// lib/pages/png_transisi_stage_route.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../widgets/alpha_video_player.dart';

/// PngTransisiStageRoute — overlay-first mode
/// Overlay (PNG animation) dimulai duluan.
/// Stage (pageUnder) mulai berjalan setelah n frame overlay (default: 1 frame).
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
  final int
  stageStartFrames; // berapa frame overlay sebelum stage mulai (default 1)
  final Duration initialDelay;
  final Duration endFrameDelay;
  final bool overlayFadeOut;
  final Duration overlayFadeDuration;

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
    this.stageStartFrames = 1, // default: mulai setelah 1 frame
    this.initialDelay = Duration.zero,
    this.endFrameDelay = const Duration(milliseconds: 140),
    this.overlayFadeOut = true,
    this.overlayFadeDuration = const Duration(milliseconds: 240),
  });

  @override
  Duration get transitionDuration => Duration.zero;
  @override
  Duration get reverseTransitionDuration => Duration.zero;
  @override
  bool get maintainState => true;
  @override
  bool get opaque => true;
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
    // Hitung delay start stage dari frame count (mis. 1 frame @24fps = ~41.6ms)
    final stageStartDelay = Duration(
      milliseconds: ((1000 / fps) * stageStartFrames).round(),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: _StageOverlayBody(
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
        stageStartDelay: stageStartDelay, // auto dihitung dari FPS
        endFrameDelay: endFrameDelay,
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
  final Duration initialDelay; // delay before starting overlay (usually zero)
  final Duration stageStartDelay; // when pageUnder should start (e.g. 500ms)
  final Duration
  endFrameDelay; // small wait after overlay finished before hiding
  final Duration initialFreeze; // how long to hold first frame (default 500ms)

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
  });

  @override
  State<_StageOverlayBody> createState() => _StageOverlayBodyState();
}

class _StageOverlayBodyState extends State<_StageOverlayBody> {
  // overlay visibility
  bool _showOverlay = true;

  // whether overlay sequence player should be mounted/playing
  bool _alphaPlayerMounted = false;

  // freeze first frame visible for `initialFreeze`
  bool _firstFrameFrozen = true;

  // whether stage (pageUnder) has been started/rendered
  bool _stageStarted = false;

  // whether alpha sequence finished
  bool _finished = false;

  // cached path for first frame (if pngPattern contains %04d)
  late final String _firstFramePath;

  @override
  void initState() {
    super.initState();

    // prepare first-frame asset path if pattern uses %04d
    if (widget.pngPattern.contains('%04d')) {
      _firstFramePath = widget.pngPattern.replaceAll(
        '%04d',
        1.toString().padLeft(4, '0'),
      );
    } else {
      _firstFramePath = widget.pngPattern
          .replaceAll('%d', 1.toString())
          .replaceAll('%04', '0001');
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // start overlay after optional initialDelay (but we still show the frozen frame)
      if (widget.initialDelay > Duration.zero) {
        Future.delayed(widget.initialDelay, () {
          if (!mounted) return;
          // overlay presence indicated by first-frame freeze; alpha player will mount after freeze
        });
      }

      // schedule end of freeze: after initialFreeze, mount the AlphaVideoPlayer
      Future.delayed(widget.initialFreeze, () {
        if (!mounted) return;
        setState(() {
          _firstFrameFrozen = false;
          _alphaPlayerMounted = true;
        });
      });

      // schedule stage start (pageUnder) after requested delay (e.g. 500ms)
      if (widget.stageStartDelay > Duration.zero) {
        Future.delayed(widget.stageStartDelay, () {
          if (!mounted) return;
          setState(() {
            _stageStarted = true;
          });
        });
      } else {
        // start immediately
        setState(() {
          _stageStarted = true;
        });
      }
    });
  }

  // Called when AlphaVideoPlayer signals finished
  Future<void> _onAlphaFinished() async {
    if (_finished) return;
    _finished = true;

    // little extra delay for last frame
    await Future.delayed(widget.endFrameDelay);
    if (!mounted) return;

    // NO fade — hide overlay immediately (hard cut)
    setState(() {
      _showOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build overlay content depend on whether first frame freeze is active
    Widget overlayContent;

    if (_firstFrameFrozen) {
      // show static first frame (asset). If first frame file missing, fallback to transparent container.
      overlayContent = Positioned.fill(child: _buildFirstFrameWidget());
    } else {
      // mount the AlphaVideoPlayer (it will play the sequence)
      overlayContent = Positioned.fill(
        child: AlphaVideoPlayer(
          webmAsset: '',
          pngPattern: widget.pngPattern,
          pngFrameCount: widget.pngFrameCount,
          fps: widget.fps,
          loop: widget.loop,
          forceUseWebm: false,
          onFinished: _onAlphaFinished,
          fit: BoxFit.cover,
          bufferSize: widget.bufferSize,
          targetDisplayWidth: widget.targetDisplayWidth,
          targetDisplayHeight: widget.targetDisplayHeight,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1) pageUnder - rendered when _stageStarted true.
        if (_stageStarted)
          Positioned.fill(
            child: IgnorePointer(
              ignoring:
                  _showOverlay, // disable interactions while overlay visible
              child: widget.pageUnder,
            ),
          ),

        // 2) overlay: show while _showOverlay true. If alpha player hasn't mounted yet,
        //    we show frozen first-frame image instead.
        if (_showOverlay) Positioned.fill(child: overlayContent),

        // 3) debug small overlay (optional)
        // Positioned(
        //   left: 8,
        //   top: 8,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        //     decoration: BoxDecoration(
        //       color: Colors.black45,
        //       borderRadius: BorderRadius.circular(6),
        //     ),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text(
        //           'Overlay ${_firstFrameFrozen ? "FRAME1" : (_alphaPlayerMounted ? "PLAYING" : "WAIT")}',
        //           style: const TextStyle(color: Colors.white, fontSize: 11),
        //         ),
        //         Text(
        //           'Stage ${_stageStarted ? "RUN" : "WAIT"}',
        //           style: const TextStyle(color: Colors.white70, fontSize: 11),
        //         ),
        //         Text(
        //           'OverlayVisible: ${_showOverlay ? "YES" : "NO"}',
        //           style: const TextStyle(color: Colors.white70, fontSize: 10),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFirstFrameWidget() {
    // If backgroundBytes provided, try to use it; else try to use asset path pattern.
    if (widget.backgroundBytes != null) {
      return Image.memory(
        widget.backgroundBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        width: double.infinity,
        height: double.infinity,
      );
    }

    // Try to load first frame from assets using computed path
    try {
      return Image.asset(
        _firstFramePath,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) {
          // fallback to plain black if asset missing
          return Container(color: Colors.black);
        },
      );
    } catch (_) {
      return Container(color: Colors.black);
    }
  }
}
