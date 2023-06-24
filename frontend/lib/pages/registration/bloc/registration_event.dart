part of 'registration_bloc.dart';

@immutable
sealed class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object> get props => [];
}

final class RegistrationUsernameChanged extends RegistrationEvent {
  const RegistrationUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

final class RegistrationPasswordChanged extends RegistrationEvent {
  const RegistrationPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

final class RegistrationEmailChanged extends RegistrationEvent {
  const RegistrationEmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

final class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted();
}
