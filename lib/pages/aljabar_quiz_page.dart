import 'package:flutter/material.dart';

class AljabarQuizPage extends StatelessWidget {
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

  // Fungsi parse pangkat (^)
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
              textScaleFactor: 0.7,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // SafeArea untuk konten
          SafeArea(
            child: Column(
              children: [
                // AppBar transparan dalam Column
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: Text(
                    judullatihan,
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

                // Kotak soal (di tengah horizontal)
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.55,
                      padding: const EdgeInsets.all(24),
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
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            children: parseMathText(latihan),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol Jawab Latihan
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/quiz/jawaban',
                        arguments: {'judullatihan': judullatihan},
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Jawab Latihan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
}
