import 'package:flutter/material.dart';
import 'package:frontend/repositories/contest_repository/models/contest.dart';

class ContestsView extends StatelessWidget {
  const ContestsView({super.key});

  @override
  Widget build(BuildContext context) {
    int someCount = 30;
    List<Contest> list = List.generate(
        someCount, (index) => Contest(id: index, name: 'Task number $index'));
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Card(
              child: ListTile(
                title: Text(list[index].name),
              ),
            );
          },
          childCount: someCount,
        ),
      ),
    );
  }
}
