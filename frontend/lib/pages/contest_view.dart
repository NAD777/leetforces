import 'package:flutter/material.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/widgets/template.dart';

import '../models/contest.dart';
import '../models/task.dart';

class ContestPage extends StatefulWidget {
  const ContestPage(
      {required this.contestRepository,
      required this.taskRepository,
      required this.contestId,
      super.key});

  final ContestRepository contestRepository;
  final TaskRepository taskRepository;
  final int contestId;

  static Route<void> route(ContestRepository contestRepository,
      TaskRepository taskRepository, int contestId) {
    return MaterialPageRoute(
      builder: (_) => ContestPage(
        contestRepository: contestRepository,
        taskRepository: taskRepository,
        contestId: contestId,
      ),
    );
  }

  @override
  State<ContestPage> createState() => _ContestPageState();
}

class _ContestPageState extends State<ContestPage> {
  late Contest contest;
  late List<Task> tasks;

  @override
  void initState() {
    widget.contestRepository.getContestInfo(widget.contestId).then((value) {
      setState(() {
        contest = value;
        widget.taskRepository.getTasks(contest).then((value) {
          setState(() {
            tasks = value;
          });
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      content: Column(
        children: [
          Text(contest.name),
          for (var e in tasks)
            Card(
              child: ListTile(
                title: Text(e.name),
              ),
            ),
        ],
      ),
    );
  }
}
