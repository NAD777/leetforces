import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:frontend/widgets/template.dart';

import '../env/config.dart';
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
                const SizedBox(width: 15),
                TaskSubmission(
                  task: task!,
                ),
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
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium?.fontSize,
                ),
              ),
              // Here can be placed some badges
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{
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
                  TableRow(children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Memory Limit'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${task.memoryLimit} megabytes'),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 20),
              Text(task.description),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskSubmission extends StatefulWidget {
  final Task task;

  const TaskSubmission({super.key, required this.task});

  @override
  State<TaskSubmission> createState() => _TaskSubmissionState();
}

class _TaskSubmissionState extends State<TaskSubmission> {
  late String language;
  late Uint8List data;

  @override
  void initState() {
    super.initState();
    language = languages.first;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Upload your solution here',
                style: TextStyle(
                  fontSize:
                      Theme.of(context).textTheme.headlineMedium?.fontSize,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                  value: language,
                  items: languages
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (e) {
                    setState(() {
                      language = e ?? "";
                    });
                  }),
              FilledButton(
                child: const Text('Choose File'),
                onPressed: () async {
                  var result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      data = result.files.first.bytes ?? Uint8List(0);
                    });
                  }
                },
              ),
              const SizedBox(height: 5),
              FilledButton(
                onPressed: () async {
                  if (language.isEmpty) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(const SnackBar(
                          content: Text("Choose language first")));
                    return;
                  }
                  if (context.mounted) {
                    var user =
                        RepositoryProvider.of<UserRepository>(context).user!;
                    RepositoryProvider.of<TaskRepository>(context)
                        .submitSolution(user.jwt, widget.task, data, language);
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
