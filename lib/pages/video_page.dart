import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart'
    show rootBundle, SystemChrome, SystemUiMode;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'png_transisi_stage_route.dart';
import 'aljabar_quiz_page.dart';
import '../l10n/app_localizations.dart';
import '../utils/materi_localizer.dart';

class VideoPage extends StatefulWidget {
  final String videoPath; // could be asset path, http(s) mp4 or YouTube URL
  final String judulMateri;
  final String judullatihan;

  /// Path asset gambar yang ingin ditampilkan ketika video selesai.
  final String endBackgroundAsset;

  const VideoPage({
    super.key,
    required this.videoPath,
    required this.judulMateri,
    required this.judullatihan,
    this.endBackgroundAsset = 'assets/images/background.png',
  });

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;

  bool _isYoutube = false;

  bool _isInitialized = false;
  bool _youtubeReady = false;

  bool _isNavigatingToQuiz = false;
  bool _showExerciseButton = false;
  bool _isPlaying = false;
  bool _hasStartedPlaying = false;

  @override
  void initState() {
    super.initState();

    // Fullscreen immersive
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _detectAndInitController();
  }

  void _detectAndInitController() {
    final path = widget.videoPath.trim();

    // Deteksi YouTube
    final youtubeId = YoutubePlayer.convertUrlToId(path);
    if (youtubeId != null && youtubeId.isNotEmpty) {
      _isYoutube = true;
      _initYoutubeController(youtubeId);
      return;
    }

    // Deteksi network atau asset
    if (path.startsWith('http://') || path.startsWith('https://')) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(path))
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _isInitialized = true);
          _videoController?.play();
        });
    } else {
      _videoController = VideoPlayerController.asset(path)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _isInitialized = true);
          _videoController?.play();
        });
    }

    if (_videoController != null) {
      _videoController!.addListener(_videoListener);
    }
  }

  void _initYoutubeController(String videoId) {
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: false,
        enableCaption: false,
        disableDragSeek: false,
        hideControls: true,
        controlsVisibleAtStart: false,
        loop: false,
        useHybridComposition: true,
      ),
    )..addListener(_youtubeListener);
  }

  void _youtubeListener() {
    if (!mounted || _youtubeController == null) return;

    final value = _youtubeController!.value;

    if (value.isReady && !_youtubeReady) {
      setState(() => _youtubeReady = true);
    }

    // Track playing state
    final isCurrentlyPlaying = value.playerState == PlayerState.playing;
    if (_isPlaying != isCurrentlyPlaying) {
      setState(() => _isPlaying = isCurrentlyPlaying);
    }

    // Track if video has started playing
    if (!_hasStartedPlaying && value.position.inMilliseconds > 100) {
      setState(() => _hasStartedPlaying = true);
    }

    // Saat video berakhir - langsung ke quiz
    if (value.playerState == PlayerState.ended) {
      try {
        _youtubeController?.pause();
      } catch (_) {}
      // Langsung ke quiz saat video selesai
      if (!_isNavigatingToQuiz) {
        _isNavigatingToQuiz = true;
        _goToLatihan(context);
      }
      return;
    }

    // Fallback: cek juga berdasarkan posisi mendekati akhir (untuk kasus ended tidak terpanggil)
    if (value.isReady && value.position.inSeconds > 0) {
      final remaining =
          value.metaData.duration.inSeconds - value.position.inSeconds;
      if (remaining <= 1 && remaining >= 0) {
        if (!_isNavigatingToQuiz) {
          _isNavigatingToQuiz = true;
          try {
            _youtubeController?.pause();
          } catch (_) {}
          _goToLatihan(context);
        }
      }
    }
  }

  void _videoListener() {
    final c = _videoController;
    if (c == null || !c.value.isInitialized) return;

    // Track playing state
    final isCurrentlyPlaying = c.value.isPlaying;
    if (_isPlaying != isCurrentlyPlaying) {
      setState(() => _isPlaying = isCurrentlyPlaying);
    }

    final position = c.value.position;
    final duration = c.value.duration;

    if (position >= duration - const Duration(milliseconds: 150)) {
      if (c.value.isPlaying) c.pause();
      // Langsung ke quiz saat video selesai
      if (!_isNavigatingToQuiz) {
        _isNavigatingToQuiz = true;
        _goToLatihan(context);
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    try {
      _videoController?.removeListener(_videoListener);
      _videoController?.dispose();
    } catch (_) {}

    try {
      _youtubeController?.removeListener(_youtubeListener);
      _youtubeController?.dispose();
    } catch (_) {}

    super.dispose();
  }

  void _onCenterTapped() {
    if (_isYoutube) {
      if (_youtubeController == null || !_youtubeReady) return;
      final playing = _youtubeController!.value.isPlaying;
      if (playing) {
        _youtubeController!.pause();
        setState(() {
          _showExerciseButton = true;
          _isPlaying = false;
        });
      } else {
        _youtubeController!.play();
        setState(() {
          _showExerciseButton = false;
          _isPlaying = true;
        });
      }
      return;
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return;
    }

    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      setState(() {
        _showExerciseButton = true;
        _isPlaying = false;
      });
    } else {
      _videoController!.play();
      setState(() {
        _showExerciseButton = false;
        _isPlaying = true;
      });
    }
  }

  Future<void> _goToLatihan(BuildContext ctx) async {
    // 1. Pause video dulu
    if (_isYoutube) {
      try {
        _youtubeController?.pause();
      } catch (_) {}
    } else {
      try {
        _videoController?.pause();
      } catch (_) {}
    }

    // 2. Load materi.json dan cari latihan
    Map<String, dynamic>? selected;
    try {
      final jsonString = await rootBundle.loadString('assets/materi.json');
      final List<dynamic> rawList = json.decode(jsonString);

      final List<Map<String, dynamic>> materiList = rawList
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);

      // Gunakan MateriLocalizer untuk cari materi berdasarkan judullatihan
      selected = MateriLocalizer.findByJudulLatihan(
        materiList,
        widget.judullatihan,
      );

      if (selected == null || selected['latihan'] == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.exerciseNotFound ??
                  'Latihan tidak ditemukan di materi.json',
            ),
          ),
        );
        return;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error memuat materi: $e')));
      return;
    }

    if (!mounted) return;

    // 3. Mainkan tirai OUTRO di atas VideoPage (current page)
    await Navigator.of(context).push(
      PngTransisiStageRoute(
        pageUnder: const SizedBox.shrink(), // overlay-only
        backgroundBytes: null,
        pngPattern: 'assets/frames/intro/intro_%04d.png',
        pngFrameCount: 28,
        fps: 24,
        loop: false,
        bufferSize: 8,
        targetDisplayWidth: null,
        targetDisplayHeight: null,
        reverseFrames: true, // main mundur → tirai nutup
        stageStartFrames: 9999, // jangan pernah tampilkan pageUnder
        autoPopOnFinish: true, // tirai selesai → overlay pop
        endFrameDelay: const Duration(milliseconds: 0),
      ),
    );

    if (!mounted) return;

    // 4. Ganti ke halaman quiz TANPA transisi tambahan
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => AljabarQuizPage(
          judullatihan: widget.judullatihan,
          latihan: MateriLocalizer.getLatihan(selected!),
        ),
      ),
    );
  }

  Widget _buildVideoContent(BoxConstraints constraints) {
    // Untuk YouTube
    if (_isYoutube) {
      if (_youtubeController == null) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        );
      }
      return SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: false,
                  progressIndicatorColor: Colors.orange,
                  topActions: const [],
                  bottomActions: const [],
                  bufferIndicator: const SizedBox.shrink(),
                ),
              ),
            ),
            // Gradient overlay untuk hide YouTube UI saat pause
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Stack(
                  children: const [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 140,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF000000),
                              Color(0xE6000000),
                              Color(0x00000000),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 140,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xFF000000),
                              Color(0xE6000000),
                              Color(0x00000000),
                            ],
                          ),
                        ),
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

    // Untuk native video
    if (!_isInitialized || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    final rawSize = _videoController!.value.size;
    final size = (rawSize.width > 0 && rawSize.height > 0)
        ? rawSize
        : Size(constraints.maxWidth, constraints.maxHeight);
    final videoW = size.width;
    final videoH = size.height;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: videoW,
          height: videoH,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 0) BACKGROUND FULLSCREEN DI LUAR SCAFFOLD
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // 1) SCAFFOLD TRANSPARAN DI ATAS BACKGROUND
        Scaffold(
          backgroundColor:
              Colors.transparent, // penting: biar gak nutupin background-nya
          body: Builder(
            builder: (context) {
              // Ambil padding atas untuk menghindari area kamera/notch
              // viewPadding tetap ada nilainya meski dalam immersive mode
              final topPadding = MediaQuery.of(context).viewPadding.top;
              // Fallback minimal 40 jika viewPadding 0 (untuk device tanpa notch)
              final safeTop = topPadding > 0 ? topPadding : 40.0;

              return Stack(
                children: [
                  // Video Area - fullscreen
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _onCenterTapped,
                      child: _buildVideoContent(
                        MediaQuery.of(context).size == Size.zero
                            ? const BoxConstraints.expand()
                            : BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width,
                                maxHeight: MediaQuery.of(context).size.height,
                              ),
                      ),
                    ),
                  ),

                  // Top Bar - hilang saat video jalan, muncul saat pause
                  Positioned(
                    left: 0,
                    right: 0,
                    top: safeTop,
                    child: AnimatedOpacity(
                      opacity: _isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring: _isPlaying,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.edgeToEdge,
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  widget.judulMateri,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 24,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tombol Play (hanya untuk native video saat di-pause)
                  if (!_isYoutube &&
                      _isInitialized &&
                      !_videoController!.value.isPlaying &&
                      !_isNavigatingToQuiz)
                    Center(
                      child: IconButton(
                        iconSize: 96,
                        color: Colors.white,
                        icon: const Icon(Icons.play_circle_fill),
                        onPressed: _onCenterTapped,
                      ),
                    ),

                  // Tombol Exercise (muncul saat pause)
                  if (_showExerciseButton && !_isNavigatingToQuiz)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 80),
                          Text(
                            AppLocalizations.of(context)?.readyToPractice ??
                                'Siap untuk latihan?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black54),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (!_isNavigatingToQuiz) {
                                _isNavigatingToQuiz = true;
                                _goToLatihan(context);
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text(
                              AppLocalizations.of(context)?.exercise ??
                                  'Latihan',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
