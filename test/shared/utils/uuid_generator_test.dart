import 'package:flutter_test/flutter_test.dart';
import 'package:todo/shared/utils/uuid_generator.dart';

void main() {
  group('UuidGenerator.generate', () {
    test('returns an RFC 4122 version 4 UUID', () {
      final id = UuidGenerator.generate();

      expect(
        id,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
            r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });

    test('never repeats a uuid across many generations', () {
      final ids = List.generate(1000, (_) => UuidGenerator.generate());

      expect(ids.toSet(), hasLength(ids.length));
    });
  });
}
