import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qnx/utils/progress_tracker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MaterialProgress', () {
    test('should create MaterialProgress with required fields', () {
      final progress = MaterialProgress(
        materialId: 'test_material',
        status: ProgressStatus.notStarted,
      );

      expect(progress.materialId, 'test_material');
      expect(progress.status, ProgressStatus.notStarted);
      expect(progress.startedAt, isNull);
      expect(progress.completedAt, isNull);
    });

    test('should create MaterialProgress with all fields', () {
      final now = DateTime.now();
      final progress = MaterialProgress(
        materialId: 'test_material',
        status: ProgressStatus.completed,
        startedAt: now,
        completedAt: now,
      );

      expect(progress.materialId, 'test_material');
      expect(progress.status, ProgressStatus.completed);
      expect(progress.startedAt, now);
      expect(progress.completedAt, now);
    });

    test('copyWith should create new instance with updated values', () {
      final original = MaterialProgress(
        materialId: 'test_material',
        status: ProgressStatus.notStarted,
      );

      final updated = original.copyWith(
        status: ProgressStatus.inProgress,
        startedAt: DateTime.now(),
      );

      expect(updated.materialId, 'test_material');
      expect(updated.status, ProgressStatus.inProgress);
      expect(updated.startedAt, isNotNull);
      expect(original.status, ProgressStatus.notStarted); // Original unchanged
    });

    test('toJson should serialize correctly', () {
      final now = DateTime.now();
      final progress = MaterialProgress(
        materialId: 'test_material',
        status: ProgressStatus.completed,
        startedAt: now,
        completedAt: now,
      );

      final json = progress.toJson();

      expect(json['materialId'], 'test_material');
      expect(json['status'], ProgressStatus.completed.index);
      expect(json['startedAt'], now.millisecondsSinceEpoch);
      expect(json['completedAt'], now.millisecondsSinceEpoch);
    });

    test('fromJson should deserialize correctly', () {
      final now = DateTime.now();
      final json = {
        'materialId': 'test_material',
        'status': ProgressStatus.inProgress.index,
        'startedAt': now.millisecondsSinceEpoch,
        'completedAt': null,
      };

      final progress = MaterialProgress.fromJson(json);

      expect(progress.materialId, 'test_material');
      expect(progress.status, ProgressStatus.inProgress);
      expect(progress.startedAt?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(progress.completedAt, isNull);
    });
  });

  group('ProgressStatus', () {
    test('should have correct index values', () {
      expect(ProgressStatus.notStarted.index, 0);
      expect(ProgressStatus.inProgress.index, 1);
      expect(ProgressStatus.completed.index, 2);
    });

    test('extension should return correct colors', () {
      expect(ProgressStatus.notStarted.color, isNotNull);
      expect(ProgressStatus.inProgress.color, isNotNull);
      expect(ProgressStatus.completed.color, isNotNull);
    });

    test('extension should return correct icons', () {
      expect(ProgressStatus.notStarted.icon, isNotNull);
      expect(ProgressStatus.inProgress.icon, isNotNull);
      expect(ProgressStatus.completed.icon, isNotNull);
    });
  });

  group('ProgressTracker', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should initialize with empty progress', () async {
      final tracker = ProgressTracker();
      
      // Wait for async initialization
      await Future.delayed(const Duration(milliseconds: 100));

      expect(tracker.completedMaterialsCount, 0);
      expect(tracker.inProgressCount, 0);
      expect(tracker.completedQuizzes, isEmpty);
    });

    test('startMaterial should mark material as in progress', () async {
      SharedPreferences.setMockInitialValues({});
      final tracker = ProgressTracker();
      await Future.delayed(const Duration(milliseconds: 100));

      await tracker.startMaterial('material_1');

      expect(tracker.getMaterialStatus('material_1'), ProgressStatus.inProgress);
      expect(tracker.inProgressCount, 1);
    });

    test('completeMaterial should mark material as completed', () async {
      SharedPreferences.setMockInitialValues({});
      final tracker = ProgressTracker();
      await Future.delayed(const Duration(milliseconds: 100));

      await tracker.completeMaterial('material_1');

      expect(tracker.getMaterialStatus('material_1'), ProgressStatus.completed);
      expect(tracker.completedMaterialsCount, 1);
    });

    test('completeQuiz should add quiz to completed set', () async {
      SharedPreferences.setMockInitialValues({});
      final tracker = ProgressTracker();
      await Future.delayed(const Duration(milliseconds: 100));

      await tracker.completeQuiz('quiz_1');

      expect(tracker.isQuizCompleted('quiz_1'), isTrue);
      expect(tracker.isQuizCompleted('quiz_2'), isFalse);
    });

    test('getTotalProgress should calculate correct percentage', () async {
      SharedPreferences.setMockInitialValues({});
      final tracker = ProgressTracker();
      await Future.delayed(const Duration(milliseconds: 100));

      await tracker.completeMaterial('material_1');
      await tracker.completeMaterial('material_2');

      expect(tracker.getTotalProgress(8), 0.25); // 2/8 = 0.25
      expect(tracker.getTotalProgress(4), 0.5);  // 2/4 = 0.5
      expect(tracker.getTotalProgress(0), 0.0);  // Edge case
    });

    test('resetProgress should clear all data', () async {
      SharedPreferences.setMockInitialValues({});
      final tracker = ProgressTracker();
      await Future.delayed(const Duration(milliseconds: 100));

      await tracker.completeMaterial('material_1');
      await tracker.completeQuiz('quiz_1');
      
      expect(tracker.completedMaterialsCount, 1);
      expect(tracker.isQuizCompleted('quiz_1'), isTrue);

      await tracker.resetProgress();

      expect(tracker.completedMaterialsCount, 0);
      expect(tracker.isQuizCompleted('quiz_1'), isFalse);
      expect(tracker.lastAccessed, isNull);
    });

    test('getMaterialStatus should return notStarted for unknown material', () async {
      SharedPreferences.setMockInitialValues({});
      final tracker = ProgressTracker();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(tracker.getMaterialStatus('unknown'), ProgressStatus.notStarted);
    });

    test('getLastAccessedText should return correct format', () async {
      SharedPreferences.setMockInitialValues({});
      final tracker = ProgressTracker();
      await Future.delayed(const Duration(milliseconds: 100));

      // Before any activity
      expect(tracker.getLastAccessedText(), 'Never');

      // After some activity
      await tracker.startMaterial('material_1');
      final text = tracker.getLastAccessedText();
      expect(text, isNot('Never'));
    });

    test('syncProgressFromSavedAnswers should recalculate from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'userText_material_1': 'Some answer',
        'userImagePath_material_2': '/path/to/image.png',
      });
      
      final tracker = ProgressTracker();
      await Future.delayed(const Duration(milliseconds: 100));

      await tracker.syncProgressFromSavedAnswers([
        'material_1',
        'material_2',
        'material_3',
      ]);

      expect(tracker.getMaterialStatus('material_1'), ProgressStatus.completed);
      expect(tracker.getMaterialStatus('material_2'), ProgressStatus.completed);
      expect(tracker.getMaterialStatus('material_3'), ProgressStatus.notStarted);
      expect(tracker.completedMaterialsCount, 2);
    });
  });
}
