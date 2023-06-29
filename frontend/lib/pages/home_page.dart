import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/widgets/template.dart';
import 'package:go_router/go_router.dart';

import '../models/contest.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<ContestSimple> list;

  @override
  void initState() {
    RepositoryProvider.of<ContestRepository>(context)
        .getContests()
        .then((value) {
      setState(() {
        list = value;
      });
    });
    list = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      content: Column(
        children: [
          for (var e in list)
            Card(
              child: ListTile(
                title: Text(e.name),
                onTap: () {
                  context.replace("/contest/${e.id}");
                },
              ),
            ),
        ],
      ),
    );
  }
}
