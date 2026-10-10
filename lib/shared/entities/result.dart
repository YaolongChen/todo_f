import 'package:todo/core/errors/failures.dart';

/// Outcome of an operation that can fail.
///
/// The two cases are constructed through [Result.ok] and [Result.error] only:
/// [Ok] and [Error] keep their constructors private so a `Result` is always
/// created through the factories, and the public surface stays on this type
/// rather than on its subclasses.
///
/// Callers still destructure with the subtype patterns, which stays exhaustive
/// because the class is `sealed`:
///
/// ```dart
/// switch (result) {
///   case Ok(:final value): ...
///   case Error(:final error): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Wraps a successful [value].
  const factory Result.ok(T value) = Ok._;

  /// Wraps a failed [error].
  const factory Result.error(Failure error) = Error._;
}

/// Successful outcome.
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// The produced value.
  final T value;
}

/// Failed outcome.
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// The failure that explains the outcome.
  final Failure error;
}
