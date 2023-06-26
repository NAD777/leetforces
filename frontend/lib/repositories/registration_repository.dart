import 'dart:async';
import 'dart:convert';
import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

class RegistrationRepository {
  Future<void> register(
      {required String username,
      required String email,
      required String password}) async {
    var response = await http.post(Uri.parse("$host/register"),
        body: jsonEncode(<String, String>{
          "login": username,
          "password": password,
          "email": email
        }),
        headers: <String, String>{"Content-Type": "application/json"});
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(json['message']);
    }
  }
}
