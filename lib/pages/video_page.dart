import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:flutter/services.dart'
    show rootBundle, SystemChrome, SystemUiMode;
import '../pages/aljabar_quiz_page.dart';

class VideoPage extends StatefulWidget {
  final String videoPath;
  final String judullatihan;

  const VideoPage({
    super.key,
    required this.videoPath,
    required this.judullatihan,
  });

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  bool _showLatihanButton = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Masuk ke mode fullscreen immersive
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      });

    // Listener untuk mendeteksi akhir video dan perubahan status
    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!_controller.value.isInitialized) return;

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    // jika duration ada dan posisi hampir sama dengan durasi -> selesai
    if (duration != null &&
        position != null &&
        position >= duration - const Duration(milliseconds: 200)) {
      if (!_showLatihanButton) {
        setState(() {
          _showLatihanButton = true;
        });
      }
    }

    // Jika video dipause oleh user (bukan karena end), kita tidak otomatis show
    // kecuali kita setnya di onTap (di bagian UI)
  }

  @override
  void dispose() {
    // Kembalikan UI mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _onCenterTapped() {
    if (!_controller.value.isInitialized) return;

    if (_controller.value.isPlaying) {
      // Jika sedang playing: pause dan tunjukkan tombol latihan
      setState(() {
        _controller.pause();
        _showLatihanButton = true;
      });
    } else {
      // Jika sedang pause: play dan sembunyikan tombol latihan
      setState(() {
        _controller.play();
        _showLatihanButton = false;
      });
    }
  }

  Future<void> _goToLatihan(BuildContext context) async {
    // Hentikan video dulu dan kembalikan ke awal
    _controller.pause();
    _controller.seekTo(Duration.zero);

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/materi.json',
      );
      final List<dynamic> materiList = json.decode(jsonString);

      final selected = materiList.firstWhere(
        (m) => m['judullatihan'] == widget.judullatihan,
        orElse: () => null,
      );

      if (selected != null && selected['latihan'] != null) {
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

  @override
  Widget build(BuildContext context) {
    // Fullscreen layout: gunakan Stack penuh
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        // SafeArea tetap agar tombol nav / area system tidak tertimpa
        child: Stack(
          children: [
            // Video mengambil seluruh ruang
            Positioned.fill(
              child: _isInitialized
                  ? GestureDetector(
                      onTap: _onCenterTapped,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width:
                              _controller.value.size?.width ??
                              MediaQuery.of(context).size.width,
                          height:
                              _controller.value.size?.height ??
                              MediaQuery.of(context).size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
            ),

            // Top bar transparan (kembali + judul) — tampil di atas video
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: AppBar(
                backgroundColor: Colors.black.withOpacity(0.35),
                elevation: 0,
                title: Text(
                  widget.judullatihan,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // restore UI mode & pop
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            // Center play icon (besar) — hanya ikon, ketuk anywhere untuk toggle
            if (_isInitialized && !_controller.value.isPlaying)
              Center(
                child: IconButton(
                  iconSize: 96,
                  color: Colors.white,
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: _onCenterTapped,
                ),
              ),

            // Tombol latihan overlay (muncul saat _showLatihanButton == true)
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
                      // Optional teks kecil
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
