import 'dart:io';
import 'package:flutter/material.dart';

class AljabarUlasanPage extends StatelessWidget {
  final String judullatihan;
  final String latihan;
  final String jawabansistempng;
  final String jawabansistemteks;
  final String jawabanuser;
  final String jawabanuserpng;
  final bool forPreview;

  const AljabarUlasanPage({
    super.key,
    required this.judullatihan,
    required this.latihan,
    required this.jawabansistempng,
    required this.jawabansistemteks,
    required this.jawabanuser,
    required this.jawabanuserpng,
    this.forPreview = false,
  });

  static Widget previewWithMediaQuery(
    MediaQueryData mq, {
    required String judul,
    required String latihan,
    required String jawabansistempng,
    required String jawabansistemteks,
    required String jawabanuser,
    required String jawabanuserpng,
  }) {
    return MediaQuery(
      data: mq,
      child: Material(
        type: MaterialType.transparency,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: AljabarUlasanPage(
              judullatihan: judul,
              latihan: latihan,
              jawabansistempng: jawabansistempng,
              jawabansistemteks: jawabansistemteks,
              jawabanuser: jawabanuser,
              jawabanuserpng: jawabanuserpng,
              forPreview: true,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                    'Ulasan: $judullatihan',
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
                      height: screenHeight * 0.9,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Soal Latihan',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              latihan,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Jawaban Kamu (Teks):',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              jawabanuser,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Jawaban Sistem (Teks):',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              jawabansistemteks,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Jawaban Sistem (Langkah):',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Image.asset(jawabansistempng, fit: BoxFit.contain),
                            const SizedBox(height: 24),
                            const Text(
                              'Jawaban Kamu (Langkah):',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildUserImage(),
                          ],
                        ),
                      ),
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

  Widget _buildUserImage() {
    if (jawabanuserpng.isNotEmpty && File(jawabanuserpng).existsSync()) {
      return Image.file(File(jawabanuserpng), fit: BoxFit.contain);
    } else {
      // fallback jika path invalid
      return const Icon(
        Icons.image_not_supported,
        size: 100,
        color: Colors.white30,
      );
    }
  }
}
