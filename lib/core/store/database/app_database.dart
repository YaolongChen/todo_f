import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:todo/core/store/database/table/todos_table.dart';

part 'app_database.g.dart';

/// Local database backing the application.
///
/// The schema lives in the neighbouring `table/` folder; this file owns the
/// connection and the provider that exposes it.
@DriftDatabase(tables: [Todos])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? queryExecutor])
    : super(queryExecutor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(),
    );
  }
}

/// Single storage engine instance for the whole application.
///
/// The connection stays open for as long as the container that owns it and is
/// closed when that container is disposed. Tests replace it through
/// `overrideWith` to run against an in-memory database.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
}
