import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/widgets/tags_list_view.dart';

import '../models/contest.dart';
import '../models/tag.dart';
import '../models/task.dart';
import '../repositories/user_repository.dart';
import '../widgets/admit_template.dart';

class AdminContestPage extends StatefulWidget {
  const AdminContestPage({required this.contestId, super.key});

  final int contestId;

  @override
  State<AdminContestPage> createState() => _AdminContestPageState();
}

class _AdminContestPageState extends State<AdminContestPage> {
  Contest? contest;
  late List<Task> tasks;

  final _formKey = GlobalKey<FormState>();
  final _form2Key = GlobalKey<FormState>();

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
    return AdminTemplate(
      content: Column(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: contest == null
                  ? _wrongNumber()
                  : [
                      Text(contest!.name),
                      const Text("Edit name of the contest:"),
                      TextFormField(
                        controller: controllerName,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: contest!.name,
                        ),
                      ),
                      const Text("Edit description of the contest:"),
                      TextFormField(
                        controller: controllerDescription,
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: contest!.description),
                      ),
                      TagsListView(
                          tags: contest!.tags,
                          isAdmin: true,
                          onDelete: _onTagDeleted,
                          onCreate: _onTagAdded),
                      ElevatedButton(
                        onPressed: () => _onChangeDataPress(context),
                        child: const Text("Change data"),
                      ),
                      TextFormField(
                        controller: controllerTaskId,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), hintText: "Task id"),
                      ),
                      Form(
                        key: _form2Key,
                        child: Column(
                          children: [
                            ElevatedButton(
                                onPressed: () => _onAddTask(context),
                                child: const Text("Add task by id")),
                            FutureBuilder<ListView>(
                              future: _tasksAsChildren(context),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.done:
                                    if (snapshot.hasError) {
                                      return const Text(
                                          "Some error has occured");
                                    }
                                    return snapshot.data!;
                                  default:
                                    return const Text("Error occured");
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  void _onTagDeleted(int id) async {
    if (id == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deleting this tag is forbidden")));
      return;
    }
    var user = RepositoryProvider.of<UserRepository>(context).user;
    if (await RepositoryProvider.of<ContestRepository>(context)
        .removeTagFromContest(user!.jwt, contest!, id)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Successfully deleted a tag")));
        setState(() {
          contest!.tags.removeWhere((element) => element.id == id);
        });
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to delete a tag")));
      }
    }
  }

  void _onTagAdded(String name) async {
    var user = RepositoryProvider.of<UserRepository>(context).user;
    var tags =
        await RepositoryProvider.of<ContestRepository>(context).getAllTags();
    int? tagsId;
    if (!tags.any((element) => element.name == name)) {
      if (context.mounted) {
        tagsId = await RepositoryProvider.of<ContestRepository>(context)
            .addTag(user!.jwt, name);
        if (tagsId == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Could not create a new tag")));
          }
          return;
        }
      }
    }
    tagsId ??= tags.where((element) => element.name == name).first.id;
    if (context.mounted) {
      if (await RepositoryProvider.of<ContestRepository>(context)
          .addTagToContest(user!.jwt, contest!, tagsId)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Successfully added tag to the contest")));
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Failure while adding tag to the contest")));
        }
      }
    }
    setState(() {
      contest!.tags.add(Tag(tagsId!, name));
    });
  }

  Future<ListView> _tasksAsChildren(BuildContext context) async {
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

  List<Widget> _wrongNumber() {
    return [const Text("Wrong contest number")];
  }

  void _onDeleteTask(BuildContext context, int taskId) async {
    if (_form2Key.currentState!.validate()) {
      var user = RepositoryProvider.of<UserRepository>(context).user;
      String token = user?.jwt ?? "";
      try {
        var newTasks = tasks.map((e) => e.id).toList();
        var oldTask = taskId;
        if (newTasks.contains(oldTask)) {
          newTasks.remove(oldTask);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Task does not exist")));
        }
        int res = await RepositoryProvider.of<ContestRepository>(context)
            .setTasksToContest(token, contest!.id, newTasks);
        if (context.mounted) {
          String value;
          switch (res) {
            case 200:
              value = "Successfully removed task";
              break;
            default:
              value = "Something went wrong";
              break;
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(value)));
          setState(() {
            tasks.removeWhere((element) => element.id == oldTask);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error")));
      }
    }
  }

  void _onAddTask(BuildContext context) async {
    if (_form2Key.currentState!.validate()) {
      var user = RepositoryProvider.of<UserRepository>(context).user;
      String token = user?.jwt ?? "";
      try {
        var newTasks = tasks.map((e) => e.id).toList();
        var newTask = int.parse(controllerTaskId.text);
        newTasks.add(newTask);
        int res = await RepositoryProvider.of<ContestRepository>(context)
            .setTasksToContest(token, contest!.id, newTasks);
        if (context.mounted) {
          String value;
          switch (res) {
            case 200:
              value = "Successfully added task";
              break;
            default:
              value = "Something went wrong";
              break;
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(value)));
          var task = await RepositoryProvider.of<TaskRepository>(context)
              .getTask(newTask);
          setState(() {
            tasks.add(task);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error")));
      }
    }
  }

  void _onChangeDataPress(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var user = RepositoryProvider.of<UserRepository>(context).user;
      String token = user?.jwt ?? "";
      try {
        int res = await RepositoryProvider.of<ContestRepository>(context)
            .editContestNameAndDescription(
          token,
          contest!.id,
          controllerName.text,
          controllerDescription.text,
        );
        if (context.mounted) {
          String value;
          switch (res) {
            case 200:
              value = "Success";
              break;
            case 403:
              value = "Forbidden";
              break;
            default:
              value = "Something went wrong";
              break;
          }
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(value)));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Error")));
      }
    }
  }
}
