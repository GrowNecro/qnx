// lib/utils/screenshot_disk.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Directory> _appDir() async {
  final dir = await getApplicationDocumentsDirectory();
  return dir;
}

/// safe filename from key
String _fileNameForKey(String key) {
  // sanitize: only keep safe chars
  final name = key.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
  return '$name.png';
}

Future<File> _fileForKey(String key) async {
  final dir = await _appDir();
  final fname = _fileNameForKey(key);
  return File(p.join(dir.path, fname));
}

Future<void> saveScreenshotToDisk(String key, Uint8List bytes) async {
  try {
    final f = await _fileForKey(key);
    await f.writeAsBytes(bytes, flush: true);
  } catch (_) {
    // ignore disk errors
  }
}

Future<Uint8List?> loadScreenshotFromDisk(String key) async {
  try {
    final f = await _fileForKey(key);
    if (await f.exists()) {
      final bytes = await f.readAsBytes();
      return bytes;
    }
  } catch (_) {}
  return null;
}

Future<bool> deleteScreenshotFromDisk(String key) async {
  try {
    final f = await _fileForKey(key);
    if (await f.exists()) {
      await f.delete();
      return true;
    }
  } catch (_) {}
  return false;
}
