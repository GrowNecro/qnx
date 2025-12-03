import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

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
                    title: Text(
                      loc?.questions ?? 'Questions',
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
                  const SizedBox(height: 30),
                  _menuButton(
                    context,
                    loc?.algebra ?? 'Algebra',
                    '/quiz/aljabar',
                    screenWidth,
                  ),
                  const SizedBox(height: 20),
                  _menuButton(
                    context,
                    loc?.comingSoon ?? 'COMING SOON',
                    null,
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
    String? route,
    double screenWidth,
  ) {
    final isDisabled = route == null;
    
    return SizedBox(
      width: screenWidth * 0.9, // 90% lebar layar
      height: 120,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, route);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(
            alpha: isDisabled ? 0.4 : 0.7,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: isDisabled ? 0 : 3,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.4),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDisabled ? Colors.grey[600] : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
