import 'package:frontend/pages/admin_tag_page.dart';
import 'package:frontend/pages/pages.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: "/",
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: "/login",
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: "/register",
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(
        path: "/contest/:id",
        builder: (context, state) =>
            ContestPage(contestId: int.parse(state.pathParameters["id"]!)),
      ),
      GoRoute(
        path: "/task/:id",
        builder: (context, state) => TaskPage(
          taskId: int.parse(state.pathParameters["id"]!),
        ),
      ),
      GoRoute(
        path: "/admin/contest/:id",
        builder: (context, state) => AdminContestPage(
          contestId: int.parse(state.pathParameters["id"]!),
        ),
      ),
      GoRoute(
        path: "/admin/contest",
        builder: (context, state) => const AdminContestCreatePage(),
      ),
      GoRoute(
        path: "/admin/task",
        builder: (context, state) => const AdminTaskPage(),
      ),
      GoRoute(
        path: "/admin/task/:id",
        builder: (context, state) => AdminTaskPage(
          taskId: int.parse(state.pathParameters["id"]!),
        ),
      ),
      GoRoute(
        path: "/profile",
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: "/admin/tag/:id",
        builder: (context, state) =>
            AdminTagPage(tagId: int.parse(state.pathParameters["id"]!)),
      ),
      GoRoute(
        path: "/admin/tag",
        builder: (context, state) => const AdminTagList(),
      )
    ],
  );
}
