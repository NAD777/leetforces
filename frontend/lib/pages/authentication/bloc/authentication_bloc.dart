import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../../../repositories/authentication_repository/authentication_repository.dart';
import '../../../repositories/user_repository/models/user.dart';
import '../../../repositories/user_repository/user_repository.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
  })  : _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        super(userRepository.user == null
          ? AuthenticationState.unauthenticated()
          : AuthenticationState.authenticated(userRepository.user!)) {
    print(userRepository.user);
    on<_AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) => add(_AuthenticationStatusChanged(status)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;
  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    return super.close();
  }

  Future<void> _onAuthenticationStatusChanged(
    _AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    switch (event.status) {
      case AuthenticationStatus.unauthenticated:
        _userRepository.setUser("");
        return emit(AuthenticationState.unauthenticated());
      case AuthenticationStatus.authenticated:
        final user = _userRepository.user;
        return emit(
          user != null
              ? AuthenticationState.authenticated(user)
              : AuthenticationState.unauthenticated(),
        );
      case AuthenticationStatus.initial:
        return emit(_userRepository.user == null
            ? AuthenticationState.unknown()
            : AuthenticationState.authenticated(_userRepository.user!));
    }
  }

  void _onAuthenticationLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) {
    _authenticationRepository.logOut();
  }
}
