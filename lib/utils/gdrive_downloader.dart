import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'gdrive_helper.dart';

class GDriveDownloader {
  static final Dio _dio = Dio();

  /// Extract file ID from Google Drive URL
  static String? getFileId(String driveUrl) {
    final patterns = [
      RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)'),
      RegExp(r'drive\.google\.com/open\?id=([a-zA-Z0-9_-]+)'),
      RegExp(r'drive\.google\.com/uc\?id=([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(driveUrl);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Download video from Google Drive URL
  /// Returns the local file path if successful
  static Future<String?> downloadFromGDrive(
    String driveUrl, {
    Function(double)? onProgress,
  }) async {
    try {
      // Extract file ID
      final fileId = getFileId(driveUrl);
      if (fileId == null) {
        debugPrint('Invalid Google Drive URL format');
        return null;
      }

      // Get download URL (different from streaming URL)
      final downloadUrl = GDriveHelper.getDownloadUrl(driveUrl);
      if (downloadUrl == null) {
        debugPrint('Failed to get Google Drive download URL');
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

      // Download file with options to handle redirects
      debugPrint('Downloading from: $downloadUrl');
      await _dio.download(
        downloadUrl,
        filePath,
        options: Options(
          followRedirects: true,
          maxRedirects: 5,
          receiveTimeout: const Duration(minutes: 10),
        ),
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
      debugPrint('Error downloading from Google Drive: $e');
      return null;
    }
  }

  /// Check if video is already downloaded
  static Future<bool> isDownloaded(String driveUrl) async {
    try {
      final fileId = getFileId(driveUrl);
      if (fileId == null) return false;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/videos/$fileId.mp4';
      final File file = File(filePath);
      
      return await file.exists();
    } catch (e) {
      debugPrint('Error checking download status: $e');
      return false;
    }
  }

  /// Get local file path if already downloaded
  static Future<String?> getLocalPath(String driveUrl) async {
    try {
      final fileId = getFileId(driveUrl);
      if (fileId == null) return null;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/videos/$fileId.mp4';
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
  static Future<bool> deleteDownload(String driveUrl) async {
    try {
      final fileId = getFileId(driveUrl);
      if (fileId == null) return false;

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/videos/$fileId.mp4';
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
