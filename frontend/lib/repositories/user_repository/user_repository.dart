import 'models/user.dart';

class UserRepository {
  User? _user;

  User? get user {
    return _user!;
  }

  void setUser(String jwt) {
    _user = User(jwt);
  }
}