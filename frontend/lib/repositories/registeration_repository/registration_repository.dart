import 'dart:async';
import 'dart:convert';
import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

enum RegistrationStatus { unknown, registered }

class RegistrationRepository {
  final _controller = StreamController<RegistrationStatus>();

  Stream<RegistrationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield RegistrationStatus.unknown;
    yield* _controller.stream;
  }

  void logOut() {
    _controller.add(RegistrationStatus.unknown);
  }

  Future<void> register(
      {required String username,
      required String email,
      required String password}) async {
    var response = await http.post(Uri.parse("$host/register"),
        body: jsonEncode(<String, String>{
          "login": username,
          "password": password,
          "email":email
        }),
        headers: <String, String>{"Content-Type": "application/json"});
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      _controller.add(RegistrationStatus.registered);
    } else {
      throw Exception(json['message']);
    }
  }

  void dispose() => _controller.close();
}
