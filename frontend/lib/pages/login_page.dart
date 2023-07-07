import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/authentication_repository.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  bool loginInProgress = false;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TextFormField inputField(String name, bool hidden,
      TextEditingController controller, FormFieldValidator<String> validator) {
    return TextFormField(
      key: Key('loginForm_${name.toLowerCase()}Input_textField'),
      decoration: InputDecoration(
        labelText: name,
      ),
      textInputAction: TextInputAction.next,
      controller: controller,
      validator: validator,
      obscureText: hidden,
    );
  }

  Widget loginButton() {
    return loginInProgress
        ? const CircularProgressIndicator()
        : ElevatedButton(
            key: const Key('loginForm_continue_elevatedButton'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  loginInProgress = true;
                });
                RepositoryProvider.of<AuthenticationRepository>(context)
                    .logIn(
                        username: usernameController.text,
                        password: passwordController.text)
                    .then((value) {
                  setState(() {
                    loginInProgress = false;
                  });
                  RepositoryProvider.of<UserRepository>(context).setUser(value);
                  context.go("/");
                }).catchError((e) {
                  print(e);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                        const SnackBar(content: Text("Invalid credentials")));
                  setState(() {
                    loginInProgress = false;
                  });
                });
              }
            },
            child: const Text('Login'),
          );
  }

  Widget registerButton(BuildContext context) {
    return ElevatedButton(
      key: const Key('loginForm_register_elevatedButton'),
      onPressed: () {
        context.go("/register");
      },
      child: const Text('Register'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            child: const Text('LeetForces'),
            onTap: () {
              context.go("/");
            }),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 20,
              ),
              width: 500,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    inputField("username", false, usernameController,
                        (String? val) {
                      if (val == null) {
                        return null;
                      }
                      return val.length >= 6 ? null : "Invalid length";
                    }),
                    inputField("password", true, passwordController,
                        (String? val) {
                      if (val == null) {
                        return null;
                      }
                      return val.length >= 6 ? null : "Invalid length";
                    }),
                    const SizedBox(height: 30),
                    loginButton(),
                    const SizedBox(height: 25),
                    registerButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
