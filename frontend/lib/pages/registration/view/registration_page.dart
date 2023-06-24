import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/registeration_repository/registration_repository.dart';

import '../bloc/registration_bloc.dart';
import 'registration_form.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const RegistrationPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Registration'),
      ),
      body: BlocProvider(
        create: (context) {
          return RegistrationBloc(
            RepositoryProvider.of<RegistrationRepository>(context),
          );
        },
        child: const RegistrationForm(),
      ),
    );
  }
}
