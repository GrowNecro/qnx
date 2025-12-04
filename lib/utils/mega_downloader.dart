import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class MegaDownloader {
  static final Dio _dio = Dio();

  /// Extract file ID and key from Mega URL
  /// Format: https://mega.nz/file/{fileId}#{key}
  static Map<String, String>? parseMegaUrl(String url) {
    final regex = RegExp(r'https://mega\.nz/file/([^#]+)#(.+)');
    final match = regex.firstMatch(url);
    
    if (match != null && match.groupCount >= 2) {
      return {
        'fileId': match.group(1)!,
        'key': match.group(2)!,
      };
    }
    return null;
  }

  /// Get download URL from Mega
  /// Mega uses a public API to get direct download links
  static Future<String?> getMegaDirectUrl(String fileId, String key) async {
    try {
      // Mega API endpoint
      final response = await _dio.post(
        'https://g.api.mega.co.nz/cs',
        queryParameters: {'id': '0', 'n': fileId},
        data: [
          {
            'a': 'g',
            'g': 1,
            'p': fileId,
          }
        ],
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data is List) {
        final data = response.data[0];
        if (data['g'] != null) {
          return data['g'] as String;
        }
      }
    } catch (e) {
      debugPrint('Error getting Mega direct URL: $e');
    }
    return null;
  }

  /// Download video from Mega URL
  /// Returns the local file path if successful
  static Future<String?> downloadFromMega(
    String megaUrl, {
    Function(double)? onProgress,
  }) async {
    try {
      // Parse Mega URL
      final parsed = parseMegaUrl(megaUrl);
      if (parsed == null) {
        debugPrint('Invalid Mega URL format');
        return null;
      }

      final fileId = parsed['fileId']!;
      final key = parsed['key']!;

      // Get direct download URL
      final directUrl = await getMegaDirectUrl(fileId, key);
      if (directUrl == null) {
        debugPrint('Failed to get Mega direct URL');
        return null;
      }

      // Get local storage directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String videosDir = '${appDir.path}/videos';
      
      // Create videos directory if it doesn't exist
      final Directory videosDirObj = Directory(videosDir);
      if (!await videosDirObj.exists()) {
        await videosDirObj.create(recursive: true);
      }

      // Save file with fileId as name
      final String filePath = '$videosDir/$fileId.mp4';
      final File file = File(filePath);

      // Check if already downloaded
      if (await file.exists()) {
        debugPrint('Video already downloaded: $filePath');
        return filePath;
      }

      // Download file
      debugPrint('Downloading from: $directUrl');
      await _dio.download(
        directUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            final progress = received / total;
            onProgress(progress);
          }
        },
      );

      debugPrint('Download complete: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error downloading from Mega: $e');
      return null;
    }
  }

  /// Check if video is already downloaded
  static Future<bool> isDownloaded(String megaUrl) async {
    try {
      final parsed = parseMegaUrl(megaUrl);
      if (parsed == null) return false;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/videos/${parsed['fileId']}.mp4';
      final File file = File(filePath);
      
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking download status: $e');
      return false;
    }
  }

  /// Get local file path if already downloaded
  static Future<String?> getLocalPath(String megaUrl) async {
    try {
      final parsed = parseMegaUrl(megaUrl);
      if (parsed == null) return null;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/videos/${parsed['fileId']}.mp4';
      final File file = File(filePath);
      
      if (await file.exists()) {
        return filePath;
      }
    } catch (e) {
      debugPrint('Error getting local path: $e');
    }
    return null;
  }

  /// Delete downloaded video
  static Future<bool> deleteDownload(String megaUrl) async {
    try {
      final parsed = parseMegaUrl(megaUrl);
      if (parsed == null) return false;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/videos/${parsed['fileId']}.mp4';
      final File file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
        debugPrint('Deleted: $filePath');
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting download: $e');
    }
    return false;
  }
}
