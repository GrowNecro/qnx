// lib/pages/video_transisi_png.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../widgets/alpha_video_player.dart';
import '../utils/memory_cache.dart';
import '../utils/screenshot_disk.dart';

/// PngTransisiPage:
/// - Bisa auto-load screenshot dari MemoryCache atau Disk via backgroundKey.
/// - Jika tidak ada screenshot, gunakan nextPageBuilder untuk merender halaman tujuan
///   langsung sebagai background (non-interactive) selama transisi.
/// - Menggunakan BoxFit.cover agar PNG frames isi layar penuh.
/// - Menambahkan delay pendek sebelum navigasi agar frame terakhir tampil penuh.
/// - Menambahkan logging & overlay debug untuk menampilkan apakah screenshot/page digunakan.
class PngTransisiPage extends StatefulWidget {
  final WidgetBuilder? nextPageBuilder;
  final Uint8List? backgroundImageBytes; // screenshot bytes (PNG)
  final String? backgroundKey; // optional key untuk auto-load dari cache/disk
  final String pngPattern;
  final int pngFrameCount;
  final int fps;
  final bool loop;
  final int bufferSize;
  final int? targetDisplayWidth;
  final int? targetDisplayHeight;

  const PngTransisiPage({
    super.key,
    this.nextPageBuilder,
    required this.pngPattern,
    required this.pngFrameCount,
    this.backgroundImageBytes,
    this.backgroundKey,
    this.fps = 24,
    this.loop = false,
    this.bufferSize = 8,
    this.targetDisplayWidth,
    this.targetDisplayHeight,
  });

  @override
  State<PngTransisiPage> createState() => _PngTransisiPageState();
}

class _PngTransisiPageState extends State<PngTransisiPage> {
  bool _navigated = false;
  static const int _endFrameDelayMs = 140;
  Uint8List? _bgBytes; // hasil auto-load dari cache/disk atau dari constructor
  bool _videoStarted =
      false; // start playback after short delay so bg can render
  bool _triedLoad = false; // used for logging/debug overlay

  @override
  void initState() {
    super.initState();
    _initBackgroundBytes();
  }

  Future<void> _initBackgroundBytes() async {
    debugPrint(
      'PngTransisiPage: init background (key=${widget.backgroundKey})',
    );
    // 1️⃣ Kalau sudah ada dari constructor, langsung pakai.
    if (widget.backgroundImageBytes != null) {
      _bgBytes = widget.backgroundImageBytes;
      _triedLoad = true;
      debugPrint(
        'PngTransisiPage: using provided backgroundImageBytes (${_bgBytes?.lengthInBytes ?? 0} bytes)',
      );
      _startVideoWithDelay();
      return;
    }

    // 2️⃣ Kalau ada key, coba load dari MemoryCache → Disk.
    if (widget.backgroundKey != null) {
      final cache = MemoryScreenshotCache();
      Uint8List? bytes = cache.get(widget.backgroundKey!);
      if (bytes != null) {
        debugPrint(
          'PngTransisiPage: found screenshot in memory for ${widget.backgroundKey} (${bytes.lengthInBytes} bytes)',
        );
      } else {
        debugPrint(
          'PngTransisiPage: not found in memory, trying disk for ${widget.backgroundKey}',
        );
        bytes = await loadScreenshotFromDisk(widget.backgroundKey!);
        if (bytes != null) {
          debugPrint(
            'PngTransisiPage: loaded screenshot from disk for ${widget.backgroundKey} (${bytes.lengthInBytes} bytes)',
          );
        }
      }

      _triedLoad = true;
      if (bytes != null && mounted) {
        setState(() {
          _bgBytes = bytes;
        });
        _startVideoWithDelay();
        debugPrint('PngTransisiPage: background ready, starting video soon.');
      } else {
        debugPrint(
          'PngTransisiPage: no screenshot found for ${widget.backgroundKey}',
        );
        _startVideoWithDelay();
      }
      return;
    }

    // 3️⃣ Tidak ada key/bytes — kita tetap start video after small delay.
    _triedLoad = true;
    _startVideoWithDelay();
    debugPrint(
      'PngTransisiPage: no background key/bytes provided, will render nextPageBuilder as bg if available.',
    );
  }

  void _startVideoWithDelay() {
    // ensure widget paints background first, then start the alpha animation
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) {
        setState(() {
          _videoStarted = true;
        });
      }
    });
  }

  Future<void> _onFinished() async {
    if (_navigated) return;
    _navigated = true;

    // Tunggu sedikit agar frame terakhir benar-benar muncul
    await Future.delayed(const Duration(milliseconds: _endFrameDelayMs));

    if (!mounted) return;

    // Jika nextPageBuilder diberikan, gunakan itu; jika tidak, push replacement kosong.
    final builder = widget.nextPageBuilder;
    if (builder != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (ctx, anim, sec) => builder(ctx),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (ctx, anim, sec) => const SizedBox.shrink(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _bgBytes ?? widget.backgroundImageBytes;

    Widget backgroundWidget;

    if (imageBytes != null) {
      //  A: gunakan image bytes jika tersedia
      backgroundWidget = Image.memory(
        imageBytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (widget.nextPageBuilder != null) {
      //  B: jika tidak ada bytes, render halaman tujuan langsung sebagai background.
      //     Bungkus dengan AbsorbPointer agar tidak bisa diinteraksi selama transisi.
      backgroundWidget = AbsorbPointer(
        absorbing: true,
        child: Builder(
          builder: (ctx) {
            // gunakan nextPageBuilder untuk membuat halaman tujuan inline
            return SizedBox.expand(child: widget.nextPageBuilder!(ctx));
          },
        ),
      );
    } else {
      //  C: fallback solid color
      backgroundWidget = Container(
        color: const Color.fromARGB(255, 158, 25, 25),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background (either image bytes, the built page, or fallback color)
          Positioned.fill(child: backgroundWidget),

          // Transition animation (start only after short delay)
          if (_videoStarted)
            Positioned.fill(
              child: AlphaVideoPlayer(
                webmAsset: '',
                pngPattern: widget.pngPattern,
                pngFrameCount: widget.pngFrameCount,
                fps: widget.fps,
                loop: widget.loop,
                forceUseWebm: false,
                onFinished: _onFinished,
                fit: BoxFit.cover,
                bufferSize: widget.bufferSize,
                targetDisplayWidth: widget.targetDisplayWidth,
                targetDisplayHeight: widget.targetDisplayHeight,
              ),
            ),

          // Debug overlay (small)
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transisi: ${widget.pngPattern.split('/').last}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BG: ${imageBytes != null ? '${imageBytes.lengthInBytes} bytes' : (widget.nextPageBuilder != null ? 'NEXT PAGE' : 'NONE')}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Video started: ${_videoStarted ? 'YES' : 'WAIT'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
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
