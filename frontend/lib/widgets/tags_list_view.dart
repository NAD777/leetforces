import 'package:flutter/material.dart';

class TagsListView extends StatelessWidget {
  const TagsListView({
    super.key,
    required this.tags,
    required this.isAdmin,
    this.onDelete,
  });

  final List<String> tags;
  final bool isAdmin;
  final Function(int)? onDelete;

  @override
  Widget build(BuildContext context) {
    assert((isAdmin && onDelete != null) || !isAdmin);
    return Row(
      children: List<Widget>.generate(
        tags.length,
        (index) => Chip(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          label: Text(tags[index]),
          deleteIcon: isAdmin ? const Icon(Icons.close) : null,
          onDeleted: isAdmin
              ? () {
                  onDelete!(index);
                }
              : null,
        ),
      ),
    );
  }
}
