import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          loc?.help ?? 'Bantuan',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
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
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Welcome Section
                  _buildSection(
                    icon: Icons.waving_hand,
                    title: loc?.welcomeToApp ?? 'Selamat Datang di QNX!',
                    content: loc?.welcomeDescription ?? 
                        'QNX (Questions and X) adalah aplikasi pembelajaran matematika interaktif yang membantu kamu belajar Aljabar dengan cara yang menyenangkan.',
                    screenWidth: screenWidth,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // How to Use Section
                  _buildSection(
                    icon: Icons.play_circle_outline,
                    title: loc?.howToUse ?? 'Cara Menggunakan',
                    content: '',
                    screenWidth: screenWidth,
                    child: Column(
                      children: [
                        _buildStep(
                          number: '1',
                          title: loc?.step1Title ?? 'Pilih Materi',
                          description: loc?.step1Desc ?? 
                              'Tekan tombol "Materi Pembelajaran" di halaman utama, lalu pilih topik yang ingin dipelajari.',
                        ),
                        _buildStep(
                          number: '2',
                          title: loc?.step2Title ?? 'Tonton Video',
                          description: loc?.step2Desc ?? 
                              'Pelajari materi melalui video pembelajaran. Video akan otomatis lanjut ke quiz setelah selesai.',
                        ),
                        _buildStep(
                          number: '3',
                          title: loc?.step3Title ?? 'Kerjakan Quiz',
                          description: loc?.step3Desc ?? 
                              'Jawab soal latihan dengan foto (kamera/galeri) atau ketik jawabanmu. Jawaban akan tersimpan otomatis.',
                        ),
                        _buildStep(
                          number: '4',
                          title: loc?.step4Title ?? 'Lihat Ulasan',
                          description: loc?.step4Desc ?? 
                              'Bandingkan jawabanmu dengan jawaban sistem di menu "Ulasan" untuk evaluasi.',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Features Section
                  _buildSection(
                    icon: Icons.star_outline,
                    title: loc?.features ?? 'Fitur Aplikasi',
                    content: '',
                    screenWidth: screenWidth,
                    child: Column(
                      children: [
                        _buildFeature(
                          icon: Icons.menu_book,
                          title: loc?.learningMaterials ?? 'Materi Pembelajaran',
                          description: loc?.materialsDesc ?? 
                              'Video pembelajaran Aljabar yang mudah dipahami.',
                        ),
                        _buildFeature(
                          icon: Icons.quiz,
                          title: loc?.questions ?? 'Soal Latihan',
                          description: loc?.questionsDesc ?? 
                              'Quiz interaktif dengan input foto atau teks.',
                        ),
                        _buildFeature(
                          icon: Icons.rate_review,
                          title: loc?.reviews ?? 'Ulasan',
                          description: loc?.reviewsDesc ?? 
                              'Bandingkan jawabanmu dengan jawaban yang benar.',
                        ),
                        _buildFeature(
                          icon: Icons.language,
                          title: loc?.language ?? 'Bahasa',
                          description: loc?.languageDesc ?? 
                              'Tersedia dalam Bahasa Indonesia dan English.',
                        ),
                        _buildFeature(
                          icon: Icons.save,
                          title: loc?.autoSave ?? 'Auto-Save',
                          description: loc?.autoSaveDesc ?? 
                              'Jawaban tersimpan otomatis, tidak perlu takut hilang.',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Settings Section
                  _buildSection(
                    icon: Icons.settings,
                    title: loc?.settingsGuide ?? 'Pengaturan',
                    content: '',
                    screenWidth: screenWidth,
                    child: Column(
                      children: [
                        _buildFeature(
                          icon: Icons.brightness_6,
                          title: loc?.brightness ?? 'Kecerahan',
                          description: loc?.brightnessDesc ?? 
                              'Atur kecerahan layar sesuai kenyamananmu.',
                        ),
                        _buildFeature(
                          icon: Icons.volume_up,
                          title: loc?.volume ?? 'Volume',
                          description: loc?.volumeDesc ?? 
                              'Atur volume audio dan video.',
                        ),
                        _buildFeature(
                          icon: Icons.translate,
                          title: loc?.languageSwitch ?? 'Ganti Bahasa',
                          description: loc?.languageSwitchDesc ?? 
                              'Tekan EN atau ID untuk mengganti bahasa.',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tips Section
                  _buildSection(
                    icon: Icons.lightbulb_outline,
                    title: loc?.tips ?? 'Tips',
                    content: '',
                    screenWidth: screenWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTip(loc?.tip1 ?? '💡 Tonton video sampai selesai untuk pemahaman maksimal.'),
                        _buildTip(loc?.tip2 ?? '📸 Gunakan kamera dengan pencahayaan yang baik.'),
                        _buildTip(loc?.tip3 ?? '✏️ Tulis langkah-langkah penyelesaian dengan rapi.'),
                        _buildTip(loc?.tip4 ?? '🔄 Cek ulasan untuk belajar dari kesalahan.'),
                        _buildTip(loc?.tip5 ?? '⚙️ Sesuaikan pengaturan untuk kenyamanan belajar.'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Version info
                  Center(
                    child: Text(
                      'QNX v1.0.0',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required double screenWidth,
    Widget? child,
  }) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 12),
            child,
          ],
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.orange.withValues(alpha: 0.8),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
