import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/pages/authentication/bloc/authentication_bloc.dart';
import 'package:frontend/pages/home/view/home_page.dart';
import 'package:frontend/pages/login/view/login_page.dart';
import 'package:frontend/pages/splash/view/splash_page.dart';
import 'package:frontend/repositories/contest_repository/contest_repository.dart';
import 'package:frontend/repositories/registeration_repository/registration_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'repositories/authentication_repository/authentication_repository.dart';
import 'repositories/user_repository/user_repository.dart';

const _brandColor = Colors.orange;

class CodetestApp extends StatefulWidget {
  final SharedPreferences pref;

  const CodetestApp(this.pref, {super.key});

  @override
  State<CodetestApp> createState() => _CodetestAppState(pref);
}

class _CodetestAppState extends State<CodetestApp> {
  late final AuthenticationRepository _authenticationRepository;
  late final UserRepository _userRepository;
  late final ContestRepository _contestRepository;
  late final RegistrationRepository _registrationRepository;
  final SharedPreferences pref;

  _CodetestAppState(this.pref);

  @override
  void initState() {
    super.initState();
    _authenticationRepository = AuthenticationRepository();
    _userRepository = UserRepository(pref);
    _contestRepository = ContestRepository();
    _registrationRepository = RegistrationRepository();
  }

  @override
  void dispose() {
    _authenticationRepository.dispose();
    super.dispose();
  }

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
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
          authenticationRepository: _authenticationRepository,
          userRepository: _userRepository,
        ),
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
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
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  HomePage.route(
                    RepositoryProvider.of<ContestRepository>(context),
                  ),
                  (route) => false,
                );
              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  LoginPage.route(),
                  (route) => false,
                );
              case AuthenticationStatus.initial:
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}
