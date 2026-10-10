import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/features/todo/presentation/screens/todo_create_screen.dart';
import 'package:todo/features/todo/presentation/screens/todo_list_screen.dart';
import 'package:todo/shared/constants/route_names.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  debugLogDiagnostics: true,
  initialLocation: RouteNames.todoList,
  routes: [
    GoRoute(
      name: RouteNames.todoList,
      path: RouteNames.todoList,
      builder: (context, state) => const TodoListScreen(),
    ),
    GoRoute(
      name: RouteNames.todoCreate,
      path: RouteNames.todoCreate,
      builder: (context, state) => const TodoCreateScreen(),
    ),
  ],
);
