import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class UserRepository {
  UserRepository(this.prefs) {
    if (prefs.containsKey("jwt")) {
      _user = User(prefs.getString("jwt")!);
    }
  }

  User? _user;
  final SharedPreferences prefs;

  User? get user {
    return _user;
  }

  void setUser(String jwt) {
    if (jwt.isEmpty) {
      _user = null;
      prefs.remove("jwt");
    } else {
      _user = User(jwt);
      prefs.setString("jwt", jwt);
    }
  }
}