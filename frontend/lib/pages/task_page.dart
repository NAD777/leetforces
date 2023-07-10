import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:frontend/widgets/template.dart';
import 'package:go_router/go_router.dart';

import '../env/config.dart';
import '../models/submission.dart';
import '../models/task.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key, required this.taskId});

  final int taskId;

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  Task? task;
  late List<Submission> submissions;

  @override
  void initState() {
    var taskRepo = RepositoryProvider.of<TaskRepository>(context);
    var userRepo = RepositoryProvider.of<UserRepository>(context);
    taskRepo.getTask(widget.taskId).then((value) {
      setState(() {
        task = value;
      });
      if (userRepo.user != null) {
        RepositoryProvider.of<TaskRepository>(context)
            .getSubmissions(userRepo.user!.jwt, value)
            .then((value) => setState(() {
                  submissions = value;
                }));
      }
    });
    submissions = [];
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
                  submissions: submissions,
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
              MarkdownBody(data: task.description, selectable: true,),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskSubmission extends StatefulWidget {
  final Task task;
  final List<Submission> submissions;

  const TaskSubmission(
      {super.key, required this.task, required this.submissions});

  @override
  State<TaskSubmission> createState() => _TaskSubmissionState();
}

class _TaskSubmissionState extends State<TaskSubmission> {
  late String language;
  late Uint8List data;
  late bool isAdmin;

  @override
  void initState() {
    RepositoryProvider.of<UserRepository>(context).getUserInfo().then((value) {
      setState(() {
        isAdmin = value.role == "Role.admin" || value.role == "Role.superAdmin";
      });
    });
    language = languages.first;
    isAdmin = false;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Card(
            child: Center(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upload solution',
                        style: TextStyle(
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.fontSize,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                          value: language,
                          items: languages
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
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
                                RepositoryProvider.of<UserRepository>(context)
                                    .user!;
                            RepositoryProvider.of<TaskRepository>(context)
                                .submitSolution(
                                    user.jwt, widget.task, data, language);
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  )),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
              child: Table(
                columnWidths: isAdmin
                    ? const {
                        0: IntrinsicColumnWidth(),
                        1: IntrinsicColumnWidth(),
                        2: FlexColumnWidth(),
                        3: IntrinsicColumnWidth(),
                      }
                    : const {
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                        2: IntrinsicColumnWidth(),
                      },
                children: <TableRow>[
                  TableRow(
                    children: <TableCell>[
                      if (isAdmin) const TableCell(child: Text("User")),
                      const TableCell(
                          child: Row(children: [
                        Text("Id"),
                        SizedBox(
                          width: 30,
                        )
                      ])),
                      const TableCell(child: Text("Submission time")),
                      const TableCell(
                        child: Row(
                          children: [
                            Text("Status"),
                            SizedBox(
                              width: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ...widget.submissions
                      .map((e) => TableRow(children: <TableCell>[
                            if (isAdmin)
                              TableCell(
                                child: Text(e.userId.toString()),
                              ),
                            TableCell(
                              child: InkWell(
                                child: Text(e.submissionId.toString()),
                                onTap: () {
                                  context.go("/submission/${e.submissionId}");
                                },
                              ),
                            ),
                            TableCell(child: Text(e.submissionTime)),
                            TableCell(child: Text(e.status ?? "Checking...")),
                          ]))
                      .toList()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
