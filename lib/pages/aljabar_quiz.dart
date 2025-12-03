import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/materi_localizer.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show routeObserver;

class AljabarQuiz extends StatefulWidget {
  const AljabarQuiz({super.key});

  @override
  State<AljabarQuiz> createState() => _AljabarQuizState();
}

class _AljabarQuizState extends State<AljabarQuiz> with RouteAware {
  List<dynamic> materiList = [];
  // Map untuk menyimpan status quiz sudah dikerjakan atau belum per judullatihan
  Map<String, bool> quizCompletedMap = {};
  bool _isLoading = true;

  Future<void> loadMateri() async {
    final data = await rootBundle.loadString('assets/materi.json');
    final List<dynamic> list = json.decode(data);

    // Load status quiz dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final Map<String, bool> completedMap = {};

    for (final materi in list) {
      // Use the raw judullatihan for key lookup (combine en+id or use id field)
      final rawJudullatihan = materi['judullatihan'];
      String judullatihan = '';
      if (rawJudullatihan is String) {
        judullatihan = rawJudullatihan;
      } else if (rawJudullatihan is Map) {
        // Use English as the key identifier
        judullatihan = rawJudullatihan['en']?.toString() ?? '';
      }
      if (judullatihan.isNotEmpty) {
        // Cek apakah ada jawaban tersimpan (gambar atau teks)
        final imagePath = prefs.getString('userImagePath_$judullatihan');
        final text = prefs.getString('userText_$judullatihan');
        completedMap[judullatihan] =
            (imagePath != null && imagePath.isNotEmpty) ||
            (text != null && text.isNotEmpty);
      }
    }

    if (!mounted) return;
    setState(() {
      materiList = list;
      quizCompletedMap = completedMap;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadMateri();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refresh when returning from quiz page
    loadMateri();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Konten utama
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    loc?.quizAlgebra ?? 'Quiz: Algebra',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  centerTitle: true,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // List quiz
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: materiList.length,
                          itemBuilder: (context, index) {
                            final materi =
                                materiList[index] as Map<String, dynamic>;
                            // Get localized texts
                            final judulLatihan =
                                MateriLocalizer.getJudulLatihan(materi);
                            final latihan = MateriLocalizer.getLatihan(materi);
                            // Use English judullatihan as key for storage
                            final rawJudullatihan = materi['judullatihan'];
                            String judullatihanKey = '';
                            if (rawJudullatihan is String) {
                              judullatihanKey = rawJudullatihan;
                            } else if (rawJudullatihan is Map) {
                              judullatihanKey =
                                  rawJudullatihan['en']?.toString() ?? '';
                            }
                            final isCompleted =
                                quizCompletedMap[judullatihanKey] ?? false;

                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(
                                  context,
                                  '/quiz/page',
                                  arguments: {
                                    'judullatihan': judullatihanKey,
                                    'latihan': latihan.isNotEmpty
                                        ? latihan
                                        : loc?.exerciseNotYetAvailable ??
                                              'Latihan belum tersedia',
                                  },
                                );
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: screenWidth * 0.9,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(0),
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200.withValues(
                                      alpha: 0.75,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Judul latihan
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 20,
                                          top: 20,
                                          right: 20,
                                          left: 20,
                                        ),
                                        child: Text(
                                          judulLatihan,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      // Level icons di kanan atas
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(
                                            (materi['level'] ?? 1) as int,
                                            (i) => Container(
                                              margin: const EdgeInsets.all(5),
                                              width: 35,
                                              height: 35,
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
                                      // Maskot di kanan bawah jika quiz sudah dikerjakan
                                      if (isCompleted)
                                        Align(
                                          alignment: Alignment.bottomRight,
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
