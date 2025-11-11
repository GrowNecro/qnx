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
  });

  @override
  State<AlphaVideoPlayer> createState() => _AlphaVideoPlayerState();
}

class _AlphaVideoPlayerState extends State<AlphaVideoPlayer> {
  Timer? _timer;
  int _currentFrame = 0;
  final Set<int> _cachedFrames = <int>{};

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
        oldWidget.webmAsset != widget.webmAsset) {
      _stopPlayback();
      _currentFrame = 0;
      _cachedFrames.clear();
      _preloadedCount = 0;
      _firstFrameNotified = false;
      _preloadNotified = false;
      _loadingRemainingInBackground = false;
      _startPlayback();
    }
  }

  @override
  void dispose() {
    _stopPlayback();
    super.dispose();
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
    // ensure buffer around first frame
    _ensureBufferedAround(_currentFrame);

    _timer = Timer.periodic(Duration(milliseconds: frameDurationMs), (t) async {
      if (!mounted) return;

      // advance
      _currentFrame++;
      if (_currentFrame >= widget.pngFrameCount) {
        if (widget.loop) {
          _currentFrame = 0;
        } else {
          _stopPlayback();
          widget.onFinished?.call();
          return;
        }
      }

      // maintain buffer
      _ensureBufferedAround(_currentFrame);

      setState(() {}); // update displayed frame
    });
  }

  void _ensureBufferedAround(int index) {
    if (widget.pngPattern == null) return;
    final int buffer = widget.bufferSize.clamp(2, 128);
    final int start = (index - 2).clamp(0, widget.pngFrameCount - 1);
    final int end = (index + buffer).clamp(0, widget.pngFrameCount - 1);

    for (int i = index; i <= end; i++) {
      if (!_cachedFrames.contains(i)) {
        _prefetchFrame(i);
      }
    }

    final keepStart = (index - 4).clamp(0, widget.pngFrameCount - 1);
    final keepEnd = (index + buffer).clamp(0, widget.pngFrameCount - 1);
    final toEvict = _cachedFrames
        .where((f) => f < keepStart || f > keepEnd)
        .toList();
    for (final f in toEvict) {
      _evictFrame(f);
    }
  }

  Future<void> _prefetchFrame(int frameIndex) async {
    if (!mounted) return;
    try {
      final path = _formatFramePath(frameIndex);
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

  void _evictFrame(int frameIndex) {
    final path = _formatFramePath(frameIndex);
    try {
      final provider = _resizeIfNeeded(AssetImage(path));
      imageCache.evict(provider);
    } catch (_) {}
    _cachedFrames.remove(frameIndex);
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
      final idx = (_currentFrame.clamp(0, widget.pngFrameCount - 1));
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
