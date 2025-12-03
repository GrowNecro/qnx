import 'package:flutter_test/flutter_test.dart';
import 'package:qnx/utils/app_utils.dart';

void main() {
  group('AppSettings', () {
    late AppSettings settings;

    setUp(() {
      settings = AppSettings();
      // Reset to default values
      settings.setBrightness(1.0);
      settings.setVolume(0.5);
    });

    test('should be a singleton', () {
      final settings1 = AppSettings();
      final settings2 = AppSettings();
      expect(identical(settings1, settings2), isTrue);
    });

    test('should have default brightness of 1.0', () {
      settings.setBrightness(1.0);
      expect(settings.brightness, equals(1.0));
    });

    test('should have default volume of 0.5', () {
      settings.setVolume(0.5);
      expect(settings.volume, equals(0.5));
    });

    group('setBrightness', () {
      test('should set brightness within valid range', () {
        settings.setBrightness(0.5);
        expect(settings.brightness, equals(0.5));
      });

      test('should clamp brightness to minimum 0.2', () {
        settings.setBrightness(0.1);
        expect(settings.brightness, equals(0.2));

        settings.setBrightness(-1.0);
        expect(settings.brightness, equals(0.2));
      });

      test('should clamp brightness to maximum 1.0', () {
        settings.setBrightness(1.5);
        expect(settings.brightness, equals(1.0));

        settings.setBrightness(10.0);
        expect(settings.brightness, equals(1.0));
      });

      test('should notify listeners on brightness change', () {
        int callCount = 0;
        settings.addListener(() => callCount++);

        settings.setBrightness(0.7);
        expect(callCount, equals(1));

        settings.setBrightness(0.8);
        expect(callCount, equals(2));
      });
    });

    group('setVolume', () {
      test('should set volume within valid range', () {
        settings.setVolume(0.7);
        expect(settings.volume, equals(0.7));
      });

      test('should clamp volume to minimum 0.0', () {
        settings.setVolume(-0.5);
        expect(settings.volume, equals(0.0));
      });

      test('should clamp volume to maximum 1.0', () {
        settings.setVolume(2.0);
        expect(settings.volume, equals(1.0));
      });

      test('should notify listeners on volume change', () {
        int callCount = 0;
        settings.addListener(() => callCount++);

        settings.setVolume(0.3);
        expect(callCount, equals(1));
      });
    });

    group('listeners', () {
      test('should add and remove listeners', () {
        int callCount = 0;
        void listener() => callCount++;

        settings.addListener(listener);
        settings.setBrightness(0.5);
        expect(callCount, equals(1));

        settings.removeListener(listener);
        settings.setBrightness(0.6);
        expect(callCount, equals(1)); // Should not increase
      });

      test('should support multiple listeners', () {
        int count1 = 0;
        int count2 = 0;

        settings.addListener(() => count1++);
        settings.addListener(() => count2++);

        settings.setBrightness(0.5);
        expect(count1, equals(1));
        expect(count2, equals(1));
      });
    });
  });

  group('HapticFeedbackType', () {
    test('should have all expected values', () {
      expect(HapticFeedbackType.values.length, equals(4));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.light));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.medium));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.heavy));
      expect(HapticFeedbackType.values, contains(HapticFeedbackType.selection));
    });
  });
}
