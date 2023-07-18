import 'package:flutter/material.dart';
import 'package:frontend/models/tag.dart';
import 'package:go_router/go_router.dart';

class TagsListView extends StatelessWidget {
  const TagsListView({
    super.key,
    required this.tags,
    required this.isAdmin,
    this.label = "Tags: ",
    this.onDelete,
    this.onCreate,
  });

  final List<Tag> tags;
  final bool isAdmin;
  final Function(int)? onDelete;
  final Function(String)? onCreate;
  final String label;

  @override
  Widget build(BuildContext context) {
    assert((isAdmin && onDelete != null && onCreate != null) || !isAdmin);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(label),
      ...List<Widget>.generate(
        tags.length,
        (index) => Chip(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          label: Text(tags[index].name),
          deleteIcon: isAdmin ? const Icon(Icons.close) : null,
          onDeleted: isAdmin
              ? () {
                  onDelete!(tags[index].id);
                }
              : null,
        ),
      ),
      if (isAdmin)
        ActionChip(
          label: const Text('Add'),
          avatar: const Icon(Icons.add),
          onPressed: () async {
            await askForName(context);
          },
        ),
    ]);
  }

  Future<void> askForName(BuildContext context) async {
    var controller = TextEditingController();

    var dialog = AlertDialog(
      title: const Text('Enter tag name'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "Name for tag",
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (controller.text != '') {
              onCreate!(controller.text);
              context.pop();
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('You cannot create tag with empty name'),
                  ),
                );
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (context) {
        return dialog;
      },
    );
  }
}
