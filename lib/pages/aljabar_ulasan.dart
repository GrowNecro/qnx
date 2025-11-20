// lib/pages/aljabar_ulasan.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class AljabarUlasan extends StatefulWidget {
  const AljabarUlasan({super.key});

  @override
  State<AljabarUlasan> createState() => _AljabarUlasanState();
}

class _AljabarUlasanState extends State<AljabarUlasan> {
  List<dynamic> materiList = [];

  @override
  void initState() {
    super.initState();
    _loadMateri();
  }

  Future<void> _loadMateri() async {
    final data = await rootBundle.loadString('assets/materi.json');
    setState(() {
      materiList = json.decode(data);
    });
  }

  /// Ambil jawaban user (image & teks) per judullatihan
  Future<Map<String, String>> _getUserAnswer(String judullatihan) async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('userImagePath_$judullatihan') ?? '';
    final text = prefs.getString('userText_$judullatihan') ?? '';
    return {'image': imagePath, 'text': text};
  }

  /// Cek apakah user punya jawaban teks atau gambar (minimal salah satu)
  bool _hasAnyAnswer(String? imagePath, String? text) {
    final hasText = text != null && text.trim().isNotEmpty;

    final hasImage =
        imagePath != null &&
        imagePath.trim().isNotEmpty &&
        File(imagePath).existsSync();

    return hasText || hasImage;
  }

  Widget _buildUserImage(String imagePath) {
    if (imagePath.trim().isNotEmpty && File(imagePath).existsSync()) {
      return Image.file(File(imagePath), fit: BoxFit.contain);
    }
    return const Icon(
      Icons.image_not_supported,
      size: 100,
      color: Colors.white30,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text(
                    'Review: Algebra',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30,
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
                  child: materiList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: materiList.length,
                          itemBuilder: (context, index) {
                            final materi = materiList[index];
                            final nomor = index + 1;

                            return FutureBuilder<Map<String, String>>(
                              future: _getUserAnswer(materi['judullatihan']),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox.shrink();
                                }

                                final userAnswer = snapshot.data!;
                                final userImg = userAnswer['image'] ?? '';
                                final userTxt = userAnswer['text'] ?? '';

                                // ❗ Filter: hanya tampilkan kalau ada jawaban teks / gambar
                                final allowed = _hasAnyAnswer(userImg, userTxt);

                                if (!allowed) {
                                  // Tidak ada jawaban sama sekali → tidak ditampilkan
                                  return const SizedBox.shrink();
                                }

                                return Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: screenWidth * 0.9,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // NOMOR + JUDUL
                                        Center(
                                          child: Text(
                                            '$nomor. ${materi['judullatihan']}',
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 20),

                                        // Soal Latihan
                                        const Text(
                                          'Exercise Question:',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          materi['latihan'] ??
                                              'Exercise question not available.',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Jawaban User (Teks)
                                        const Text(
                                          'Your Answer (Text):',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          userTxt.isEmpty
                                              ? '(No text answer provided)'
                                              : userTxt,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Jawaban User (Gambar)
                                        const Text(
                                          'Your Answer (Image):',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Center(child: _buildUserImage(userImg)),

                                        const SizedBox(height: 24),

                                        // Jawaban Sistem (Teks)
                                        const Text(
                                          'System Answer (Text):',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          materi['jawabansistemteks'] ??
                                              'No system text available.',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Jawaban Sistem (Langkah / Gambar)
                                        const Text(
                                          'System Answer (Step):',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (materi['jawabansistempng'] != null)
                                          Center(
                                            child: Image.asset(
                                              materi['jawabansistempng'],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
