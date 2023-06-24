part of 'registration_bloc.dart';

@immutable
final class RegistrationState extends Equatable {
  final FormzSubmissionStatus status;
  final Username username;
  final Password password;
  final Email email;
  final bool isValid;

  const RegistrationState({
    this.status = FormzSubmissionStatus.initial,
    this.username = const Username.pure(),
    this.password = const Password.pure(),
    this.email = const Email.pure(),
    this.isValid = false,
  });

  RegistrationState copyWith({
    FormzSubmissionStatus? status,
    Username? username,
    Password? password,
    Email? email,
    bool? isValid,
}) {
    return RegistrationState(
      status: status ?? this.status,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [status, username, password, email];
}
