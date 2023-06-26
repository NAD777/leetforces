import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/registration_repository.dart';
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

  CodetestApp(this.pref, {super.key})
      : _authenticationRepository = AuthenticationRepository(),
        _userRepository = UserRepository(pref),
        _contestRepository = ContestRepository(),
        _registrationRepository = RegistrationRepository();

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
      ],
      child: MaterialApp(
        initialRoute: '/',
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
        onGenerateRoute: AppRouter.router.generator,
      ),
    );
  }
}
