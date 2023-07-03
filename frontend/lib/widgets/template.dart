import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/user_repository.dart';
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
                  context.go("/");
                }),
            actions: [
              IconButton(
                onPressed: () {
                  context.go("/profile");
                },
                icon: const Icon(Icons.person_outline_rounded),
              ),
              IconButton(
                onPressed: () {
                  RepositoryProvider.of<UserRepository>(context).setUser("");
                  context.go("/login");
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
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
