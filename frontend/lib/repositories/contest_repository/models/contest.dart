class ContestSimple {
  int id;
  String name;

  ContestSimple({required this.id, required this.name});
}

class Contest extends ContestSimple {
  String description;
  List<int> taskIds;

  Contest(
      {required super.id,
      required super.name,
      required this.description,
      required this.taskIds});
}
