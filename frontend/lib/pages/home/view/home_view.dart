import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../authentication/bloc/authentication_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Builder(
            builder: (context) {
              final userId = context.select(
                    (AuthenticationBloc bloc) => bloc.state.user.jwt,
              );
              return Text('UserID: $userId');
            },
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthenticationBloc>().add(
                AuthenticationLogoutRequested(),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}