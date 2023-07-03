import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/env/config.dart';

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

  Future<String> getRole() async {
    if (user?.jwt == null) {
      return "Role.guest";
    }
    var response = await http.get(Uri.parse("$host/check_privileges"),
        headers: <String, String>{
          "Authorization": _user!.jwt,
          "Content-Type": "application/json"
        },);
    return response.body;
  }
}
