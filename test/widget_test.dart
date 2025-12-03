// Main widget tests for QNX app
//
// This file exports all unit and widget tests for the QNX learning app.
// Run all tests with: flutter test

import 'package:flutter_test/flutter_test.dart';

// Import utility tests
import 'utils/progress_tracker_test.dart' as progress_tracker_tests;
import 'utils/language_manager_test.dart' as language_manager_tests;
import 'utils/materi_localizer_test.dart' as materi_localizer_tests;
import 'utils/app_utils_test.dart' as app_utils_tests;
import 'utils/frame_preloader_test.dart' as frame_preloader_tests;
import 'utils/theme_manager_test.dart' as theme_manager_tests;

// Import routes tests
import 'routes/app_routes_test.dart' as app_routes_tests;

void main() {
  group('QNX App Tests', () {
    group('Utils', () {
      progress_tracker_tests.main();
      language_manager_tests.main();
      materi_localizer_tests.main();
      app_utils_tests.main();
      frame_preloader_tests.main();
      theme_manager_tests.main();
    });

    group('Routes', () {
      app_routes_tests.main();
    });
  });
}
