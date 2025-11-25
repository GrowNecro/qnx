// lib/pages/aljabar_quiz_page.dart
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class AljabarQuizPage extends StatefulWidget {
  final String judullatihan;
  final String latihan;
  final bool forPreview;

  const AljabarQuizPage({
    super.key,
    required this.judullatihan,
    required this.latihan,
    this.forPreview = false,
  });

  static Widget previewWithMediaQuery(
    MediaQueryData mq,
    String judul,
    String latihanText,
  ) {
    return MediaQuery(
      data: mq,
      child: Material(
        type: MaterialType.transparency,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: AljabarQuizPage(
              judullatihan: judul,
              latihan: latihanText,
              forPreview: true,
            ),
          ),
        ),
      ),
    );
  }

  @override
  State<AljabarQuizPage> createState() => _AljabarQuizPageState();
}

class _AljabarQuizPageState extends State<AljabarQuizPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();

  /// Flag untuk tahu apakah ini materi terakhir
  bool _isLastMateri = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAnswer();
    _checkIfLastMateri();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('userImagePath_${widget.judullatihan}');
    final text = prefs.getString('userText_${widget.judullatihan}');
    setState(() {
      if (path != null && File(path).existsSync()) {
        _image = File(path);
      }
      if (text != null) {
        _controller.text = text;
      }
    });
  }

  /// Cek sekali di awal: apakah judullatihan ini adalah materi terakhir?
  Future<void> _checkIfLastMateri() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/materi.json',
      );
      final List<dynamic> materiList = json.decode(jsonString);

      dynamic currentMateri;
      try {
        currentMateri = materiList.firstWhere(
          (m) => m['judullatihan'] == widget.judullatihan,
        );
      } catch (_) {
        currentMateri = null;
      }

      if (currentMateri == null) return;

      final int? currentId = currentMateri['id'] is int
          ? currentMateri['id'] as int
          : int.tryParse(currentMateri['id'].toString());

      if (currentId == null) return;

      // Cek apakah ada materi dengan id = currentId + 1
      bool hasNext = false;
      for (final m in materiList) {
        final mid = m['id'] is int
            ? m['id'] as int
            : int.tryParse(m['id'].toString()) ?? -1;
        if (mid == currentId + 1) {
          hasNext = true;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _isLastMateri = !hasNext;
        });
      }
    } catch (_) {
      // kalau error, biarkan default false (anggap bukan terakhir)
    }
  }

  List<InlineSpan> parseMathText(String text) {
    final List<InlineSpan> spans = [];
    int start = 0;
    final powerRegex = RegExp(r'(\d+)\^(\d+)');
    for (final match in powerRegex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(text: match.group(1)));
      spans.add(
        WidgetSpan(
          child: Transform.translate(
            offset: const Offset(0, -7),
            child: Text(
              match.group(2)!,
              textScaler: const TextScaler.linear(0.7),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return spans;
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _openFullImage() {
    if (_image == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(child: InteractiveViewer(child: Image.file(_image!))),
        ),
      ),
    );
  }

  Future<void> _saveJawabanAndNext() async {
    if (_image == null && _controller.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jawaban kosong!')));
      return;
    }

    // Simpan jawaban
    final prefs = await SharedPreferences.getInstance();
    if (_image != null) {
      await prefs.setString(
        'userImagePath_${widget.judullatihan}',
        _image!.path,
      );
    }
    await prefs.setString('userText_${widget.judullatihan}', _controller.text);

    // Ambil materi.json
    final String jsonString = await rootBundle.loadString('assets/materi.json');
    final List<dynamic> materiList = json.decode(jsonString);

    // Materi sekarang
    dynamic currentMateri;
    try {
      currentMateri = materiList.firstWhere(
        (m) => m['judullatihan'] == widget.judullatihan,
      );
    } catch (_) {
      currentMateri = null;
    }

    if (currentMateri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Materi tidak ditemukan')));
      return;
    }

    final int? currentId = currentMateri['id'] is int
        ? currentMateri['id'] as int
        : int.tryParse(currentMateri['id'].toString());

    if (currentId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID materi tidak valid')));
      return;
    }

    // Cari materi id berikutnya
    dynamic nextMateri;
    try {
      nextMateri = materiList.firstWhere((m) {
        final mid = m['id'] is int
            ? m['id'] as int
            : int.tryParse(m['id'].toString()) ?? -1;
        return mid == currentId + 1;
      });
    } catch (_) {
      nextMateri = null;
    }

    // Jika ini materi terakhir (tidak ada nextMateri) → ke HOME
    if (nextMateri == null || _isLastMateri) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selamat, semua materi sudah selesai!')),
        );
        // pergi ke home dan buang semua route sebelumnya, via AppRoutes + transisi
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
          arguments: {
            'transisi':
                'transisi2', // biar tetap pakai PNG transition dari AppRoutes
          },
        );
      }
      return;
    }

    // Ambil data untuk materi/video berikutnya
    final String nextVideoPath = nextMateri['video']?.toString() ?? '';
    final String nextJudulLatihan =
        nextMateri['judullatihan']?.toString() ?? 'Latihan';

    // Pindah ke halaman video materi berikutnya via AppRoutes + transisi
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/materi/video',
      arguments: {
        'videoPath': nextVideoPath,
        'judulMateri': nextMateri['judul']?.toString() ?? '',
        'judullatihan': nextJudulLatihan,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // biar background bisa sampai belakang appbar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.judullatihan,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // === BACKGROUND ===
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // === KONTEN ===
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.8,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.25,
                            child: SingleChildScrollView(
                              child: RichText(
                                textAlign: TextAlign.justify,
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: parseMathText(widget.latihan),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _image == null && _controller.text.isEmpty
                                ? const Center(
                                    child: Text(
                                      'Belum ada foto jawaban',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Stack(
                                    children: [
                                      // Gambar jawaban atau text area
                                      if (_image != null)
                                        Positioned.fill(
                                          child: GestureDetector(
                                            onTap: _openFullImage,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                _image!,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        const Center(
                                          child: Text(
                                            'Jawaban teks sudah disimpan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      // Maskot di tengah jika ada jawaban (gambar atau teks)
                                      if (_image != null ||
                                          _controller.text.isNotEmpty)
                                        Positioned(
                                          right: 8,
                                          bottom: 0,
                                          child: Image.asset(
                                            'assets/images/maskot.png',
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: 'Tulis jawaban teks kamu di sini',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.black26,
                            ),
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.forPreview ? null : _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.forPreview
                              ? null
                              : _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galeri'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.forPreview
                              ? null
                              : _saveJawabanAndNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            _isLastMateri ? 'Selesai' : 'Next',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
