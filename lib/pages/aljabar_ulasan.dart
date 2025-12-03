// lib/pages/aljabar_ulasan.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/materi_localizer.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show routeObserver;

class AljabarUlasan extends StatefulWidget {
  const AljabarUlasan({super.key});

  @override
  State<AljabarUlasan> createState() => _AljabarUlasanState();
}

class _AljabarUlasanState extends State<AljabarUlasan> with RouteAware {
  List<dynamic> materiList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMateri();
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
    // Refresh when returning
    _loadMateri();
  }

  Future<void> _loadMateri() async {
    final data = await rootBundle.loadString('assets/materi.json');
    if (!mounted) return;
    setState(() {
      materiList = json.decode(data);
      _isLoading = false;
    });
  }

  /// Ambil jawaban user (image & teks) per judullatihan
  /// Try both EN and ID versions to find existing answer
  Future<Map<String, String>> _getUserAnswer(
    Map<String, dynamic> materi,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get all possible keys to check
    final judulLatihanField = materi['judullatihan'];
    List<String> keysToCheck = [];

    if (judulLatihanField is String) {
      keysToCheck.add(judulLatihanField);
    } else if (judulLatihanField is Map) {
      if (judulLatihanField['en'] != null)
        keysToCheck.add(judulLatihanField['en']);
      if (judulLatihanField['id'] != null)
        keysToCheck.add(judulLatihanField['id']);
    }

    String imagePath = '';
    String text = '';

    // Check each key for saved answers
    for (final key in keysToCheck) {
      final savedImage = prefs.getString('userImagePath_$key') ?? '';
      final savedText = prefs.getString('userText_$key') ?? '';

      if (savedImage.isNotEmpty || savedText.isNotEmpty) {
        imagePath = savedImage;
        text = savedText;
        break;
      }
    }
    
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
    final loc = AppLocalizations.of(context);

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
                  title: Text(
                    loc?.reviewAlgebra ?? 'Review: Algebra',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  centerTitle: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(height: 20),

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
                            final nomor = index + 1;
                            final judulLatihan =
                                MateriLocalizer.getJudulLatihan(materi);
                            final latihan = MateriLocalizer.getLatihan(materi);
                            final jawabanSistem =
                                MateriLocalizer.getJawabanSistem(materi);

                            return FutureBuilder<Map<String, String>>(
                              future: _getUserAnswer(materi),
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
                                      color: Colors.black.withValues(
                                        alpha: 0.65,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.4,
                                          ),
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
                                            '$nomor. $judulLatihan',
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
                                        Text(
                                          loc?.exerciseQuestion ??
                                              'Exercise Question:',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          latihan.isEmpty
                                              ? loc?.exerciseNotAvailable ??
                                                    'Exercise question not available.'
                                              : latihan,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Jawaban User (Teks)
                                        Text(
                                          loc?.yourAnswerText ??
                                              'Your Answer (Text):',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          userTxt.isEmpty
                                              ? loc?.noTextAnswerProvided ??
                                                    '(No text answer provided)'
                                              : userTxt,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Jawaban User (Gambar)
                                        Text(
                                          loc?.yourAnswerImage ??
                                              'Your Answer (Image):',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Center(child: _buildUserImage(userImg)),

                                        const SizedBox(height: 24),

                                        // Jawaban Sistem (Teks)
                                        Text(
                                          loc?.systemAnswerText ??
                                              'System Answer (Text):',
                                          style: const TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          jawabanSistem.isEmpty
                                              ? loc?.noSystemTextAvailable ??
                                                    'No system text available.'
                                              : jawabanSistem,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // Jawaban Sistem (Langkah / Gambar)
                                        Text(
                                          loc?.systemAnswerStep ??
                                              'System Answer (Step):',
                                          style: const TextStyle(
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
