import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_chat/utils/file_utils.dart';

class LogManager extends ChangeNotifier {
  static final LogManager instance = LogManager._internal();

  LogManager._internal();

  bool _isLoggingEnabled = false;
  bool get isLoggingEnabled => _isLoggingEnabled;

  File? _logFile;
  final int _maxLogFileSizeBytes = 5 * 1024 * 1024; // 5MB

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggingEnabled = prefs.getBool('enable_logging') ?? false;
    if (_isLoggingEnabled) {
      try {
        var p = await PathProvider.getPath("logs/app_logs.txt");
        _logFile = File(p);

        if (_logFile != null && await _logFile!.exists()) {
          final length = await _logFile!.length();
          if (length > _maxLogFileSizeBytes) {
            // 如果日志过大，清空重写
            await _logFile!.writeAsString('');
          }
        }
      } catch (e) {
        debugPrint("LogManager init error: $e");
      }
    }
  }

  Future<void> setLoggingEnabled(bool enabled) async {
    _isLoggingEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_logging', enabled);
    try {
      var p = await PathProvider.getPath("logs/app_logs.txt");
      _logFile = File(p);

      if (_logFile != null && await _logFile!.exists()) {
        final length = await _logFile!.length();
        if (length > _maxLogFileSizeBytes) {
          // 如果日志过大，清空重写
          await _logFile!.writeAsString('');
        }
      }
    } catch (e) {
      debugPrint("LogManager init error: $e");
    }
    notifyListeners();
  }

  void addLog(String log) {
    if (!_isLoggingEnabled || _logFile == null) return;

    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $log\n';

    try {
      _logFile!.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      // 捕获异常，防止在这里死循环抛出 print
    }
  }

  Future<String> getLogs() async {
    if (_logFile == null) return "ERROR_NOT_INIT";
    if (await _logFile!.exists()) {
      try {
        var str = await _logFile!.readAsString();
        if (str.isEmpty) return "ERROR_NONE";
        return str;
      } catch (e) {
        return "ERROR_READ_FAIL:$e";
      }
    }
    return "ERROR_NONE";
  }

  Future<void> clearLogs() async {
    if (_logFile != null) {
      try {
        if (await _logFile!.exists()) {
          await _logFile!.writeAsString('');
        }
      } catch (e) {
        debugPrint("Clear log error: $e");
      }
    }
  }
}
