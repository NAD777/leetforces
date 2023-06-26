import 'package:fluro/fluro.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/registration_page.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/task_repository.dart';

import 'pages/contest_view.dart';

class AppRouter {
  static final router = FluroRouter();
  static final contestRepository = ContestRepository();
  static final taskRepository = TaskRepository();

  static final Handler homeHandler = Handler(handlerFunc: (context, params) {
    return HomePage(contestRepository: contestRepository);
  });
  static final Handler contestHandler = Handler(handlerFunc: (context, params) {
    return ContestPage(
      contestRepository: contestRepository,
      taskRepository: taskRepository,
      contestId: int.parse(params["id"]![0]),
    );
  });
  static final Handler registrationHandler =
      Handler(handlerFunc: (context, params) {
    return const RegistrationPage();
  });
  static final Handler loginHandler = Handler(handlerFunc: (context, params) {
    return const LoginPage();
  });

  static void setupRouter() {
    router.define("/", handler: homeHandler);
    router.define("/contest/:id", handler: contestHandler);
    router.define("/register", handler: registrationHandler);
    router.define("/login", handler: loginHandler);
  }
}
