import 'dart:io';
import 'package:flutter/services.dart';

/// Saves the app data as one JSON file inside the app's private folder.
/// The folder path comes from a tiny piece of Kotlin code (MainActivity)
/// so no extra Flutter plugin is needed.
class Storage {
  static const MethodChannel _channel = MethodChannel('school_manager/storage');
  static File? _cached;

  static Future<File> _file() async {
    final File? existing = _cached;
    if (existing != null) return existing;
    String dir;
    try {
      final String? d = await _channel.invokeMethod<String>('dir');
      dir = (d == null || d.isEmpty) ? Directory.systemTemp.path : d;
    } catch (_) {
      dir = Directory.systemTemp.path;
    }
    final Directory folder = Directory(dir);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final File f = File('$dir/school_data.json');
    _cached = f;
    return f;
  }

  static Future<String?> read() async {
    try {
      final File f = await _file();
      if (await f.exists()) {
        return await f.readAsString();
      }
    } catch (_) {}
    return null;
  }

  static Future<void> write(String text) async {
    try {
      final File f = await _file();
      final File tmp = File('${f.path}.tmp');
      await tmp.writeAsString(text, flush: true);
      await tmp.rename(f.path);
    } catch (_) {}
  }
}
