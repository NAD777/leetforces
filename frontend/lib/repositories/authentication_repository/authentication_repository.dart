import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum AuthenticationStatus { unknown, authenticated, unauthenticated }

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<String> logIn({
    required String username,
    required String password,
  }) async {
    http.Response response = await http.post(
      Uri.parse("/login"),
      body: jsonEncode(<String, String>{
        "login": username,
        "password": password,
      }),
    );
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
