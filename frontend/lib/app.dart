import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/registration_repository.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/authentication_repository.dart';
import 'repositories/user_repository.dart';

const _brandColor = Colors.orange;

class CodetestApp extends StatelessWidget {
  final SharedPreferences pref;
  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  final ContestRepository _contestRepository;
  final RegistrationRepository _registrationRepository;
  final TaskRepository _taskRepository;

  CodetestApp(this.pref, {super.key})
      : _authenticationRepository = AuthenticationRepository(),
        _userRepository = UserRepository(pref),
        _contestRepository = ContestRepository(),
        _registrationRepository = RegistrationRepository(),
        _taskRepository = TaskRepository();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: _authenticationRepository,
        ),
        RepositoryProvider.value(
          value: _userRepository,
        ),
        RepositoryProvider.value(
          value: _contestRepository,
        ),
        RepositoryProvider.value(
          value: _registrationRepository,
        ),
        RepositoryProvider.value(
          value: _taskRepository,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Codetest App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _brandColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _brandColor,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: EasyDynamicTheme.of(context).themeMode,
        routerConfig: AppRouter.router,
/*        onGenerateRoute: (settings) {
          var path = Uri.parse(settings.name ?? "/");
          if (path.pathSegments.isEmpty) {
            return MaterialPageRoute(builder: (context) {
              return const HomePage();
            });
          }
          switch (path.pathSegments[0]) {
            case "contest":
              if (path.pathSegments.length == 2) {
                try {
                  var id = int.tryParse(path.pathSegments[1]);
                  if (id != null) {
                    return MaterialPageRoute(builder: (context) {
                      return ContestPage(contestId: id);
                    });
                  }
                } catch (e) {
                  return MaterialPageRoute(builder: (context) {
                    return const HomePage();
                  });
                }
              }
              break;
            case "login":
              return MaterialPageRoute(builder: (context) {
                return const LoginPage();
              });
              break;
            case "register":
              return MaterialPageRoute(builder: (context) {
                return const RegistrationPage();
              });
              break;
          }
        },*/
      ),
    );
  }
}
