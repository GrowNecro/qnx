// lib/widgets/alpha_video_player.dart
// Optimized PNG sequence player with prefetch buffer + eviction
import 'dart:async';
import 'package:flutter/material.dart';

/// Optimized AlphaVideoPlayer for PNG sequences.
/// - Use pngPattern like 'assets/frames/short/short_%04d.png'
/// - pngFrameCount total frames
/// - fps frames per second
/// - bufferSize how many frames to keep prefetched in memory (default 8)
/// - targetDisplayWidth/Height optional: resize frames when decoding to reduce GPU memory.
class AlphaVideoPlayer extends StatefulWidget {
  final String webmAsset;
  final String? pngPattern;
  final int pngFrameCount;
  final int fps;
  final bool loop;
  final bool forceUseWebm;
  final VoidCallback? onFinished;
  final BoxFit fit;
  final int bufferSize;
  final int? targetDisplayWidth;
  final int? targetDisplayHeight;
  final VoidCallback? onFirstFrameRendered;
  final bool reverseFrames;
  final VoidCallback? onEnteringFinalPhase;
  final int finalPhaseFrameCount;

  // Preload behaviour
  final int initialPreloadFrames;
  final bool loadRestAfterPreload;
  final VoidCallback? onPreloadReady;

  const AlphaVideoPlayer({
    super.key,
    required this.webmAsset,
    this.pngPattern,
    this.pngFrameCount = 0,
    this.fps = 24,
    this.loop = false,
    this.forceUseWebm = false,
    this.onFinished,
    this.onFirstFrameRendered,
    this.fit = BoxFit.contain,
    this.bufferSize = 8,
    this.targetDisplayWidth,
    this.targetDisplayHeight,
    this.onPreloadReady,
    this.initialPreloadFrames = 24, // default 24
    this.loadRestAfterPreload = true, // default true
    this.reverseFrames = false,
    this.onEnteringFinalPhase,
    this.finalPhaseFrameCount = 10,
  });

  @override
  State<AlphaVideoPlayer> createState() => _AlphaVideoPlayerState();
}

/// Global cache untuk menyimpan frame yang sudah diload.
/// Key: pngPattern, Value: Set of loaded frame indices.
/// Frame yang sudah diload sekali akan tetap tersedia sepanjang app berjalan.
final Map<String, Set<int>> _globalFrameCache = {};

class _AlphaVideoPlayerState extends State<AlphaVideoPlayer> {
  Timer? _timer;
  int _currentFrame = 0;
  bool _finalPhaseNotified = false;

  /// Get or create cached frames set for current pattern
  Set<int> get _cachedFrames {
    final key = widget.pngPattern ?? '';
    return _globalFrameCache.putIfAbsent(key, () => <int>{});
  }

