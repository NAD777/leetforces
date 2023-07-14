import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repositories/tag_repository.dart';
import 'package:frontend/widgets/admit_template.dart';
import 'package:go_router/go_router.dart';

import '../models/tag.dart';
import '../repositories/contest_repository.dart';
import '../repositories/user_repository.dart';
import '../widgets/tags_list_view.dart';

class AdminTagList extends StatefulWidget {
  const AdminTagList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AdminTagList();
  }
}

class _AdminTagList extends State<AdminTagList> {
  List<Tag> tags = [];

  void updateList() {
    RepositoryProvider.of<TagRepository>(context).getAllTags().then((value) {
      setState(() {
        tags = value;
      });
    });
  }

  @override
  void initState() {
    updateList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminTemplate(
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1000,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TagsListView(
                    tags: const [],
                    isAdmin: true,
                    label: "",
                    onCreate: (name) async {
                      if (!tags.any((element) => element.name == name)) {
                        if (context.mounted) {
                          var user =
                              RepositoryProvider.of<UserRepository>(context)
                                  .user;
                          int? tagsId;
                          tagsId =
                              await RepositoryProvider.of<TagRepository>(
                                      context)
                                  .addTag(user!.jwt, name);
                          if (tagsId == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Could not create a new tag")));
                            }
                            return;
                          } else {
                            updateList();
                          }
                        }
                      }
                      updateList();
                    },
                    onDelete: (a) {},
                  ),
                ),
              ],
            ),
            for (var e in tags)
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1000,
                ),
                child: Card(
                  child: ListTile(
                    title: Text(e.name),
                    onTap: () {
                      context.go("/admin/tag/${e.id}");
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
