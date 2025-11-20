import 'package:flutter/material.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png', // sesuaikan nama file background
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    title: const Text(
                      'Questions',
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
                  const SizedBox(height: 30),
                  _menuButton(
                    context,
                    'Algebra',
                    '/quiz/aljabar',
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
      width: screenWidth * 0.9, // 90% lebar layar
      height: 120,
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.7),
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
            fontSize: 30,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
