// lib/pages/aljabar_quiz_page.dart
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show progressTracker;
import '../utils/materi_localizer.dart';
import '../l10n/app_localizations.dart';

class AljabarQuizPage extends StatefulWidget {
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

  @override
  State<AljabarQuizPage> createState() => _AljabarQuizPageState();
}

class _AljabarQuizPageState extends State<AljabarQuizPage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _controller = TextEditingController();

  /// Flag untuk tahu apakah ini materi terakhir
  bool _isLastMateri = false;
  
  /// Flag untuk tracking perubahan (unsaved changes)
  bool _hasUnsavedChanges = false;

  /// Timer untuk auto-save draft
  Timer? _autoSaveTimer;

  /// Flag untuk menampilkan animasi saved
  bool _showSavedIndicator = false;

  /// Flag untuk loading state saat saving
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAnswer();
    _checkIfLastMateri();
    
    // Listen untuk perubahan text
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }
  
  /// Callback ketika text berubah
  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
    // Reset auto-save timer
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), _autoSaveDraft);
  }

  /// Auto-save draft ke SharedPreferences
  Future<void> _autoSaveDraft() async {
    if (!mounted || widget.forPreview) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'draft_text_${widget.judullatihan}',
      _controller.text,
    );
    if (_image != null) {
      await prefs.setString('draft_image_${widget.judullatihan}', _image!.path);
    }

    // Show saved indicator briefly
    if (mounted) {
      setState(() => _showSavedIndicator = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _showSavedIndicator = false);
      }
    }
  }

  Future<void> _loadSavedAnswer() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Try to load saved answer first
    String? path = prefs.getString('userImagePath_${widget.judullatihan}');
    String? text = prefs.getString('userText_${widget.judullatihan}');

    // If no saved answer, try to load draft
    if ((path == null || path.isEmpty) && (text == null || text.isEmpty)) {
      path = prefs.getString('draft_image_${widget.judullatihan}');
      text = prefs.getString('draft_text_${widget.judullatihan}');
    }

    if (!mounted) return;
    setState(() {
      if (path != null && path.isNotEmpty && File(path).existsSync()) {
        _image = File(path);
      }
      if (text != null && text.isNotEmpty) {
        _controller.text = text;
      }
    });
  }

  /// Cek sekali di awal: apakah judullatihan ini adalah materi terakhir?
  Future<void> _checkIfLastMateri() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/materi.json',
      );
      final List<dynamic> materiList = json.decode(jsonString);

      dynamic currentMateri;
      try {
        currentMateri = materiList.firstWhere(
          (m) => MateriLocalizer.matchesJudulLatihan(
            m as Map<String, dynamic>,
            widget.judullatihan,
          ),
        );
      } catch (_) {
        currentMateri = null;
      }

      if (currentMateri == null) return;

      final int? currentId = currentMateri['id'] is int
          ? currentMateri['id'] as int
          : int.tryParse(currentMateri['id'].toString());

      if (currentId == null) return;

      // Cek apakah ada materi dengan id = currentId + 1
      bool hasNext = false;
      for (final m in materiList) {
        final mid = m['id'] is int
            ? m['id'] as int
            : int.tryParse(m['id'].toString()) ?? -1;
        if (mid == currentId + 1) {
          hasNext = true;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _isLastMateri = !hasNext;
        });
      }
    } catch (_) {
      // kalau error, biarkan default false (anggap bukan terakhir)
    }
  }

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
              textScaler: const TextScaler.linear(0.7),
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

  Future<void> _takePhoto() async {
    HapticFeedback.lightImpact();
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _hasUnsavedChanges = true;
      });
      _autoSaveDraft();
    }
  }

  Future<void> _pickFromGallery() async {
    HapticFeedback.lightImpact();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _hasUnsavedChanges = true;
      });
      _autoSaveDraft();
    }
  }
  
  /// Hapus gambar yang sudah dipilih
  void _removeImage() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)?.removeImage ?? 'Hapus Gambar?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context)?.removeImageConfirm ??
              'Gambar akan dihapus dari jawaban.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(context)?.cancel ?? 'Batal',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _image = null;
                _hasUnsavedChanges = true;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              AppLocalizations.of(context)?.delete ?? 'Hapus',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullImage() {
    if (_image == null) return;
    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(child: InteractiveViewer(child: Image.file(_image!))),
        ),
      ),
    );
  }
  
  /// Konfirmasi keluar jika ada unsaved changes
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges || widget.forPreview) return true;

    final loc = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc?.unsavedChanges ?? 'Perubahan Belum Disimpan',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          loc?.unsavedChangesConfirm ??
              'Kamu memiliki jawaban yang belum disimpan. Yakin ingin keluar?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              loc?.stay ?? 'Tetap di sini',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(
              loc?.exitAnyway ?? 'Keluar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _saveJawabanAndNext() async {
    final loc = AppLocalizations.of(context);
    if (_image == null && _controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc?.emptyAnswer ?? 'Jawaban kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Show loading
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    // Simpan jawaban
    final prefs = await SharedPreferences.getInstance();
    if (_image != null) {
      await prefs.setString(
        'userImagePath_${widget.judullatihan}',
        _image!.path,
      );
    }
    await prefs.setString('userText_${widget.judullatihan}', _controller.text);
    
    // Clear draft setelah save
    await prefs.remove('draft_text_${widget.judullatihan}');
    await prefs.remove('draft_image_${widget.judullatihan}');

    // Mark as saved
    _hasUnsavedChanges = false;

    // Track progress - mark quiz as completed and material as completed
    await progressTracker.completeQuiz(widget.judullatihan);
    await progressTracker.completeMaterial(widget.judullatihan);
    
    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(loc?.answerSaved ?? 'Jawaban tersimpan!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _isSaving = false);

    // Ambil materi.json
    final String jsonString = await rootBundle.loadString('assets/materi.json');
    final List<dynamic> materiList = json.decode(jsonString);

    // Materi sekarang
    dynamic currentMateri;
    try {
      currentMateri = materiList.firstWhere(
        (m) => MateriLocalizer.matchesJudulLatihan(
          m as Map<String, dynamic>,
          widget.judullatihan,
        ),
      );
    } catch (_) {
      currentMateri = null;
    }

    if (currentMateri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(loc?.materialNotFound ?? 'Materi tidak ditemukan'),
        ),
      );
      return;
    }

    final int? currentId = currentMateri['id'] is int
        ? currentMateri['id'] as int
        : int.tryParse(currentMateri['id'].toString());

    if (currentId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(loc?.idNotValid ?? 'ID materi tidak valid')),
      );
      return;
    }

    // Cari materi id berikutnya
    dynamic nextMateri;
    try {
      nextMateri = materiList.firstWhere((m) {
        final mid = m['id'] is int
            ? m['id'] as int
            : int.tryParse(m['id'].toString()) ?? -1;
        return mid == currentId + 1;
      });
    } catch (_) {
      nextMateri = null;
    }

    // Jika ini materi terakhir (tidak ada nextMateri) → ke HOME
    if (nextMateri == null || _isLastMateri) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc?.allMaterialsCompleted ??
                  'Selamat, semua materi sudah selesai!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // pergi ke home dan buang semua route sebelumnya, via AppRoutes + transisi
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
          arguments: {
            'transisi':
                'transisi2', // biar tetap pakai PNG transition dari AppRoutes
          },
        );
      }
      return;
    }

    // Ambil data untuk materi/video berikutnya
    final nextMateriMap = nextMateri as Map<String, dynamic>;
    final String nextVideoPath = nextMateriMap['video']?.toString() ?? '';
    final String nextJudulLatihan = MateriLocalizer.getJudulLatihan(
      nextMateriMap,
    );
    final String nextJudul = MateriLocalizer.getJudul(nextMateriMap);

    // Pindah ke halaman video materi berikutnya via AppRoutes + transisi
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/materi/video',
      arguments: {
        'videoPath': nextVideoPath,
        'judulMateri': nextJudul,
        'judullatihan': nextJudulLatihan,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        // biar background bisa sampai belakang appbar
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.judullatihan,
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
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && mounted) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            // Auto-save indicator
            if (_showSavedIndicator)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Icon(Icons.cloud_done, color: Colors.green, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'Draft tersimpan',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            // === BACKGROUND ===
            SizedBox.expand(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),

            // === KONTEN ===
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: screenWidth * 0.9,
                        height: screenHeight * 0.8,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: screenHeight * 0.25,
                              child: SingleChildScrollView(
                                child: RichText(
                                  textAlign: TextAlign.justify,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: parseMathText(widget.latihan),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: _image == null && _controller.text.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate,
                                            size: 64,
                                            color: Colors.white.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            AppLocalizations.of(
                                                  context,
                                                )?.noAnswerYet ??
                                                'Belum ada foto jawaban',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Stack(
                                      children: [
                                        // Gambar jawaban atau text area
                                        if (_image != null)
                                          Positioned.fill(
                                            child: GestureDetector(
                                              onTap: _openFullImage,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.file(
                                                  _image!,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          const Center(
                                            child: Text(
                                              'Jawaban teks sudah disimpan',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        // Tombol hapus gambar
                                        if (_image != null)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: _removeImage,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        // Maskot di tengah jika ada jawaban (gambar atau teks)
                                        if (_image != null ||
                                            _controller.text.isNotEmpty)
                                          Positioned(
                                            right: 8,
                                            bottom: 0,
                                            child: Image.asset(
                                              'assets/images/maskot.png',
                                              width: 150,
                                              height: 150,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                      ],
                                    ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(
                                      context,
                                    )?.writeAnswerHere ??
                                    'Tulis jawaban teks kamu di sini',
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.black26,
                              ),
                              style: const TextStyle(color: Colors.white),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.forPreview ? null : _takePhoto,
                            icon: const Icon(Icons.camera_alt, size: 20),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppLocalizations.of(context)?.takePhoto ??
                                    'Foto',
                                maxLines: 1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.forPreview
                                ? null
                                : _pickFromGallery,
                            icon: const Icon(Icons.photo_library, size: 20),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppLocalizations.of(
                                      context,
                                    )?.chooseFromGallery ??
                                    'Galeri',
                                maxLines: 1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: (widget.forPreview || _isSaving)
                                ? null
                                : _saveJawabanAndNext,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    _isLastMateri
                                        ? Icons.check_circle_rounded
                                        : Icons.arrow_forward_ios_rounded,
                                    size: 20,
                                  ),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isSaving
                                    ? '...'
                                    : _isLastMateri
                                    ? (AppLocalizations.of(
                                            context,
                                          )?.completed ??
                                          'Selesai')
                                    : (AppLocalizations.of(context)?.next ??
                                          'Next'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
