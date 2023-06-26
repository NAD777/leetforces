import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String jwt;

  const User(this.jwt);

  @override
  List<Object> get props => [jwt];

  static const empty = User('-');
}
