import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AljabarQuiz extends StatefulWidget {
  const AljabarQuiz({super.key});

  @override
  State<AljabarQuiz> createState() => _AljabarQuizState();
}

class _AljabarQuizState extends State<AljabarQuiz> {
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
              'assets/images/background.jpg', // sesuaikan nama file
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  // Transparent AppBar (dalam Column, seperti QuizPage)
                  AppBar(
                    backgroundColor: Colors.transparent,
                    title: const Text(
                      'Quiz: Aljabar',
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

                  // Isi konten (list)
                  Expanded(
                    child: materiList.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: materiList.length,
                            itemBuilder: (context, index) {
                              final materi = materiList[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/quiz/page',
                                    arguments: {
                                      'judullatihan':
                                          materi['judullatihan'] ??
                                          'Judul tidak tersedia',
                                      'latihan':
                                          materi['latihan'] ??
                                          'Latihan belum tersedia',
                                    },
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
                                          color: Colors.black.withOpacity(0.2),
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
          ),
        ],
      ),
    );
  }
}
