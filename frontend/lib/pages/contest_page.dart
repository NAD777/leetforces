import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/widgets/tags_list_view.dart';
import 'package:frontend/widgets/template.dart';
import 'package:go_router/go_router.dart';

import '../models/contest.dart';
import '../models/task.dart';

class ContestPage extends StatefulWidget {
  const ContestPage({required this.contestId, super.key});

  final int contestId;

  @override
  State<ContestPage> createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage> {
  Contest? contest;
  late List<Task> tasks;

  @override
  void initState() {
    RepositoryProvider.of<ContestRepository>(context)
        .getContestInfo(widget.contestId)
        .then((value) {
      setState(() {
        contest = value;
        RepositoryProvider.of<TaskRepository>(context)
            .getTasks(contest!)
            .then((value) {
          setState(() {
            tasks = value;
          });
        });
      });
    });
    tasks = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      content: contest == null
          ? const Center(child: CircularProgressIndicator())
          : ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1000,
                    ),
                    child: Text(
                      contest!.name,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TagsListView(
                    tags: contest!.tags,
                    isAdmin: false,
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1000,
                    ),
                    child: MarkdownBody(
                      data: contest!.description,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var e in tasks)
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1000,
                      ),
                      child: Card(
                        child: ListTile(
                          title: Text(e.name),
                          onTap: () {
                            context.go("/task/${e.id}");
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
