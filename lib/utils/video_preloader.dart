import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Singleton untuk cache video IDs dari materi.json
/// Tidak menyimpan controller agar tidak ada masalah dispose
class VideoPreloader {
  static final VideoPreloader _instance = VideoPreloader._internal();
  factory VideoPreloader() => _instance;
  VideoPreloader._internal();

  final List<String> _videoIds = [];
  bool _isPreloaded = false;

  bool get isPreloaded => _isPreloaded;
  List<String> get videoIds => List.unmodifiable(_videoIds);

  /// Preload metadata video dari materi.json
  Future<void> preloadAllVideos() async {
    if (_isPreloaded) return;

    try {
      // Load materi.json
      final jsonString = await rootBundle.loadString('assets/materi.json');
      final List<dynamic> rawList = json.decode(jsonString);

      // Extract semua video IDs
      _videoIds.clear();
      for (final item in rawList) {
        if (item is Map<String, dynamic> && item['video'] != null) {
          final videoUrl = item['video'] as String;
          final videoId = YoutubePlayer.convertUrlToId(videoUrl);
          if (videoId != null && videoId.isNotEmpty) {
            _videoIds.add(videoId);
          }
        }
      }

      _isPreloaded = true;
      debugPrint('Video preloader: Cached ${_videoIds.length} video IDs');
    } catch (e) {
      debugPrint('Video preloader error: $e');
    }
  }

  /// Cek apakah video ID ada dalam cache (sudah di-load metadata)
  bool hasVideo(String videoId) {
    return _videoIds.contains(videoId);
  }

  /// Reset preloader
  void reset() {
    _videoIds.clear();
    _isPreloaded = false;
  }
}

/// Global instance
final videoPreloader = VideoPreloader();
