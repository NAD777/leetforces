import 'package:flutter/material.dart';
import 'package:frontend/repositories/contest_repository/contest_repository.dart';
import 'package:frontend/widgets/template.dart';

import '../../../repositories/contest_repository/models/contest.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.contestRepository, super.key});

  final ContestRepository contestRepository;

  static Route<void> route(ContestRepository contestRepository) {
    return MaterialPageRoute(
      builder: (_) => HomePage(contestRepository: contestRepository),
    );
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int someCount = 30;
  late List<ContestSimple> list;

  @override
  void initState() {
    widget.contestRepository.getContests().then((value) {
      setState(() {
        list = value;
      });
    });
    list = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      content: Column(
        children: [
          for (var e in list)
            Card(
              child: ListTile(
                title: Text(e.name),
              ),
            ),
        ],
      ),
    );
  }
}
