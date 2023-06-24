import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../bloc/registration_bloc.dart';

class RegistrationForm extends StatelessWidget {
  const RegistrationForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegistrationBloc, RegistrationState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Authentication Failure')),
            );
        } else if (state.status.isSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Registration Success')),
            );
          Navigator.of(context).pop();
        }
      },
      child: Center(
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
              // height: 500,
              width: 500,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _UsernameInput(),
                  _EmailInput(),
                  _PasswordInput(),
                  const SizedBox(height: 30),
                  _RegistrationButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) => previous.username != current.username,
      builder: (context, state) {
        return TextFormField(
          key: const Key('registrationForm_usernameInput_textField'),
          decoration: InputDecoration(
            labelText: 'Username',
            errorText:
                state.username.displayError != null ? 'Invalid username' : null,
          ),
          textInputAction: TextInputAction.next,
          onChanged: (username) =>
              context.read<RegistrationBloc>().add(RegistrationUsernameChanged(username)),
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextFormField(
          key: const Key('registrationForm_emailInput_textField'),
          decoration: InputDecoration(
            labelText: 'Email',
            errorText:
            state.email.displayError != null ? 'Invalid email' : null,
          ),
          textInputAction: TextInputAction.next,
          onChanged: (email) =>
              context.read<RegistrationBloc>().add(RegistrationEmailChanged(email)),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextFormField(
          key: const Key('registrationForm_passwordInput_textField'),
          decoration: InputDecoration(
            labelText: 'Password',
            errorText:
                state.password.displayError != null ? 'Invalid password' : null,
          ),
          obscureText: true,
          onChanged: (password) =>
              context.read<RegistrationBloc>().add(RegistrationPasswordChanged(password)),
        );
      },
    );
  }
}

class _RegistrationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('registrationForm_continue_elevatedButton'),
                onPressed: state.isValid
                    ? () {
                        context.read<RegistrationBloc>().add(const RegistrationSubmitted());
                      }
                    : null,
                child: const Text('Registration'),
              );
      },
    );
  }
}
