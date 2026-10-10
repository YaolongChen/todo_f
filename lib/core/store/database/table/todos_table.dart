import 'package:drift/drift.dart';

/// Physical storage schema for todo records.
///
/// This is storage infrastructure only: the business entity lives in
/// `features/todo/domain/entities/todo.dart`, and the feature's data layer maps
/// between that entity and the generated `TodoRow`.
@DataClassName('TodoRow')
class Todos extends Table {
  /// Unique identifier of the todo. Never null, never empty.
  TextColumn get id => text()();

  /// Human readable content of the todo. Never null, never empty.
  TextColumn get content => text()();

  /// Creation timestamp of the todo.
  DateTimeColumn get createdAt => dateTime()();

  /// Whether the todo has been completed. Defaults to `false`.
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
