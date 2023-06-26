import 'dart:async';
import 'dart:convert';
import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

class AuthenticationRepository {
  Future<String> logIn({
    required String username,
    required String password,
  }) async {
    var response = await http.post(Uri.parse("$host/login"),
        body: jsonEncode(<String, String>{
          "login": username,
          "password": password,
        }),
        headers: <String, String>{"Content-Type": "application/json"});
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return json['data'];
    } else {
      throw Exception(json['message']);
    }
  }
}
