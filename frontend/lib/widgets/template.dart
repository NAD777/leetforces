import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:go_router/go_router.dart';

class Template extends StatefulWidget {
  const Template({
    required this.content,
    super.key,
    this.scrollable = true,
    this.isAdminPage = false,
    this.onFabPressed,
    this.fabTooltip,
  });

  final Widget content;
  final bool scrollable;
  final bool isAdminPage;
  final Function()? onFabPressed;
  final String? fabTooltip;

  @override
  State<Template> createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  bool isAdmin = false;
  bool inProgress = true;

  @override
  void initState() {
    super.initState();
    RepositoryProvider.of<UserRepository>(context).getRole().then((value) {
      if (value == "Role.admin" || value == "Role.superAdmin") {
        setState(() {
          isAdmin = true;
        });
      } else if (widget.isAdminPage) {
        context.go('/');
      }
      setState(() {
        inProgress = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var user = RepositoryProvider.of<UserRepository>(context).user;

    var padding = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Center(child: widget.content),
    );

    var body = widget.scrollable
        ? SingleChildScrollView(
            child: padding,
          )
        : padding;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: !widget.scrollable ? Colors.transparent : null,
        title: GestureDetector(
            child: const Text('LeetForces'),
            onTap: () {
              context.go("/");
            }),
        actions: user != null
            ? <Widget>[
                if (isAdmin) ...[
                  TextButton(
                    onPressed: () {
                      context.go('/admin/task');
                    },
                    child: Text(
                      'Create task',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.go('/admin/tag');
                    },
                    tooltip: 'Manage tags',
                    icon: const Icon(Icons.tag),
                  ),
                ],
                IconButton(
                  onPressed: () {
                    context.go("/profile");
                  },
                  tooltip: 'Profile',
                  icon: const Icon(Icons.person_outline_rounded),
                ),
                IconButton(
                  onPressed: () {
                    RepositoryProvider.of<UserRepository>(context).setUser("");
                    context.go("/login");
                  },
                  tooltip: 'Log out',
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
      body: widget.isAdminPage && inProgress
          ? const Center(child: CircularProgressIndicator())
          : body,
      floatingActionButton: widget.onFabPressed != null && isAdmin
          ? FloatingActionButton(
              onPressed: widget.onFabPressed,
              tooltip: widget.fabTooltip,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
