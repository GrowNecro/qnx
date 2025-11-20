import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late VideoPlayerController _bgController;
  bool _isBgReady = false;

  @override
  void initState() {
    super.initState();

    // Jika pakai asset:
    _bgController = VideoPlayerController.asset('assets/videos/video_home.mp4')
      ..initialize().then((_) {
        // Pastikan mounted sebelum setState
        if (!mounted) return;
        setState(() {
          _isBgReady = true;
        });
        _bgController
          ..setLooping(true)
          ..setVolume(0) // mute background
          ..play();
      });

    // Jika pakai network, ganti dengan:
    // _bgController = VideoPlayerController.network('https://....mp4') ...
  }

  @override
  void dispose() {
    _bgController.pause();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Video background (fill, cover)
          Positioned.fill(
            child: _isBgReady
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _bgController.value.size.width,
                      height: _bgController.value.size.height,
                      child: VideoPlayer(_bgController),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          ),

          // Optional overlay untuk memberikan efek gelap agar teks terbaca
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          // Konten (ikon + tombol)
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode
                          .srcATop,
                    ),
                    child: Image.asset(
                      'assets/images/sugeng_rawuh.png',
                      width: screenWidth * 0.75,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _menuButton(context, 'Learning Materials', '/materi'),
                  const SizedBox(height: 20),
                  _menuButton(context, 'Questions', '/quiz'),
                  const SizedBox(height: 20),
                  _menuButton(context, 'Reviews', '/ulasan'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(BuildContext context, String text, String route) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.9,
      height: 120,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
        ),
      ),
    );
  }
}
