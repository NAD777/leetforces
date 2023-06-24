part of 'authentication_bloc.dart';

@immutable
class AuthenticationState extends Equatable {
  AuthenticationState._({
    this.status = AuthenticationStatus.unauthenticated,
    this.user = User.empty,
  }) {
    print(1);
  }

  AuthenticationState.unknown() : this._();

  AuthenticationState.authenticated(User user)
      : this._(status: AuthenticationStatus.authenticated, user: user);

  AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  final AuthenticationStatus status;
  final User user;

  @override
  List<Object> get props => [status, user];
}
