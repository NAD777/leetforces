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
import '../widgets/template.dart';

class AdminContestPage extends StatefulWidget {
  const AdminContestPage({required this.contestId, super.key});

  final int contestId;

  @override
  State<AdminContestPage> createState() => _AdminContestPageState();
}

class _AdminContestPageState extends State<AdminContestPage> {
  Contest? contest;
  late List<Task> tasks;

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerTaskId = TextEditingController();

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
            controllerName.text = contest!.name;
            controllerDescription.text = contest!.description;
          });
        });
      });
    });
    controllerName.text = "";
    controllerDescription.text = "";
    controllerTaskId.text = "";
    tasks = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      isAdminPage: true,
      content: Column(
        children: contest == null
            ? [const Text("Wrong contest number")]
            : [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Edit name of the contest:",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: SizedBox(
                        width: 400,
                        child: TextFormField(
                          controller: controllerName,
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            hintText: contest!.name,
                          ),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Edit description of the contest:",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 400,
                        height: 40,
                        child: TextFormField(
                          controller: controllerDescription,
                          decoration: InputDecoration(
                              border: const UnderlineInputBorder(),
                              hintText: contest!.description),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Is closed",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      height: 50,
                      child: CheckboxListTile(
                        title: const Text(
                          "",
                          style: TextStyle(fontSize: 20),
                        ),
                        value: contest!.isClosed,
                        onChanged: (bool? value) {
                          setState(() {
                            contest!.isClosed = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 10, bottom: 50),
                      child: TagsListView(
                          tags: contest!.tags,
                          isAdmin: true,
                          onDelete: _onTagDeleted,
                          onCreate: _onTagAdded),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: SizedBox(
                        width: 200,
                        height: 40,
                        child: TextFormField(
                          controller: controllerTaskId,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(),
                              hintText: "Task id"),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _onAddTask(context),
                        child: const Text(
                          "Add task by id",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(width: 500, child: _tasksAsChildren(context)),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: _onSaveChanges,
                        child: const Text("Save changes")),
                  ],
                ),
              ],
      ),
    );
  }

  void _onTagDeleted(int id) async {
    setState(() {
      contest!.tags.removeWhere((element) => element.id == id);
    });
  }

  void _onSaveChanges() async {
    var user = RepositoryProvider.of<UserRepository>(context).user;
    if (await RepositoryProvider.of<ContestRepository>(context).editContest(
        user!.jwt, contest!.id,
        name: controllerName.text,
        description: controllerDescription.text,
        tasks: tasks.map((e) => e.id).toList(),
        tags: contest!.tags.map((e) => e.id).toList(),
        isClosed: contest!.isClosed)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully updated the contest")));
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Could not update contest")));
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
