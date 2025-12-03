import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'routes/app_routes.dart';
import 'l10n/app_localizations.dart';
import 'utils/theme_manager.dart';
import 'utils/language_manager.dart';
import 'utils/progress_tracker.dart';

// Global instances
final ThemeManager themeManager = ThemeManager();
final LanguageManager languageManager = LanguageManager();
final ProgressTracker progressTracker = ProgressTracker();
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set fullscreen immersive untuk seluruh app
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [], // Sembunyikan semua system overlay
  );

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to changes
    themeManager.addListener(_onSettingsChanged);
    languageManager.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    themeManager.removeListener(_onSettingsChanged);
    languageManager.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Questions and X',
      debugShowCheckedModeBanner: false,
      
      // Theme support
      theme: ThemeManager.lightTheme,
      darkTheme: ThemeManager.darkTheme,
      themeMode: themeManager.themeMode,

      // Localization support
      locale: languageManager.locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorObservers: [routeObserver],
      builder: (context, child) {
        // Wrap semua halaman dengan fullscreen setting
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
            systemNavigationBarContrastEnforced: false,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
