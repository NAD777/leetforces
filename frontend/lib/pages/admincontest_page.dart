import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/widgets/template.dart';

import '../models/contest.dart';
import '../models/task.dart';
import '../repositories/user_repository.dart';

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

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();

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
    tasks = [];
    super.initState();
  }

  /*@override
  Widget build(BuildContext context) {
    return Template(
      content: Column(
        children: contest == null
            ? [
              const Text("Wrong contest number")
              ]
            : [
          Text(contest!.name),
          const Text("Edit name of the contest:"),
          TextField(decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: contest!.name
          )),
          const Text("Edit name of the contest:"),
          TextField(decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: contest!.description
          ),
          ),
        ],
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Template(
        content: Form(
      key: _formKey,
      child: Column(
        children: contest == null
            ? [const Text("Wrong contest number")]
            : [
                Text(contest!.name),
                const Text("Edit name of the contest:"),
                TextFormField(
                    controller: controllerName,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: contest!.name)),
                const Text("Edit name of the contest:"),
                TextFormField(
                  controller: controllerDescription,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: contest!.description),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String token =
                            RepositoryProvider.of<UserRepository>(context)
                                .user!
                                .jwt;
                        RepositoryProvider.of<ContestRepository>(context)
                            .editContestNameAndDescription(
                                token,
                                contest!.id,
                                controllerName.text,
                                controllerDescription.text);
                      }
                    },
                    child: const Text("Change data"))
              ],
      ),
    ));
  }
}
