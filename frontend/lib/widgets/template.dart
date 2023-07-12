import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';

class Template extends StatelessWidget {
  const Template({required this.content, super.key, this.scrollable = true});

  final Widget content;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    var user = RepositoryProvider.of<UserRepository>(context).user;

    var padding = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Center(child: content),
    );

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            child: const Text('LeetForces'),
            onTap: () {
              context.go("/");
            }),
        actions: user != null
            ? <IconButton>[
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
              ]
            : [
                TextButton(
                  child: const Text("Login"),
                  onPressed: () {
                    context.go("/login");
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
      ),
      body: scrollable
          ? SingleChildScrollView(
              child: padding,
            )
          : padding,
    );
  }
}
