/// Date and time formatting helpers shared across features.
abstract final class DateFormatters {
  /// Formats [dateTime] as `yyyy-MM-dd HH:mm` in the device's local time.
  static String formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${local.year}-${_twoDigits(local.month)}-${_twoDigits(local.day)} '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
