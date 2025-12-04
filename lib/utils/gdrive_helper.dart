class GDriveHelper {
  /// Convert Google Drive share URL to direct streaming URL
  /// Input: https://drive.google.com/file/d/{FILE_ID}/view?usp=sharing
  /// Output: https://drive.usercontent.google.com/download?id={FILE_ID}
  static String? getDirectUrl(String driveUrl) {
    // Extract file ID from various Google Drive URL formats
    final patterns = [
      RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)'),
      RegExp(r'drive\.google\.com/open\?id=([a-zA-Z0-9_-]+)'),
      RegExp(r'drive\.google\.com/uc\?id=([a-zA-Z0-9_-]+)'),
      RegExp(r'drive\.usercontent\.google\.com.*[?&]id=([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(driveUrl);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1)!;
        // Use usercontent.google.com which is better for direct streaming
        // This domain is specifically for serving file content
        return 'https://drive.usercontent.google.com/download?id=$fileId&export=download&authuser=0&confirm=t';
      }
    }

    return null;
  }

  /// Get download URL (different from streaming URL)
  static String? getDownloadUrl(String driveUrl) {
    final patterns = [
      RegExp(r'drive\.google\.com/file/d/([a-zA-Z0-9_-]+)'),
      RegExp(r'drive\.google\.com/open\?id=([a-zA-Z0-9_-]+)'),
      RegExp(r'drive\.google\.com/uc\?id=([a-zA-Z0-9_-]+)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(driveUrl);
      if (match != null && match.groupCount >= 1) {
        final fileId = match.group(1)!;
        return 'https://drive.google.com/uc?export=download&id=$fileId&confirm=t';
      }
    }

    return null;
  }

  /// Check if URL is a Google Drive URL
  static bool isGDriveUrl(String url) {
    return url.contains('drive.google.com');
  }
}
