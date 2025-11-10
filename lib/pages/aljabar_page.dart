import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AljabarPage extends StatefulWidget {
  const AljabarPage({super.key});

  @override
  State<AljabarPage> createState() => _AljabarPageState();
}

class _AljabarPageState extends State<AljabarPage> {
  List<dynamic> materiList = [];

  Future<void> loadMateri() async {
    final data = await rootBundle.loadString('assets/materi.json');
    setState(() {
      materiList = json.decode(data);
    });
  }

  @override
  void initState() {
    super.initState();
    loadMateri();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.jpg', // ganti sesuai path gambar
              fit: BoxFit.cover,
            ),
          ),

          // Konten utama
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent, // transparan
                  elevation: 0,
                  title: const Text(
                    'Materi: Aljabar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // List materi
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: materiList.length,
                    itemBuilder: (context, index) {
                      final materi = materiList[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/materi/video',
                            arguments: {
                              'videoPath': materi['video'],
                              'judullatihan': materi['judullatihan'],
                            },
                          );
                        },
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: screenWidth * 0.95,
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200.withOpacity(
                                0.8,
                              ), // semi-transparent
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 10,
                                    top: 10,
                                  ),
                                  child: Text(
                                    materi['judul'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      materi['level'],
                                      (i) => Container(
                                        margin: const EdgeInsets.all(4),
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
