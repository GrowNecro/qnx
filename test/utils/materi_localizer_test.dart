import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qnx/utils/materi_localizer.dart';

void main() {
  // Initialize binding for SharedPreferences
  setUpAll(() {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('MateriLocalizer', () {
    group('getText', () {
      test('should return fallback for null field', () {
        expect(MateriLocalizer.getText(null), equals(''));
        expect(MateriLocalizer.getText(null, fallback: 'default'), equals('default'));
      });

      test('should return string directly for old format', () {
        expect(MateriLocalizer.getText('Hello World'), equals('Hello World'));
        expect(MateriLocalizer.getText(''), equals(''));
      });

      test('should return localized text from map for new format', () async {
        // Wait for language manager to initialize
        await Future.delayed(const Duration(milliseconds: 100));
        
        final field = {'en': 'Hello', 'id': 'Halo'};
        
        // This will depend on current language setting
        final result = MateriLocalizer.getText(field);
        expect(result, isIn(['Hello', 'Halo']));
      });

      test('should fallback to English when current language not available', () async {
        await Future.delayed(const Duration(milliseconds: 100));
        
        final field = {'en': 'English Only'};
        expect(MateriLocalizer.getText(field), equals('English Only'));
      });

      test('should fallback to Indonesian when English not available', () async {
        await Future.delayed(const Duration(milliseconds: 100));
        
        final field = {'id': 'Indonesian Only'};
        expect(MateriLocalizer.getText(field), equals('Indonesian Only'));
      });

      test('should return first available value when neither en/id available', () async {
        await Future.delayed(const Duration(milliseconds: 100));
        
        final field = {'fr': 'French', 'de': 'German'};
        final result = MateriLocalizer.getText(field);
        expect(result, isIn(['French', 'German']));
      });

      test('should return fallback for empty map', () {
        expect(MateriLocalizer.getText({}, fallback: 'empty'), equals('empty'));
      });

      test('should return fallback for unsupported type', () {
        expect(MateriLocalizer.getText(123, fallback: 'unsupported'), equals('unsupported'));
        expect(MateriLocalizer.getText([1, 2, 3], fallback: 'unsupported'), equals('unsupported'));
      });
    });

    group('getJudul', () {
      test('should extract judul from materi', () {
        final materi = {'judul': 'Test Title'};
        expect(MateriLocalizer.getJudul(materi), equals('Test Title'));
      });

      test('should return Untitled for missing judul', () {
        final materi = <String, dynamic>{};
        expect(MateriLocalizer.getJudul(materi), equals('Untitled'));
      });

      test('should handle bilingual judul', () {
        final materi = {'judul': {'en': 'English Title', 'id': 'Judul Indonesia'}};
        final result = MateriLocalizer.getJudul(materi);
        expect(result, isIn(['English Title', 'Judul Indonesia']));
      });
    });

    group('getJudulLatihan', () {
      test('should extract judullatihan from materi', () {
        final materi = {'judullatihan': 'Exercise 1'};
        expect(MateriLocalizer.getJudulLatihan(materi), equals('Exercise 1'));
      });

      test('should return Exercise for missing judullatihan', () {
        final materi = <String, dynamic>{};
        expect(MateriLocalizer.getJudulLatihan(materi), equals('Exercise'));
      });

      test('should handle bilingual judullatihan', () {
        final materi = {'judullatihan': {'en': 'Exercise', 'id': 'Latihan'}};
        final result = MateriLocalizer.getJudulLatihan(materi);
        expect(result, isIn(['Exercise', 'Latihan']));
      });
    });

    group('getLatihan', () {
      test('should extract latihan from materi', () {
        final materi = {'latihan': 'Solve x + 2 = 5'};
        expect(MateriLocalizer.getLatihan(materi), equals('Solve x + 2 = 5'));
      });

      test('should return empty string for missing latihan', () {
        final materi = <String, dynamic>{};
        expect(MateriLocalizer.getLatihan(materi), equals(''));
      });
    });

    group('getJawabanSistem', () {
      test('should extract jawabansistemteks from materi', () {
        final materi = {'jawabansistemteks': 'x = 3'};
        expect(MateriLocalizer.getJawabanSistem(materi), equals('x = 3'));
      });

      test('should return empty string for missing jawabansistemteks', () {
        final materi = <String, dynamic>{};
        expect(MateriLocalizer.getJawabanSistem(materi), equals(''));
      });

      test('should handle bilingual jawabansistemteks', () {
        final materi = {
          'jawabansistemteks': {
            'id': 'Langkah 1: ...',
            'en': 'Step 1: ...'
          }
        };
        final result = MateriLocalizer.getJawabanSistem(materi);
        expect(result, isIn(['Langkah 1: ...', 'Step 1: ...']));
      });
    });

    group('matchesJudulLatihan', () {
      test('should match string judullatihan', () {
        final materi = {'judullatihan': 'Exercise 1'};
        expect(MateriLocalizer.matchesJudulLatihan(materi, 'Exercise 1'), isTrue);
        expect(MateriLocalizer.matchesJudulLatihan(materi, 'Exercise 2'), isFalse);
      });

      test('should match map judullatihan with any language', () {
        final materi = {'judullatihan': {'en': 'Exercise', 'id': 'Latihan'}};
        expect(MateriLocalizer.matchesJudulLatihan(materi, 'Exercise'), isTrue);
        expect(MateriLocalizer.matchesJudulLatihan(materi, 'Latihan'), isTrue);
        expect(MateriLocalizer.matchesJudulLatihan(materi, 'Other'), isFalse);
      });

      test('should return false for null judullatihan', () {
        final materi = <String, dynamic>{};
        expect(MateriLocalizer.matchesJudulLatihan(materi, 'Any'), isFalse);
      });

      test('should return false for unsupported type', () {
        final materi = {'judullatihan': 123};
        expect(MateriLocalizer.matchesJudulLatihan(materi, '123'), isFalse);
      });
    });

    group('findByJudulLatihan', () {
      final materiList = [
        {'id': 1, 'judullatihan': 'Exercise 1'},
        {'id': 2, 'judullatihan': 'Exercise 2'},
        {'id': 3, 'judullatihan': {'en': 'Exercise 3', 'id': 'Latihan 3'}},
      ];

      test('should find materi by string judullatihan', () {
        final result = MateriLocalizer.findByJudulLatihan(
          materiList.map((m) => Map<String, dynamic>.from(m)).toList(),
          'Exercise 1',
        );
        expect(result, isNotNull);
        expect(result!['id'], equals(1));
      });

      test('should find materi by map judullatihan (English)', () {
        final result = MateriLocalizer.findByJudulLatihan(
          materiList.map((m) => Map<String, dynamic>.from(m)).toList(),
          'Exercise 3',
        );
        expect(result, isNotNull);
        expect(result!['id'], equals(3));
      });

      test('should find materi by map judullatihan (Indonesian)', () {
        final result = MateriLocalizer.findByJudulLatihan(
          materiList.map((m) => Map<String, dynamic>.from(m)).toList(),
          'Latihan 3',
        );
        expect(result, isNotNull);
        expect(result!['id'], equals(3));
      });

      test('should return null when not found', () {
        final result = MateriLocalizer.findByJudulLatihan(
          materiList.map((m) => Map<String, dynamic>.from(m)).toList(),
          'Non-existent',
        );
        expect(result, isNull);
      });

      test('should return null for empty list', () {
        final result = MateriLocalizer.findByJudulLatihan([], 'Any');
        expect(result, isNull);
      });
    });
  });
}
