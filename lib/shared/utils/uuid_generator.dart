import 'package:uuid/uuid.dart';

/// Builds RFC 4122 version 4 (random) identifiers.
///
/// Lives in `shared/utils` so every feature mints ids through one place instead
/// of spreading `Uuid()` calls around, and so tests can swap in a deterministic
/// generator through the `idGenerator` seam of the use case that creates todos.
///
/// Version 4 ids are random and therefore unordered: the local cache sorts by
/// `createdAt`, which keeps "newest first" independent of the id format and safe
/// for rows written before this UUID switch.
abstract final class UuidGenerator {
  static const Uuid _uuid = Uuid();

  /// Returns a new UUID such as `3f1c9b6a-2d4e-4f7b-9c1d-8a5e2b0f6d34`.
  static String generate() => _uuid.v4();
}
