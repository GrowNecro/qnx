import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show languageManager, progressTracker, routeObserver;
import '../utils/frame_preloader.dart';
import '../utils/video_preloader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, RouteAware {
  late VideoPlayerController _bgController;
  bool _isBgReady = false;
  
  // Settings
  bool _showSettings = false;
  double _brightness = 1.0; // 0.0 - 1.0
  double _volume = 0.5; // 0.0 - 1.0

  // Animation for settings panel
  late AnimationController _settingsAnimController;
  late Animation<double> _settingsAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup settings animation
    _settingsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _settingsAnimation = CurvedAnimation(
      parent: _settingsAnimController,
      curve: Curves.easeOutCubic,
    );

    // Load saved settings
    _loadSettings();
    
    // Sync progress from saved answers
    _syncProgress();

    // Jika pakai asset:
    _bgController = VideoPlayerController.asset('assets/videos/video_home.mp4')
      ..initialize().then((_) {
        // Pastikan mounted sebelum setState
        if (!mounted) return;
        setState(() {
          _isBgReady = true;
        });
        _bgController
          ..setLooping(true)
          ..setVolume(_volume)
          ..play();
      })
      ..addListener(() {
        // Pastikan video tetap playing dan looping
        if (_bgController.value.isInitialized &&
            !_bgController.value.isPlaying &&
            _bgController.value.position >= _bgController.value.duration) {
          _bgController.seekTo(Duration.zero);
          _bgController.play();
        }
      });
  }
  
  /// Sync progress tracker with actual saved answers
  Future<void> _syncProgress() async {
    // Material IDs based on judullatihan (English version as key)
    final materialIds = [
      'Constructing Linear Equations',
      'Finding Variable Values',
      'Equations with Fractions',
      'Calculating Distance Difference',
      'Linear Inequalities',
      'Distributive Property Equations',
      'Simplifying Equations',
      'Simple Fraction Equations',
    ];
    await progressTracker.syncProgressFromSavedAnswers(materialIds);
    if (mounted) setState(() {});
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _brightness = prefs.getDouble('app_brightness') ?? 1.0;
      _volume = prefs.getDouble('app_volume') ?? 0.5;
    });
    // Apply volume to video if ready
    if (_isBgReady) {
      _bgController.setVolume(_volume);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer for progress updates
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
    // Preload PNG frames for smooth transitions
    if (!framePreloader.isIntroPreloaded) {
      framePreloader.preloadAllFrames(context);
    }
    
    // Preload semua video dari materi.json
    if (!videoPreloader.isPreloaded) {
      videoPreloader.preloadAllVideos();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('app_brightness', _brightness);
    await prefs.setDouble('app_volume', _volume);
  }

  void _toggleSettings() {
    HapticFeedback.lightImpact();
    setState(() => _showSettings = !_showSettings);
    if (_showSettings) {
      _settingsAnimController.forward();
    } else {
      _settingsAnimController.reverse();
    }
  }

  Future<bool> _onWillPop() async {
    final loc = AppLocalizations.of(context);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          loc?.exitApp ?? 'Exit App',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          loc?.exitConfirm ?? 'Are you sure you want to exit?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              loc?.cancel ?? 'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(
              loc?.exit ?? 'Exit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _settingsAnimController.dispose();
    _bgController.pause();
    _bgController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this page - refresh progress
    _syncProgress();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      body: Stack(
        children: [
          // Video background (fill, cover)
          Positioned.fill(
            child: _isBgReady
                ? FittedBox(
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: _bgController.value.size.width,
                      height: _bgController.value.size.height,
                      child: VideoPlayer(_bgController),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          ),

          // Optional overlay untuk memberikan efek gelap agar teks terbaca
          Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0)),
          ),

          // Konten (ikon + tombol)
          SafeArea(
              child: Stack(
                children: [
                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Semantics(
                          label: 'Welcome image',
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcATop,
                            ),
                            child: Image.asset(
                              'assets/images/sugeng_rawuh.png',
                              width: screenWidth * 0.75,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _menuButton(
                          context,
                          AppLocalizations.of(context)?.learningMaterials ??
                              'Learning Materials',
                          '/materi',
                          Icons.menu_book,
                        ),
                        const SizedBox(height: 20),
                        _menuButton(
                          context,
                          AppLocalizations.of(context)?.questions ??
                              'Questions',
                          '/quiz',
                          Icons.quiz,
                        ),
                        const SizedBox(height: 20),
                        _menuButton(
                          context,
                          AppLocalizations.of(context)?.reviews ?? 'Reviews',
                          '/ulasan',
                          Icons.rate_review,
                        ),
                      ],
                    ),
                  ),

                  // Help button (bottom right)
                  Positioned(
                    bottom: 25,
                    right: 25,
                    child: Semantics(
                      button: true,
                      label: 'Help',
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamed(
                            context,
                            '/help',
                            arguments: const {'transisi': 'fade'},
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Settings button (top right)
                  Positioned(
                    top: 25,
                    right: 25,
                    child: IconButton(
                      icon: AnimatedRotation(
                        turns: _showSettings ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 32,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black54),
                          ],
                        ),
                      ),
                      onPressed: _toggleSettings,
                    ),
                  ),

                  // Settings dropdown panel with animation
                  if (_showSettings)
                    Positioned(
                      top: 64,
                      right: 16,
                      child: FadeTransition(
                        opacity: _settingsAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.1),
                            end: Offset.zero,
                          ).animate(_settingsAnimation),
                          child: _buildSettingsPanel(),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Brightness overlay (untuk simulasi kecerahan)
            if (_brightness < 1.0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: 1.0 - _brightness),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    final loc = AppLocalizations.of(context);

    return Material(
      color: Colors.black.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc?.settings ?? 'Settings',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => _showSettings = false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Brightness slider
            _buildSettingRow(
              icon: Icons.brightness_6,
              label: loc?.brightness ?? 'Brightness',
            ),
            Semantics(
              label: 'Brightness slider',
              child: Slider(
                value: _brightness,
                min: 0.2,
                max: 1.0,
                activeColor: Colors.orange,
                inactiveColor: Colors.grey,
                onChanged: (value) {
                  setState(() => _brightness = value);
                },
                onChangeEnd: (_) => _saveSettings(),
              ),
            ),

            const SizedBox(height: 4),

            // Volume slider
            _buildSettingRow(
              icon: _volume > 0 ? Icons.volume_up : Icons.volume_off,
              label: loc?.volume ?? 'Volume',
            ),
            Semantics(
              label: 'Volume slider',
              child: Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                activeColor: Colors.orange,
                inactiveColor: Colors.grey,
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                    _bgController.setVolume(_volume);
                  });
                },
                onChangeEnd: (_) => _saveSettings(),
              ),
            ),

            const Divider(color: Colors.white24, height: 24),

            // Language toggle
            _buildSettingRow(
              icon: Icons.language,
              label: loc?.language ?? 'Language',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildToggleButton(
                    label: 'EN',
                    isSelected: languageManager.isEnglish,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      languageManager.setEnglish();
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildToggleButton(
                    label: 'ID',
                    isSelected: languageManager.isIndonesian,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      languageManager.setIndonesian();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),

            const Divider(color: Colors.white24, height: 24),

            // Progress indicator
            _buildSettingRow(
              icon: Icons.analytics,
              label: loc?.progress ?? 'Progress',
            ),
            const SizedBox(height: 8),
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label option',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.orange
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.orange
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final completed = progressTracker.completedMaterialsCount;
    final inProg = progressTracker.inProgressCount;
    final total = 8; // Total materials in app (from materi.json)
    final percentage = progressTracker.getTotalProgress(total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '$completed/$total completed',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (inProg > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$inProg in progress',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _menuButton(
    BuildContext context,
    String text,
    String route, [
    IconData? icon,
    Map<String, dynamic>? extraArguments,
  ]) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Semantics(
      button: true,
      label: text,
      child: SizedBox(
        width: screenWidth * 0.9,
        height: 120,
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            final args = <String, dynamic>{'transisi': 'fade'};
            if (extraArguments != null) {
              args.addAll(extraArguments);
            }
            Navigator.pushNamed(context, route, arguments: args);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.black87, size: 32),
                const SizedBox(width: 16),
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
