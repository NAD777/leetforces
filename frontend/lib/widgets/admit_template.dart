import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:frontend/widgets/template.dart';
import 'package:go_router/go_router.dart';

class AdminTemplate extends StatefulWidget {
  @deprecated
  const AdminTemplate({super.key, required this.content});

  final Widget content;

  @override
  State<AdminTemplate> createState() => _AdminTemplateState();
}

class _AdminTemplateState extends State<AdminTemplate> {
  bool admin = false;

  @override
  void initState() {
    super.initState();
    RepositoryProvider.of<UserRepository>(context).getRole().then((value) {
      if (value == "Role.admin" || value == "Role.superAdmin") {
        setState(() {
          admin = true;
        });
      } else {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      content: admin
          ? widget.content
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
