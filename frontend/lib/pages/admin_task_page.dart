import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/task.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../repositories/user_repository.dart';
import '../widgets/admit_template.dart';

class AdminTaskPage extends StatefulWidget {
  final int? taskId;

  const AdminTaskPage({super.key, this.taskId});

  @override
  State<StatefulWidget> createState() => _AdminTaskPageState();
}

class _AdminTaskPageState extends State<AdminTaskPage> {
  final _formKey = GlobalKey<FormState>();
  Task? task;
  Uint8List? data;

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerMemoryLimit = TextEditingController();
  TextEditingController controllerTimeLimit = TextEditingController();
  TextEditingController controllerAmountOfTests = TextEditingController();
  TextEditingController controllerFileName = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.taskId == null) {
      task = Task(0, "", 0, 0, 0, "");
      return;
    }
    RepositoryProvider.of<TaskRepository>(context)
        .getTask(widget.taskId!)
        .then((value) {
      setState(() {
        task = value;
      });
      controllerName.text = value.name;
      controllerDescription.text = value.description;
      controllerMemoryLimit.text = value.memoryLimit.toString();
      controllerTimeLimit.text = value.timeLimit.toString();
      RepositoryProvider.of<TaskRepository>(context)
          .getTaskInfo(widget.taskId!)
          .then((value) {
        controllerAmountOfTests.text = value.testsCount.toString();
        controllerFileName.text = value.masterFilename;
      });
    });
  }

  TableRow formTextRow(String label, TextEditingController controller, int len,
      {bool intField = false, int? lines}) {
    var validator = intField
        ? (val) {
            if (val == null) {
              return null;
            }
            var intV = int.tryParse(val);
            if (intV == null) {
              return "Not a number";
            }
            if (intV <= 0) {
              return "Must be positive";
            }
            if (widget.taskId == null) {
              if (val.isEmpty) {
                return "Must not be empty";
              }
            }
            return null;
          }
        : (val) {
            if (widget.taskId == null) {
              if (val.isEmpty) {
                return "Must not be empty";
              }
            }
            return null;
          };
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Text(label),
        ),
        TableCell(
          child: lines == null
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: controller,
                    validator: validator,
                  ),
                )
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: controller,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      minLines: lines,
                      maxLines: null,
                      validator: validator,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminTemplate(
      content: Column(
        children: [
          Form(
            key: _formKey,
            child: Table(
                children: task == null
                    ? [
                        const TableRow(children: [CircularProgressIndicator()]),
                      ]
                    : mainBody(context)),
          ),
        ],
      ),
    );
  }

  mainBody(BuildContext context) {
    return [
      formTextRow("Task name:", controllerName, 15),
      formTextRow("Task description:", controllerDescription, 15, lines: 8),
      formTextRow("Tests count:", controllerAmountOfTests, 4, intField: true),
      formTextRow("Memory limit (MB):", controllerMemoryLimit, 4,
          intField: true),
      formTextRow("Time limit (sec):", controllerTimeLimit, 4, intField: true),
      formTextRow("Master solution file name:", controllerFileName, 15),
      TableRow(
        children: [
          TableCell(
            child: Text("Master solution: ${data == null ? "" : "[Chosen]"}"),
          ),
          TableCell(
            child: ElevatedButton(
              onPressed: () async {
                var result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  controllerFileName.text = result.names.first!;
                  setState(() {
                    data = result.files.first.bytes ?? Uint8List(0);
                  });
                }
              },
              child: const Text("Choose file"),
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          const TableCell(child: Text("")),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                var user = RepositoryProvider.of<UserRepository>(context).user!;
                String? file;
                if (data != null) {
                  file = base64.encode(data!.toList());
                }
                if (widget.taskId == null) {
                  if (data == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Select master solution")));
                    return;
                  }
                  RepositoryProvider.of<TaskRepository>(context)
                      .createTask(
                    user.jwt,
                    controllerName.text,
                    controllerDescription.text,
                    int.parse(controllerMemoryLimit.text),
                    int.parse(controllerTimeLimit.text),
                    int.parse(controllerAmountOfTests.text),
                    controllerFileName.text,
                    file!,
                  )
                      .then((value) {
                    context.go("/task/$value");
                  });
                } else {
                  RepositoryProvider.of<TaskRepository>(context)
                      .editTask(
                    user.jwt,
                    widget.taskId!,
                    name: controllerName.text,
                    description: controllerDescription.text,
                    memoryLimit: int.parse(controllerMemoryLimit.text),
                    timeLimit: int.parse(controllerTimeLimit.text),
                    amountOfTests: int.parse(controllerAmountOfTests.text),
                    masterFilename: controllerFileName.text,
                    masterSolution: file,
                  )
                      .then((value) {
                    setState(() {
                      data = null;
                    });
                  });
                }
              },
              child: Text(widget.taskId == null ? "Create" : "Update"),
            ),
          ),
        ],
      ),
    ];
  }
}
