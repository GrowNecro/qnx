import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Singleton untuk cache video paths dari materi.json (offline mode)
class VideoPreloader {
  static final VideoPreloader _instance = VideoPreloader._internal();
  factory VideoPreloader() => _instance;
  VideoPreloader._internal();

  final List<String> _videoPaths = [];
  bool _isPreloaded = false;

  bool get isPreloaded => _isPreloaded;
  List<String> get videoPaths => List.unmodifiable(_videoPaths);

  /// Preload video paths dari materi.json
  Future<void> preloadAllVideos() async {
    if (_isPreloaded) return;

    try {
      // Load materi.json
      final jsonString = await rootBundle.loadString('assets/materi.json');
      final List<dynamic> rawList = json.decode(jsonString);

      // Extract semua video paths
      _videoPaths.clear();
      for (final item in rawList) {
        if (item is Map<String, dynamic> && item['video'] != null) {
          final videoPath = item['video'] as String;
          if (videoPath.isNotEmpty) {
            _videoPaths.add(videoPath);
          }
        }
      }

      _isPreloaded = true;
      debugPrint('Video preloader: Cached ${_videoPaths.length} video paths');
    } catch (e) {
      debugPrint('Video preloader error: $e');
    }
  }

  /// Cek apakah video path ada dalam cache
  bool hasVideo(String videoPath) {
    return _videoPaths.contains(videoPath);
  }

  /// Reset preloader
  void reset() {
    _videoPaths.clear();
    _isPreloaded = false;
  }
}

/// Global instance
final videoPreloader = VideoPreloader();
