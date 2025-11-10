import 'package:flutter/material.dart';

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background foto
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/background.jpg',
                ), // ganti path sesuai foto
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Konten di atas background
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    title: const Text(
                      'MATERI',
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
                  const SizedBox(height: 30),
                  _menuButton(
                    context,
                    'Aljabar',
                    '/materi/aljabar',
                    screenWidth,
                  ),
                  const SizedBox(height: 20),
                  _menuButton(
                    context,
                    'COMING SOON',
                    'null',
                    screenWidth,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(
    BuildContext context,
    String text,
    String route,
    double screenWidth,
  ) {
    return SizedBox(
      width: screenWidth * 0.95, // 95% lebar layar
      height: 120,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(
            0.9,
          ), // biar sedikit transparan
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
