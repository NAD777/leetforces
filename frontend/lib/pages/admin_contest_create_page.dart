import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/tag_repository.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/widgets/tags_list_view.dart';

import '../models/contest.dart';
import '../models/tag.dart';
import '../models/task.dart';
import '../repositories/user_repository.dart';
import '../widgets/admit_template.dart';

class AdminContestCreatePage extends StatefulWidget {
  const AdminContestCreatePage({super.key});

  @override
  State<AdminContestCreatePage> createState() => _AdminContestCreatePageState();
}

class _AdminContestCreatePageState extends State<AdminContestCreatePage> {
  Contest? contest;
  late List<Task> tasks;

  final _formKey = GlobalKey<FormState>();

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerTaskId = TextEditingController();

  @override
  void initState() {
    controllerName.text = "";
    controllerDescription.text = "";
    controllerTaskId.text = "";
    tasks = [];
    contest = Contest(
        id: -1,
        name: "",
        description: "",
        tasks: [],
        tags: [Tag(1, "All")],
        isClosed: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AdminTemplate(
        content: Column(children: [
      Form(
          key: _formKey,
          child: Column(
            children: contest == null
                ? [const Text("Wrong contest number")]
                : [
                    Text(contest!.name),
                    const Text("Enter name of the contest:"),
                    TextFormField(
                      controller: controllerName,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: contest!.name,
                      ),
                    ),
                    const Text("Enter description of the contest:"),
                    TextFormField(
                      controller: controllerDescription,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: contest!.description),
                    ),
                    CheckboxListTile(
                      title: const Text("Is closed"),
                      value: contest!.isClosed,
                      onChanged: (bool? value) {
                        setState(() {
                          contest!.isClosed = value!;
                        });
                      },
                    ),
                    TagsListView(
                        tags: contest!.tags,
                        isAdmin: true,
                        onDelete: _onTagDeleted,
                        onCreate: _onTagAdded),
                    TextFormField(
                      controller: controllerTaskId,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), hintText: "Task id"),
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: () => _onAddTask(context),
                            child: const Text("Add task by id")),
                        _tasksAsChildren(context)
                      ],
                    ),
                    ElevatedButton(
                        onPressed: _onCreateContest,
                        child: const Text("Create contest")),
                  ],
          ))
    ]));
  }

  void _onTagDeleted(int id) async {
    setState(() {
      contest!.tags.removeWhere((element) => element.id == id);
    });
  }

  void _onCreateContest() async {
    var user = RepositoryProvider.of<UserRepository>(context).user;
    if (await RepositoryProvider.of<ContestRepository>(context).createContest(
      user!.jwt,
      controllerName.text,
      controllerDescription.text,
      tasks: tasks.map((e) => e.id).toList(),
      tags: contest!.tags.map((e) => e.id).toList(),
      isClosed: contest!.isClosed,
    )) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully created the contest")));
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not create a contest")));
      }
    }
  }

  void _onTagAdded(String name) async {
    var user = RepositoryProvider.of<UserRepository>(context).user;
    var tags = await RepositoryProvider.of<TagRepository>(context).getAllTags();
    int? tagsId;
    if (!tags.any((element) => element.name == name)) {
      if (context.mounted) {
        tagsId = await RepositoryProvider.of<TagRepository>(context)
            .addTag(user!.jwt, name);
        if (tagsId == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Could not create a new tag")));
          }
          return;
        }
      }
    } else {
      tagsId = tags.where((element) => element.name == name).first.id;
    }
    setState(() {
      contest!.tags.add(Tag(tagsId!, name));
    });
  }

  ListView _tasksAsChildren(BuildContext context) {
    List<DataRow> res = [];
    for (var task in tasks) {
      res.add(
        DataRow(
          cells: [
            DataCell(Text(task.id.toString())),
            DataCell(Text(task.name)),
            DataCell(ElevatedButton(
              onPressed: () => _onDeleteTask(context, task.id),
              child: const Text("Delete"),
            ))
          ],
        ),
      );
    }
    var columns = List.of([
      const DataColumn(label: Text("Task id")),
      const DataColumn(label: Text("Task name")),
      const DataColumn(label: Text(""))
    ]);
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: [DataTable(columns: columns, rows: res)],
    );
  }

  void _onDeleteTask(BuildContext context, int taskId) async {
    setState(() => tasks.removeWhere((element) => element.id == taskId));
  }

  void _onAddTask(BuildContext context) async {
    int newTask;
    try {
      newTask = int.parse(controllerTaskId.text);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Wrong task format")));
      return;
    }
    var task =
        await RepositoryProvider.of<TaskRepository>(context).getTask(newTask);

    setState(() => tasks.add(task));
  }
}
