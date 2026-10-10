// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_complete_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the completion of a single list entry, one controller per todo id.
///
/// The state is a plain `AsyncValue`: `loading` while the write is in flight,
/// `data` once the todo is completed and `error` when the domain refused it.
/// `AsyncValue` asserts that a new `loading` never carries the previous error,
/// so a stale failure cannot be reported twice.
///
/// Being a family keeps that in-flight flag per row: a tap on one entry never
/// blocks another, and the entry that was tapped reports its own failure.

@ProviderFor(TodoCompleteController)
final todoCompleteControllerProvider = TodoCompleteControllerFamily._();

/// Drives the completion of a single list entry, one controller per todo id.
///
/// The state is a plain `AsyncValue`: `loading` while the write is in flight,
/// `data` once the todo is completed and `error` when the domain refused it.
/// `AsyncValue` asserts that a new `loading` never carries the previous error,
/// so a stale failure cannot be reported twice.
///
/// Being a family keeps that in-flight flag per row: a tap on one entry never
/// blocks another, and the entry that was tapped reports its own failure.
final class TodoCompleteControllerProvider
    extends $NotifierProvider<TodoCompleteController, AsyncValue<void>> {
  /// Drives the completion of a single list entry, one controller per todo id.
  ///
  /// The state is a plain `AsyncValue`: `loading` while the write is in flight,
  /// `data` once the todo is completed and `error` when the domain refused it.
  /// `AsyncValue` asserts that a new `loading` never carries the previous error,
  /// so a stale failure cannot be reported twice.
  ///
  /// Being a family keeps that in-flight flag per row: a tap on one entry never
  /// blocks another, and the entry that was tapped reports its own failure.
  TodoCompleteControllerProvider._({
    required TodoCompleteControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'todoCompleteControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todoCompleteControllerHash();

  @override
  String toString() {
    return r'todoCompleteControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TodoCompleteController create() => TodoCompleteController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TodoCompleteControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todoCompleteControllerHash() =>
    r'618dc2234343e2e10ff5572f12975f9cd2d30cad';

/// Drives the completion of a single list entry, one controller per todo id.
///
/// The state is a plain `AsyncValue`: `loading` while the write is in flight,
/// `data` once the todo is completed and `error` when the domain refused it.
/// `AsyncValue` asserts that a new `loading` never carries the previous error,
/// so a stale failure cannot be reported twice.
///
/// Being a family keeps that in-flight flag per row: a tap on one entry never
/// blocks another, and the entry that was tapped reports its own failure.

final class TodoCompleteControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TodoCompleteController,
          AsyncValue<void>,
          AsyncValue<void>,
          AsyncValue<void>,
          String
        > {
  TodoCompleteControllerFamily._()
    : super(
        retry: null,
        name: r'todoCompleteControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives the completion of a single list entry, one controller per todo id.
  ///
  /// The state is a plain `AsyncValue`: `loading` while the write is in flight,
  /// `data` once the todo is completed and `error` when the domain refused it.
  /// `AsyncValue` asserts that a new `loading` never carries the previous error,
  /// so a stale failure cannot be reported twice.
  ///
  /// Being a family keeps that in-flight flag per row: a tap on one entry never
  /// blocks another, and the entry that was tapped reports its own failure.

  TodoCompleteControllerProvider call(String todoId) =>
      TodoCompleteControllerProvider._(argument: todoId, from: this);

  @override
  String toString() => r'todoCompleteControllerProvider';
}

/// Drives the completion of a single list entry, one controller per todo id.
///
/// The state is a plain `AsyncValue`: `loading` while the write is in flight,
/// `data` once the todo is completed and `error` when the domain refused it.
/// `AsyncValue` asserts that a new `loading` never carries the previous error,
/// so a stale failure cannot be reported twice.
///
/// Being a family keeps that in-flight flag per row: a tap on one entry never
/// blocks another, and the entry that was tapped reports its own failure.

abstract class _$TodoCompleteController extends $Notifier<AsyncValue<void>> {
  late final _$args = ref.$arg as String;
  String get todoId => _$args;

  AsyncValue<void> build(String todoId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
