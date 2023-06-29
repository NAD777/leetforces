import 'package:frontend/pages/contest_view.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/registration_page.dart';
import 'package:frontend/pages/task_page.dart';
import 'package:go_router/go_router.dart';


class AppRouter {
  static final router = GoRouter(routes: [
    GoRoute(
      path: "/",
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: "/register",
      builder: (context, state) => const RegistrationPage(),
    ),
    GoRoute(
      path: "/login",
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: "/contest/:id",
      builder: (context, state) =>
          ContestPage(contestId: int.parse(state.pathParameters["id"]!)),
    ),
    GoRoute(path: "/task/:id",
    builder: (context, state) => TaskPage(taskId: int.parse(state.pathParameters["id"]!)))
  ]);
}