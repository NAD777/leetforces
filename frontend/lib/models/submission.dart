class Submission {
  int submissionId;
  int userId;
  int taskId;
  String sourceCode;
  String language;
  String? status;
  int? testNumber;
  String submissionTime;
  int? memory;
  int? runtime;

  Submission(
      this.submissionId,
      this.userId,
      this.taskId,
      this.sourceCode,
      this.language,
      this.status,
      this.testNumber,
      this.submissionTime,
      this.memory,
      this.runtime);
}
