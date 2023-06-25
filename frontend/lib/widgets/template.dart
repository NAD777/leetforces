import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../pages/authentication/bloc/authentication_bloc.dart';

class Template extends StatelessWidget {
  const Template({required this.content, super.key});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('LeetForces'),
            actions: [
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(
              //     theme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              //   ),
              // ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline_rounded),
              ),
              IconButton(
                onPressed: () {
                  context.read<AuthenticationBloc>().add(
                        AuthenticationLogoutRequested(),
                      );
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          // ContestsView(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            sliver: SliverToBoxAdapter(
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
