import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/registration_repository.dart';
import 'package:go_router/go_router.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegistrationPage();
}

class _RegistrationPage extends State<StatefulWidget> {
  bool registrationInProcess = false;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TextFormField inputField(String name, TextEditingController controller,
      FormFieldValidator<String> validator) {
    return TextFormField(
      key: Key('registrationForm_${name.toLowerCase()}Input_textField'),
      decoration: InputDecoration(
        labelText: name,
      ),
      obscureText: name == 'password',
      textInputAction: TextInputAction.next,
      controller: controller,
      validator: validator,
    );
  }

  Widget registrationButton(BuildContext context) => registrationInProcess
      ? const CircularProgressIndicator()
      : ElevatedButton(
          key: const Key('registrationForm_continue_elevatedButton'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() {
                registrationInProcess = true;
              });
              RepositoryProvider.of<RegistrationRepository>(context)
                  .register(
                      username: usernameController.text,
                      email: emailController.text,
                      password: passwordController.text)
                  .then((value) {
                setState(() {
                  registrationInProcess = false;
                });
                context.go("/login");
              }).catchError((e) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(e.toString())));
                setState(() {
                  registrationInProcess = false;
                });
              });
            }
          },
          child: const Text('Registration'),
        );

  @override
  Widget build(BuildContext context) => Scaffold(
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
                      inputField("username", usernameController, (String? val) {
                        if (val == null) {
                          return null;
                        }
                        return val.length >= 6 ? null : "Invalid length";
                      }),
                      inputField("email", emailController, (String? val) {
                        if (val == null) {
                          return null;
                        }
                        return val.length >= 6 ? null : "Invalid length";
                      }),
                      inputField("password", passwordController, (String? val) {
                        if (val == null) {
                          return null;
                        }
                        return val.length >= 6 ? null : "Invalid length";
                      }),
                      const SizedBox(height: 30),
                      registrationButton(context),
                      ElevatedButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
