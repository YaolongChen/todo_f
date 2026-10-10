import 'package:flutter_test/flutter_test.dart';
import 'package:todo/shared/utils/date_formatters.dart';

void main() {
  group('DateFormatters.formatDateTime', () {
    test('formats a DateTime as yyyy-MM-dd HH:mm', () {
      expect(
        DateFormatters.formatDateTime(DateTime(2024, 5, 6, 8, 9)),
        '2024-05-06 08:09',
      );
    });

    test('pads month, day, hour and minute to two digits', () {
      expect(
        DateFormatters.formatDateTime(DateTime(2024, 1, 2, 3, 4)),
        '2024-01-02 03:04',
      );
    });

    test('keeps already two digit components unchanged', () {
      expect(
        DateFormatters.formatDateTime(DateTime(2024, 12, 31, 23, 59)),
        '2024-12-31 23:59',
      );
    });

    test('formats midnight as 00:00', () {
      expect(
        DateFormatters.formatDateTime(DateTime(2024, 5, 6)),
        '2024-05-06 00:00',
      );
    });

    test('renders the same instant identically for UTC and local input', () {
      final local = DateTime(2024, 5, 6, 8, 9);

      expect(
        DateFormatters.formatDateTime(local.toUtc()),
        DateFormatters.formatDateTime(local),
      );
    });
  });
}
