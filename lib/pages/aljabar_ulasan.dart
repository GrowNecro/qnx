// import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'aljabar_ulasan_page.dart';

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

  // Ambil jawaban user (image & teks) per judullatihan
  Future<Map<String, String>> _getUserAnswer(String judullatihan) async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath =
        prefs.getString('userImagePath_$judullatihan') ??
        'assets/images/default.png';
    final text =
        prefs.getString('userText_$judullatihan') ?? 'Belum ada jawaban.';
    return {'image': imagePath, 'text': text};
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
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar transparan
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text(
                    'Ulasan: Aljabar',
                    style: TextStyle(
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
                // Konten utama
                Expanded(
                  child: materiList.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: materiList.length,
                          itemBuilder: (context, index) {
                            final materi = materiList[index];
                            return FutureBuilder<Map<String, String>>(
                              future: _getUserAnswer(materi['judullatihan']),
                              builder: (context, snapshot) {
                                final userAnswer =
                                    snapshot.data ??
                                    {
                                      'image': 'assets/images/default.png',
                                      'text': 'Belum ada jawaban.',
                                    };
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AljabarUlasanPage(
                                          judullatihan: materi['judullatihan'],
                                          latihan: materi['latihan'],
                                          jawabansistempng:
                                              materi['jawabansistempng'] ??
                                              'assets/images/default.png',
                                          jawabansistemteks:
                                              materi['jawabansistemteks'] ??
                                              'Tidak ada teks sistem.',
                                          jawabanuser: userAnswer['text']!,
                                          jawabanuserpng: userAnswer['image']!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: screenWidth * 0.9,
                                      margin: const EdgeInsets.only(bottom: 20),
                                      padding: const EdgeInsets.all(16),
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              bottom: 10,
                                            ),
                                            child: Text(
                                              materi['judullatihan'] ??
                                                  'Judul kosong',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: List.generate(
                                                materi['level'] ?? 1,
                                                (i) => Container(
                                                  margin: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  width: 40,
                                                  height: 40,
                                                  decoration: const BoxDecoration(
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                        'assets/images/level.png',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
