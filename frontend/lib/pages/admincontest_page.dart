import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/contest_repository.dart';
import 'package:frontend/repositories/task_repository.dart';
import 'package:frontend/widgets/template.dart';

import '../models/contest.dart';
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

  @override
  Widget build(BuildContext context) {
    return AdminTemplate(
      content: Form(
        key: _formKey,
        child: Column(
          children: contest == null
              ? wrongNumber()
              : [
                  Text(contest!.name),
                  const Text("Edit name of the contest:"),
                  TextFormField(
                      controller: controllerName,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: contest!.name)),
                  const Text("Edit description of the contest:"),
                  TextFormField(
                    controller: controllerDescription,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: contest!.description),
                  ),
                  ElevatedButton(
                    onPressed: () => onChangeDataPress(context),
                    child: const Text("Change data"),
                  ),
                ],
        ),
      ),
    );
  }

  List<Widget> wrongNumber() {
    return [const Text("Wrong contest number")];
  }

  void onChangeDataPress(BuildContext context) async {
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
        }
      }
      catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error")));
      }
    }
  }
}
