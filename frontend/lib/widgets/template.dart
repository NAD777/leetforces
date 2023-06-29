import 'package:flutter/material.dart';

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
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline_rounded),
              ),
              IconButton(
                onPressed: () {
                  /*context.read<AuthenticationBloc>().add(
                        AuthenticationLogoutRequested(),
                      );*/
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          // ContestsView(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            sliver: SliverFillRemaining(
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
