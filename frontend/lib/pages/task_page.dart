import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:frontend/widgets/template.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
            .getSubmissions(userRepo.user!.jwt, value.id)
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
      scrollable: false,
      content: task == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Row(
              children: <Widget>[
                Flexible(
                  child: TaskDescription(task: task!),
                ),
                Flexible(
                  child: TaskSubmission(
                    task: task!,
                    submissions: submissions,
                  ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: CustomScrollView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          slivers: <Widget>[
            SliverList.list(
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
                  border: TableBorder.all(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
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
                MarkdownBody(
                  data: task.description,
                  selectable: true,
                ),
              ],
            ),
          ],
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
  Uint8List? data;
  String? fileName;
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Upload solution',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.headlineMedium?.fontSize,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: language,
                    items: languages
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    onChanged: (e) {
                      setState(() {
                        language = e ?? "";
                      });
                    },
                  ),
                  const SizedBox(height: 5),
                  FilledButton(
                    child: const Text('Choose File'),
                    onPressed: () async {
                      var result = await FilePicker.platform.pickFiles();
                      if (result != null) {
                        setState(() {
                          data = result.files.first.bytes;
                          fileName = result.names.first;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(fileName ?? "No file selected"),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: data != null
                        ? () async {
                            if (language.isEmpty) {
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text("Choose language first"),
                                  ),
                                );
                              return;
                            }

                            if (context.mounted) {
                              var user =
                                  RepositoryProvider.of<UserRepository>(context)
                                      .user!;
                              log('Submit solution');
                              var submissionId =
                                  await RepositoryProvider.of<TaskRepository>(
                                          context)
                                      .submitSolution(
                                user.jwt,
                                widget.task,
                                data!,
                                language,
                              );
                              if (context.mounted) {
                                var userInfo =
                                    await RepositoryProvider.of<UserRepository>(
                                            context)
                                        .getUserInfo();
                                var formatter =
                                    DateFormat("E, d MMM y HH:mm:ss");
                                var time =
                                    "${formatter.format(DateTime.now().toUtc())} GMT";
                                setState(() {
                                  widget.submissions.add(Submission(
                                      submissionId,
                                      userInfo.id,
                                      widget.task.id,
                                      "",
                                      language,
                                      "Checking...",
                                      1,
                                      time,
                                      0,
                                      0,
                                      userInfo.login));
                                });
                              }
                            }
                          }
                        : null,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
              child: SingleChildScrollView(
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
                        if (isAdmin) const TableCell(child: Text("User ")),
                        const TableCell(
                          child: Row(
                            children: [
                              Text("Id"),
                              SizedBox(
                                width: 30,
                              )
                            ],
                          ),
                        ),
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
                        .map(
                          (e) => TableRow(
                            children: <TableCell>[
                              if (isAdmin)
                                TableCell(
                                  child: SizedBox(width: e.login.length * 8, child: Text(e.login)),
                                ),
                              TableCell(
                                child: InkWell(
                                  child: Text(e.submissionId.toString()),
                                  onTap: () {
                                    showSubmissionInfo(context, e);
                                  },
                                ),
                              ),
                              TableCell(child: Text(e.submissionTime)),
                              TableCell(child: Text(e.status ?? "Checking...")),
                            ],
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void showSubmissionInfo(BuildContext context, Submission submission) {
    var code = utf8.decode(base64Decode(submission.sourceCode));

    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              title: const Text('Submission info'),
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () => context.pop(),
                ),
              ],
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 30,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Text>[
                          Text(
                            'Task Name: ${widget.task.name}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            'Submission time: ${submission.submissionTime}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            'Status: ${submission.status}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            'Language: ${submission.language}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            'Test Failed: ${submission.testNumber}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            'Time: ${submission.runtime}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            'Memory: ${submission.memory}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Your code:',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Flexible(
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: CustomScrollView(
                          slivers: [
                            SliverList.list(children: [Text(code)]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
