import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class AppLogger {
  AppLogger(String name) : _logger = Logger(name) {
    if (!_printerInitialized) {
      _printerInitialized = true;
      Logger.root.onRecord.listen(_printLog);
    }
  }

  static bool _printerInitialized = false;

  final Logger _logger;

  void _printLog(LogRecord record) {
    debugPrint(
      "${record.time} [${record.loggerName}] ${record.message}${record.error != null ? "\n${record.error.toString()}" : ""}${record.stackTrace != null ? "\n${record.stackTrace}" : ""}",
      wrapWidth: 120,
    );
  }

  void i(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  void w(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  void e(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.shout(message, error, stackTrace);
  }
}
