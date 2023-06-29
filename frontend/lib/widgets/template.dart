import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Template extends StatelessWidget {
  const Template({required this.content, super.key});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: GestureDetector(
                child: const Text('LeetForces'),
                onTap: () {
                  context.replace("/");
                }),
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
