import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/tag.dart';
import 'package:frontend/models/userinfo.dart';
import 'package:frontend/repositories/tag_repository.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:frontend/widgets/admit_template.dart';
import 'package:go_router/go_router.dart';

class AdminTagPage extends StatefulWidget {
  final int tagId;

  const AdminTagPage({super.key, required this.tagId});

  @override
  State<StatefulWidget> createState() => _TagPage();
}

class _TagPage extends State<AdminTagPage> {
  Tag? tag;
  List<UserInfo> users = [];
  TextEditingController controller = TextEditingController();

  void updateUsers() {
    var tagRep = RepositoryProvider.of<TagRepository>(context);
    var userRep = RepositoryProvider.of<UserRepository>(context);
    tagRep.getUsersByTag(userRep.user!.jwt, widget.tagId).then((value) {
      setState(() {
        users = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    var tagRep = RepositoryProvider.of<TagRepository>(context);
    var _ = RepositoryProvider.of<UserRepository>(context);
    tagRep.getAllTags().then((value) {
      for (var element in value) {
        if (element.id == widget.tagId) {
          setState(() {
            tag = element;
          });
          return;
        }
      }
      context.go("/");
    });
    updateUsers();
  }

  Widget mainBody(BuildContext context) {
    return Column(children: [
      Row(
        children: [Text("Tag: ${tag!.name}")],
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Add user by login:",
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 200,
              height: 40,
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                ),
                controller: controller,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () {
                  var userRep = RepositoryProvider.of<UserRepository>(context);
                  userRep.searchUserInfo(controller.text).then((value) {
                    if (value != null) {
                      var jwt = userRep.user!.jwt;
                      RepositoryProvider.of<TagRepository>(context)
                          .addUserTag(jwt, value.id, widget.tagId)
                          .then((value) => updateUsers());
                    }
                  });
                },
                child: const Text("Add")),
          )
        ],
      ),
      ...users.map((e) => Row(children: [
            IconButton(
              onPressed: () {
                var userRep = RepositoryProvider.of<UserRepository>(context);
                RepositoryProvider.of<TagRepository>(context)
                    .removeUserTag(userRep.user!.jwt, e, widget.tagId)
                    .then((value) => updateUsers());
              },
              icon: const Icon(Icons.close),
            ),
            Text(e.login),
          ])),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AdminTemplate(
        content: tag == null
            ? const Column(children: [CircularProgressIndicator()])
            : mainBody(context));
  }
}
