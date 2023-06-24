import 'dart:async';
import 'dart:convert';
import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

enum AuthenticationStatus { authenticated, unauthenticated, initial }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.initial;
    yield* _controller.stream;
  }

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
      _controller.add(AuthenticationStatus.authenticated);
      return json['data'];
    } else {
      throw Exception(json['message']);
    }
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void dispose() => _controller.close();
}
