import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart'
    show rootBundle, SystemChrome, SystemUiMode;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../pages/aljabar_quiz_page.dart';

class VideoPage extends StatefulWidget {
  final String videoPath; // could be asset path, http(s) mp4 or YouTube URL
  final String judullatihan;

  /// Path asset gambar yang ingin ditampilkan ketika video selesai.
  final String endBackgroundAsset;

  const VideoPage({
    super.key,
    required this.videoPath,
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
  bool _isNetworkMp4 = false;
  bool _isAsset = false;

  bool _showLatihanButton = false;
  bool _isInitialized = false;
  bool _youtubeReady = false;
  bool _endImagePrecached = false;

  /// Menandakan video selesai dan tampilkan gambar akhir.
  bool _showEndImage = false;

  @override
  void initState() {
    super.initState();

    // Fullscreen immersive
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Preload background agar tidak flicker putih
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(AssetImage(widget.endBackgroundAsset), context)
          .then((_) {
            if (!mounted) return;
            setState(() => _endImagePrecached = true);
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() => _endImagePrecached = false);
          });
    });

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
      _isNetworkMp4 = true;
      _videoController = VideoPlayerController.network(path)
        ..initialize().then((_) {
          if (!mounted) return;
          setState(() => _isInitialized = true);
          _videoController?.play();
        });
    } else {
      _isAsset = true;
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

    // Saat video berakhir
    if (value.playerState == PlayerState.ended) {
      if (!_showEndImage || !_showLatihanButton) {
        setState(() {
          _showEndImage = true;
          _showLatihanButton = true;
        });
      }
      try {
        _youtubeController?.pause();
      } catch (_) {}
    }
  }

  void _videoListener() {
    final c = _videoController;
    if (c == null || !c.value.isInitialized) return;

    final position = c.value.position;
    final duration = c.value.duration;

    if (duration != null &&
        position != null &&
        position >= duration - const Duration(milliseconds: 150)) {
      if (c.value.isPlaying) c.pause();
      if (!_showEndImage || !_showLatihanButton) {
        setState(() {
          _showEndImage = true;
          _showLatihanButton = true;
        });
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
        setState(() => _showLatihanButton = true);
      } else {
        _youtubeController!.play();
        setState(() {
          _showLatihanButton = false;
          _showEndImage = false;
        });
      }
      return;
    }

    if (_videoController == null || !_videoController!.value.isInitialized)
      return;

    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
      setState(() => _showLatihanButton = true);
    } else {
      _videoController!.play();
      setState(() {
        _showLatihanButton = false;
        _showEndImage = false;
      });
    }
  }

  Future<void> _goToLatihan(BuildContext context) async {
    if (_isYoutube) {
      try {
        _youtubeController?.pause();
        _youtubeController?.seekTo(const Duration(seconds: 0));
      } catch (_) {}
    } else {
      try {
        _videoController?.pause();
        _videoController?.seekTo(Duration.zero);
      } catch (_) {}
    }

    try {
      final jsonString = await rootBundle.loadString('assets/materi.json');
      final List<dynamic> rawList = json.decode(jsonString);

      final List<Map<String, dynamic>> materiList = rawList
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);

      final selected = materiList.firstWhere(
        (m) => m['judullatihan'] == widget.judullatihan,
        orElse: () => <String, dynamic>{},
      );

      if (selected.isNotEmpty && selected['latihan'] != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AljabarQuizPage(
              judullatihan: widget.judullatihan,
              latihan: selected['latihan'],
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Latihan tidak ditemukan di materi.json'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error memuat materi: $e')));
    }
  }

  Widget _buildVideoContent(BoxConstraints constraints) {
    // Tampilkan gambar akhir jika sudah selesai
    if (_showEndImage) {
      if (!_endImagePrecached) {
        return const SizedBox.expand(
          child: DecoratedBox(decoration: BoxDecoration(color: Colors.black)),
        );
      }

      return SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              image: AssetImage(widget.endBackgroundAsset),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    // Untuk YouTube
    if (_isYoutube) {
      if (_youtubeController == null) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        );
      }
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: false,
              progressIndicatorColor: Colors.orange,
            ),
          ),
        ),
      );
    }

    // Untuk native video
    if (!_isInitialized || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    final size =
        _videoController!.value.size ??
        Size(constraints.maxWidth, constraints.maxHeight);
    final videoW = size.width <= 0 ? constraints.maxWidth : size.width;
    final videoH = size.height <= 0 ? constraints.maxHeight : size.height;

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video Area
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

            // Top Bar
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: AppBar(
                backgroundColor: Colors.black.withOpacity(0.35),
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  widget.judullatihan,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            // Tombol Play (hanya untuk native video)
            if (!_isYoutube &&
                _isInitialized &&
                !_videoController!.value.isPlaying &&
                !_showEndImage)
              Center(
                child: IconButton(
                  iconSize: 96,
                  color: Colors.white,
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: _onCenterTapped,
                ),
              ),

            // Tombol Latihan
            if (_showLatihanButton)
              Positioned.fill(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Siap untuk latihan?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _goToLatihan(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Latihan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
    );
  }
}
