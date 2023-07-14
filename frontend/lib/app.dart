import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/registration_repository.dart';
import 'package:frontend/repositories/tag_repository.dart';
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
  final TagRepository _tagRepository;

  CodetestApp(this.pref, {super.key})
      : _authenticationRepository = AuthenticationRepository(),
        _userRepository = UserRepository(pref),
        _contestRepository = ContestRepository(),
        _registrationRepository = RegistrationRepository(),
        _taskRepository = TaskRepository(),
        _tagRepository = TagRepository();

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
        RepositoryProvider.value(
          value: _tagRepository,
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'LeetForces',
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
      ),
    );
  }
}
