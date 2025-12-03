import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Progress tracking for learning materials and quizzes
class ProgressTracker extends ChangeNotifier {
  static const String _progressKey = 'learning_progress';
  static const String _completedQuizzesKey = 'completed_quizzes';
  static const String _lastAccessedKey = 'last_accessed';

  Map<String, MaterialProgress> _progress = {};
  Set<String> _completedQuizzes = {};
  DateTime? _lastAccessed;

  Map<String, MaterialProgress> get progress => Map.unmodifiable(_progress);
  Set<String> get completedQuizzes => Set.unmodifiable(_completedQuizzes);
  DateTime? get lastAccessed => _lastAccessed;

  ProgressTracker() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load material progress
    final progressJson = prefs.getString(_progressKey);
    if (progressJson != null) {
      final Map<String, dynamic> decoded = json.decode(progressJson);
      _progress = decoded.map((key, value) => 
        MapEntry(key, MaterialProgress.fromJson(value)));
    }

    // Load completed quizzes
    final completedList = prefs.getStringList(_completedQuizzesKey);
    if (completedList != null) {
      _completedQuizzes = completedList.toSet();
    }

    // Load last accessed time
    final lastAccessedMs = prefs.getInt(_lastAccessedKey);
    if (lastAccessedMs != null) {
      _lastAccessed = DateTime.fromMillisecondsSinceEpoch(lastAccessedMs);
    }

    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save material progress
    final progressJson = json.encode(
      _progress.map((key, value) => MapEntry(key, value.toJson()))
    );
    await prefs.setString(_progressKey, progressJson);

    // Save completed quizzes
    await prefs.setStringList(_completedQuizzesKey, _completedQuizzes.toList());

    // Save last accessed time
    _lastAccessed = DateTime.now();
    await prefs.setInt(_lastAccessedKey, _lastAccessed!.millisecondsSinceEpoch);
  }

  /// Mark a material as started
  Future<void> startMaterial(String materialId) async {
    _progress[materialId] ??= MaterialProgress(
      materialId: materialId,
      status: ProgressStatus.inProgress,
      startedAt: DateTime.now(),
    );
    
    if (_progress[materialId]!.status == ProgressStatus.notStarted) {
      _progress[materialId] = _progress[materialId]!.copyWith(
        status: ProgressStatus.inProgress,
        startedAt: DateTime.now(),
      );
    }
    
    await _saveProgress();
    notifyListeners();
  }

  /// Mark a material as completed
  Future<void> completeMaterial(String materialId) async {
    _progress[materialId] = (_progress[materialId] ?? MaterialProgress(
      materialId: materialId,
      status: ProgressStatus.completed,
      startedAt: DateTime.now(),
    )).copyWith(
      status: ProgressStatus.completed,
      completedAt: DateTime.now(),
    );
    
    await _saveProgress();
    notifyListeners();
  }

  /// Mark a quiz as completed
  Future<void> completeQuiz(String quizId) async {
    _completedQuizzes.add(quizId);
    await _saveProgress();
    notifyListeners();
  }

  /// Check if a quiz is completed
  bool isQuizCompleted(String quizId) => _completedQuizzes.contains(quizId);

  /// Get progress status for a material
  ProgressStatus getMaterialStatus(String materialId) {
    return _progress[materialId]?.status ?? ProgressStatus.notStarted;
  }

  /// Get total progress percentage (0.0 - 1.0)
  double getTotalProgress(int totalMaterials) {
    if (totalMaterials == 0) return 0.0;
    final completed = _progress.values
        .where((p) => p.status == ProgressStatus.completed)
        .length;
    return completed / totalMaterials;
  }

  /// Get count of completed materials
  int get completedMaterialsCount => _progress.values
      .where((p) => p.status == ProgressStatus.completed)
      .length;

  /// Get count of in-progress materials
  int get inProgressCount => _progress.values
      .where((p) => p.status == ProgressStatus.inProgress)
      .length;

  /// Reset all progress
  Future<void> resetProgress() async {
    _progress.clear();
    _completedQuizzes.clear();
    _lastAccessed = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_completedQuizzesKey);
    await prefs.remove(_lastAccessedKey);
    
    // Also clear all saved quiz answers
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('userImagePath_') ||
          key.startsWith('userText_') ||
          key.startsWith('draft_text_') ||
          key.startsWith('draft_image_')) {
        await prefs.remove(key);
      }
    }

    notifyListeners();
  }

  /// Recalculate progress from saved quiz answers
  /// Call this to sync progress with actual saved answers
  Future<void> syncProgressFromSavedAnswers(List<String> allMaterialIds) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear current progress
    _progress.clear();
    _completedQuizzes.clear();

    // Recalculate based on saved answers
    for (final materialId in allMaterialIds) {
      final imagePath = prefs.getString('userImagePath_$materialId');
      final text = prefs.getString('userText_$materialId');

      final hasAnswer =
          (imagePath != null && imagePath.isNotEmpty) ||
          (text != null && text.isNotEmpty);

      if (hasAnswer) {
        _progress[materialId] = MaterialProgress(
          materialId: materialId,
          status: ProgressStatus.completed,
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
        );
        _completedQuizzes.add(materialId);
      }
    }

    await _saveProgress();
    notifyListeners();
  }

  /// Get formatted last accessed string
  String getLastAccessedText() {
    if (_lastAccessed == null) return 'Never';
    
    final now = DateTime.now();
    final diff = now.difference(_lastAccessed!);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${_lastAccessed!.day}/${_lastAccessed!.month}/${_lastAccessed!.year}';
  }
}

enum ProgressStatus { notStarted, inProgress, completed }

class MaterialProgress {
  final String materialId;
  final ProgressStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;

  MaterialProgress({
    required this.materialId,
    required this.status,
    this.startedAt,
    this.completedAt,
  });

  MaterialProgress copyWith({
    String? materialId,
    ProgressStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return MaterialProgress(
      materialId: materialId ?? this.materialId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'materialId': materialId,
    'status': status.index,
    'startedAt': startedAt?.millisecondsSinceEpoch,
    'completedAt': completedAt?.millisecondsSinceEpoch,
  };

  factory MaterialProgress.fromJson(Map<String, dynamic> json) {
    return MaterialProgress(
      materialId: json['materialId'] as String,
      status: ProgressStatus.values[json['status'] as int],
      startedAt: json['startedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['startedAt'] as int)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
    );
  }
}

/// Extension to get color for progress status
extension ProgressStatusExtension on ProgressStatus {
  Color get color {
    switch (this) {
      case ProgressStatus.notStarted:
        return Colors.grey;
      case ProgressStatus.inProgress:
        return Colors.orange;
      case ProgressStatus.completed:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case ProgressStatus.notStarted:
        return Icons.circle_outlined;
      case ProgressStatus.inProgress:
        return Icons.timelapse;
      case ProgressStatus.completed:
        return Icons.check_circle;
    }
  }
}
