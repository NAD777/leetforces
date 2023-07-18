class SimpleTask {
  int id;
  String name;
  int memoryLimit;
  int timeLimit;
  int authorId;

  SimpleTask(
      this.id, this.name, this.memoryLimit, this.timeLimit, this.authorId);
}

class Task extends SimpleTask {
  String description;

  Task(super.id, super.name, super.memoryLimit, super.timeLimit, super.authorId,
      this.description);
}

class TaskInfo {
  String masterFilename;
  String masterSolution;
  int testsCount;

  TaskInfo(this.masterFilename, this.masterSolution, this.testsCount);
}
