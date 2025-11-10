import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'aljabar_ulasan_page.dart';

class JawabanPage extends StatefulWidget {
  final String judullatihan;

  const JawabanPage({super.key, required this.judullatihan});

  @override
  State<JawabanPage> createState() => _JawabanPageState();
}

class _JawabanPageState extends State<JawabanPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedAnswer();
  }

  // Ambil jawaban user jika sudah tersimpan
  Future<void> _loadSavedAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('userImagePath_${widget.judullatihan}');
    final text = prefs.getString('userText_${widget.judullatihan}');
    setState(() {
      if (path != null && File(path).existsSync()) _image = File(path);
      if (text != null) _controller.text = text;
    });
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _pickFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _saveJawaban() async {
    if (_image == null && _controller.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Jawaban kosong!')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    if (_image != null) {
      await prefs.setString(
        'userImagePath_${widget.judullatihan}',
        _image!.path,
      );
    }
    await prefs.setString('userText_${widget.judullatihan}', _controller.text);

    // Ambil data dari assets
    final String jsonString = await rootBundle.loadString('assets/materi.json');
    final List<dynamic> materiList = json.decode(jsonString);

    // Cari materi sesuai judul latihan
    final materi = materiList.firstWhere(
      (m) => m['judullatihan'] == widget.judullatihan,
      orElse: () => null,
    );

    if (materi == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Materi tidak ditemukan')));
      return;
    }

    final String jawabansistempng =
        materi['jawabansistempng'] ?? 'assets/images/default.png';
    final String jawabansistemteks =
        materi['jawabansistemteks'] ?? 'Tidak ada teks sistem.';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AljabarUlasanPage(
          judullatihan: widget.judullatihan,
          latihan: materi['latihan'] ?? {},
          jawabansistempng: jawabansistempng,
          jawabansistemteks: jawabansistemteks,
          jawabanuser: _controller.text.isEmpty
              ? 'Belum ada jawaban teks.'
              : _controller.text,
          jawabanuserpng: _image?.path ?? 'assets/images/default.png',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    'Jawaban: ${widget.judullatihan}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenWidth * 1.8,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: _image == null
                                ? const Center(
                                    child: Text(
                                      'Belum ada foto',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _image!,
                                      fit: BoxFit.contain,
                                    ),
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
                            maxLines: null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: _pickFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveJawaban,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Jawaban',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
