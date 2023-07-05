import 'package:frontend/models/task.dart';

class ContestSimple {
  int id;
  String name;

  ContestSimple({required this.id, required this.name});
}

class Contest extends ContestSimple {
  String description;
  List<SimpleTask> tasks;
  List<String> tags;

  Contest(
      {required super.id,
      required super.name,
      required this.description,
      required this.tasks,
      required this.tags});
}
