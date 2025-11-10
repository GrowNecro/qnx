import 'dart:typed_data';

/// Simple in-memory screenshot cache (lives only while app is running).
class MemoryScreenshotCache {
  // singleton instance
  static final MemoryScreenshotCache _instance =
      MemoryScreenshotCache._internal();
  factory MemoryScreenshotCache() => _instance;
  MemoryScreenshotCache._internal();

  // internal storage
  final Map<String, Uint8List> _cache = {};

  /// Save screenshot bytes into memory
  void save(String key, Uint8List bytes) {
    _cache[key] = bytes;
  }

  /// Retrieve screenshot (returns null if not found)
  Uint8List? get(String key) => _cache[key];

  /// Delete one
  void remove(String key) => _cache.remove(key);

  /// Clear all
  void clear() => _cache.clear();
}
