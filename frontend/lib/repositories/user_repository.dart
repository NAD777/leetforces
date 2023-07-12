import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/tag.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/env/config.dart';

import '../models/userinfo.dart';

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
    var response = await http.get(
      Uri.parse("$host/check_privileges"),
      headers: <String, String>{
        "Authorization": _user!.jwt,
      },
    );
    return response.body;
  }

  Future<UserInfo> getUserInfo() async {
    if (user?.jwt == null) {
      return UserInfo(0, "guest", "Role.guest", "none", []);
    }
    var response = await http.get(
      Uri.parse("$host/current_user_info"),
      headers: <String, String>{
        "Authorization": _user!.jwt,
      },
    );
    var resp = jsonDecode(response.body) as Map<String, dynamic>;
    var tags = (resp["tags"] as List<dynamic>)
        .map((tag) => Tag(tag["id"], tag["name"]))
        .toList();
    return UserInfo(
      resp["id"],
      resp["login"],
      resp["role"],
      resp["email"],
      tags,
    );
  }

  Future<UserInfo?> searchUserInfo(String login) async {
    var response = await http.get(
      Uri.parse("$host/public_user_info_by_login/$login"),
      headers: <String, String>{
        "Authorization": _user!.jwt,
      },
    );
    var resp = jsonDecode(response.body) as Map<String, dynamic>;
    var tags = (resp["tags"] as List<dynamic>)
        .map((tag) => Tag(tag["id"], tag["name"]))
        .toList();
    return UserInfo(
      resp["id"],
      resp["login"],
      resp["role"],
      resp["email"],
      tags,
    );
  }
}