  // tracking preload
  int _preloadedCount = 0;
  bool _firstFrameNotified = false;
  bool _preloadNotified = false;
  bool _loadingRemainingInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPlayback();
    });
  }

  @override
  void didUpdateWidget(covariant AlphaVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pngPattern != widget.pngPattern ||
        oldWidget.pngFrameCount != widget.pngFrameCount ||
        oldWidget.webmAsset != widget.webmAsset ||
        oldWidget.reverseFrames != widget.reverseFrames) {
      _stopPlayback();
      _currentFrame = 0;
      // Tidak clear cache karena frame yang sudah diload tetap tersedia
      _preloadedCount = _cachedFrames.length; // count existing cached frames
      _firstFrameNotified = _cachedFrames.contains(0);
      _preloadNotified = _cachedFrames.length >= widget.initialPreloadFrames;
      _loadingRemainingInBackground = false;
      _finalPhaseNotified = false;
      _startPlayback();
    }
  }

  @override
  void dispose() {
    _stopPlayback();
    super.dispose();
  }

  int _getDisplayIndex(int logicalFrame) {
    logicalFrame = logicalFrame.clamp(0, widget.pngFrameCount - 1);
    if (!widget.reverseFrames) return logicalFrame;
    return widget.pngFrameCount - 1 - logicalFrame;
  }

  void _startPlayback() {
    if (widget.pngPattern != null &&
        widget.pngFrameCount > 0 &&
        !widget.forceUseWebm) {
      // if initialPreloadFrames > 0, preload first chunk before starting timer/playback
      final toPreload = widget.initialPreloadFrames.clamp(
        1,
        widget.pngFrameCount,
      );
      if (toPreload > 0) {
        _preloadInitialFrames(toPreload).then((_) {
          // after preload chunk ready, start playback loop
          _playPngSequence();
          // optionally kick off background loading of remaining frames
          if (widget.loadRestAfterPreload) {
            _loadRemainingInBackground(toPreload + 1);
          }
        });
      } else {
        _playPngSequence();
      }
      return;
    }

    if (widget.webmAsset.isNotEmpty) {
      _simulateVideoPlayback();
      return;
    }

    widget.onFinished?.call();
  }

  Future<void> _preloadInitialFrames(int toPreload) async {
    for (int i = 0; i < toPreload; i++) {
      if (!mounted) return;
      if (!_cachedFrames.contains(i)) {
        await _prefetchFrame(i);
      }
      // notify first frame when frame 0 is ready
      if (i == 0 && !_firstFrameNotified && _cachedFrames.contains(0)) {
        _firstFrameNotified = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onFirstFrameRendered?.call();
        });
      }
    }
    _preloadNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onPreloadReady?.call();
    });
  }

  Future<void> _loadRemainingInBackground(int startOneBasedIndex) async {
    if (_loadingRemainingInBackground) return;
    _loadingRemainingInBackground = true;
    for (
      int oneBased = startOneBasedIndex;
      oneBased <= widget.pngFrameCount;
      oneBased++
    ) {
      final idx = (oneBased - 1).clamp(0, widget.pngFrameCount - 1);
      if (!mounted) break;
      if (!_cachedFrames.contains(idx)) {
        try {
          await _prefetchFrame(idx);
        } catch (_) {}
        // small throttle to avoid hogging I/O
        await Future.delayed(const Duration(milliseconds: 4));
      }
    }
    _loadingRemainingInBackground = false;
  }

  void _playPngSequence() {
    _stopPlayback();
    final frameDurationMs = (1000 / (widget.fps > 0 ? widget.fps : 24)).round();
    _currentFrame = 0;
    _finalPhaseNotified = false;
    // ensure buffer around first frame
    _ensureBufferedAround(_currentFrame);

    _timer = Timer.periodic(Duration(milliseconds: frameDurationMs), (t) async {
      if (!mounted) return;

      // advance
      _currentFrame++;
      if (_currentFrame >= widget.pngFrameCount) {
        if (widget.loop) {
          _currentFrame = 0;
          _finalPhaseNotified = false;
        } else {
          _stopPlayback();
          widget.onFinished?.call();
          return;
        }
      }

      // Check final phase
      final remaining = widget.pngFrameCount - _currentFrame - 1;
      if (!_finalPhaseNotified && remaining < widget.finalPhaseFrameCount) {
        _finalPhaseNotified = true;
        widget.onEnteringFinalPhase?.call();
      }

      // maintain buffer
      _ensureBufferedAround(_currentFrame);

      setState(() {}); // update displayed frame
    });
  }

  void _ensureBufferedAround(int index) {
    if (widget.pngPattern == null) return;
    final int buffer = widget.bufferSize.clamp(2, 128);
    final int end = (index + buffer).clamp(0, widget.pngFrameCount - 1);

    // Prefetch frames ahead - no eviction, keep all in cache
    for (int i = index; i <= end; i++) {
      if (!_cachedFrames.contains(i)) {
        _prefetchFrame(i);
      }
    }
    // Tidak ada eviction - semua frame yang sudah diload tetap di memory
  }

  Future<void> _prefetchFrame(int frameIndex) async {
    if (!mounted) return;
    try {
      final displayIndex = _getDisplayIndex(frameIndex);
      final path = _formatFramePath(displayIndex);
      final ImageProvider provider = _resizeIfNeeded(AssetImage(path));
      await precacheImage(provider, context);
      _cachedFrames.add(frameIndex);
      _preloadedCount++;

      // if this is the first frame, notify immediate first-frame-rendered
      if (frameIndex == 0 && !_firstFrameNotified) {
        _firstFrameNotified = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onFirstFrameRendered?.call();
        });
      }

      // if we've reached initialPreloadFrames threshold, notify preload ready
      if (!_preloadNotified &&
          widget.initialPreloadFrames > 0 &&
          _preloadedCount >= widget.initialPreloadFrames) {
        _preloadNotified = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onPreloadReady?.call();
        });
      }
    } catch (_) {
      // ignore frame load errors
    }
  }

  ImageProvider _resizeIfNeeded(ImageProvider base) {
    if (widget.targetDisplayWidth != null ||
        widget.targetDisplayHeight != null) {
      final width = widget.targetDisplayWidth;
      final height = widget.targetDisplayHeight;
      if (width != null && height != null) {
        return ResizeImage(base, width: width, height: height);
      } else if (width != null) {
        return ResizeImage(base, width: width);
      } else if (height != null) {
        return ResizeImage(base, height: height);
      }
    }
    return base;
  }

  void _stopPlayback() {
    _timer?.cancel();
    _timer = null;
    // we purposely don't evict all cached frames here to allow reuse across route rebuilds;
    // if you want to free, uncomment the next lines:
    // for (final f in _cachedFrames) {
    //   _evictFrame(f);
    // }
    // _cachedFrames.clear();
  }

  void _simulateVideoPlayback() {
    final durSeconds = (widget.pngFrameCount > 0)
        ? (widget.pngFrameCount / (widget.fps > 0 ? widget.fps : 24))
        : 2;
    final d = Duration(milliseconds: (durSeconds * 1000).round());
    _timer = Timer(d, () {
      if (!mounted) return;
      if (widget.loop) {
        _simulateVideoPlayback();
      } else {
        widget.onFinished?.call();
      }
    });
  }

  String _formatFramePath(int frameIndex) {
    final pattern = widget.pngPattern ?? '';
    final idx = frameIndex + 1;
    if (!pattern.contains('%')) {
      if (pattern.contains('{n}')) {
        return pattern.replaceAll('{n}', idx.toString());
      }
      return '$pattern$idx.png';
    }
    final regex = RegExp(r'%0?(\d+)d');
    final m = regex.firstMatch(pattern);
    if (m != null) {
      final width = int.tryParse(m.group(1) ?? '0') ?? 0;
      final value = idx.toString().padLeft(width, '0');
      return pattern.replaceAll(RegExp(r'%0?\d+d'), value);
    }
    if (pattern.contains('%d')) {
      return pattern.replaceFirst('%d', idx.toString());
    }
    return '$pattern$idx.png';
  }

  @override
  Widget build(BuildContext context) {
    // PNG sequence path: render current PNG frame
    if (widget.pngPattern != null &&
        widget.pngFrameCount > 0 &&
        !widget.forceUseWebm) {
      final idx = _getDisplayIndex(
        _currentFrame.clamp(0, widget.pngFrameCount - 1),
      );
      final path = _formatFramePath(idx);
      final provider = _resizeIfNeeded(AssetImage(path));

      // Fill available area so transparent parts reveal the background under this widget
      return SizedBox.expand(
        child: Image(
          image: provider,
          fit: widget.fit,
          gaplessPlayback: true,
          filterQuality: FilterQuality.low,
        ),
      );
    }

    // WebM fallback (if provided)
    if (widget.webmAsset.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_fill,
              size: 56,
              color: Colors.white.withAlpha((0.9 * 255).round()),
            ),
            const SizedBox(height: 8),
            Text(
              'Playing video (fallback)',
              style: TextStyle(
                color: Colors.white.withAlpha((0.9 * 255).round()),
              ),
            ),
          ],
        ),
      );
    }

    // Nothing to show
    return const SizedBox.shrink();
  }
}
