import 'package:flutter_test/flutter_test.dart';
import 'package:qnx/utils/frame_preloader.dart';

void main() {
  group('FramePreloader', () {
    late FramePreloader preloader;

    setUp(() {
      preloader = FramePreloader();
      preloader.reset(); // Reset state before each test
    });

    test('should be a singleton', () {
      final preloader1 = FramePreloader();
      final preloader2 = FramePreloader();
      expect(identical(preloader1, preloader2), isTrue);
    });

    test('should have correct initial state', () {
      preloader.reset();
      expect(preloader.isIntroPreloaded, isFalse);
      expect(preloader.isShortPreloaded, isFalse);
      expect(preloader.isPreloading, isFalse);
    });

    group('reset', () {
      test('should reset all preload states', () {
        preloader.reset();
        expect(preloader.isIntroPreloaded, isFalse);
        expect(preloader.isShortPreloaded, isFalse);
        expect(preloader.isPreloading, isFalse);
      });
    });

    // Note: Actual preloading tests would require a proper BuildContext
    // which is difficult to mock in unit tests. These would be better
    // tested as integration tests or widget tests.

    group('getters', () {
      test('isIntroPreloaded should return current state', () {
        preloader.reset();
        expect(preloader.isIntroPreloaded, isFalse);
      });

      test('isShortPreloaded should return current state', () {
        preloader.reset();
        expect(preloader.isShortPreloaded, isFalse);
      });

      test('isPreloading should return current state', () {
        preloader.reset();
        expect(preloader.isPreloading, isFalse);
      });
    });
  });

  group('framePreloader global instance', () {
    test('should be a FramePreloader instance', () {
      expect(framePreloader, isA<FramePreloader>());
    });

    test('should be the same as FramePreloader factory', () {
      expect(identical(framePreloader, FramePreloader()), isTrue);
    });
  });
}
