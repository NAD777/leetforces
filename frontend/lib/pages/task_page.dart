import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/widgets/template.dart';

import '../models/task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key, required this.taskId});

  final int taskId;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  Task? task;

  @override
  void initState() {
    RepositoryProvider.of<TaskRepository>(context)
        .getTask(widget.taskId)
        .then((value) {
      setState(() {
        task = value;
      });
    });
    task = Task(1, "A + B", "aekghlkgfnskzjbgmrd rkjggkjd hzd kjh jghrdghkjrzsnkjgh dkjsrghjk drnkgjn kdjh kjt h", 412, 112, 'asvf');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      content: task == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Row(
              children: <Widget>[
                TaskDescription(task: task!),
                const SizedBox(width: 10),
                const TaskSubmission(),
              ],
            ),
    );
  }
}

class TaskDescription extends StatelessWidget {
  const TaskDescription({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                task.name,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
                ),
              ),
              // Here can be placed some badges
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth> {
                  0: IntrinsicColumnWidth(),
                  1: IntrinsicColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[
                  TableRow(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Time Limit'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${task.timeLimit} seconds'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Memory Limit'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('${task.memoryLimit} megabytes'),
                      ),
                    ]
                  ),
                ],
              ),
              Text(task.description),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskSubmission extends StatelessWidget {
  const TaskSubmission({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          children: [
            Text(
              'Upload your solution here',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
              ),
            ),
            FilledButton(
              onPressed: () {
                // TODO: show file picker
              },
              child: const Text('Choose File'),
            ),
          ],
        ),
      ),
    );
  }
}