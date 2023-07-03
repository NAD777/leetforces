import 'dart:convert';
import 'dart:typed_data';

import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

import '../models/contest.dart';
import '../models/task.dart';

class TaskRepository {
  Future<List<Task>> getTasks(Contest contest) async {
    return await Future.wait(contest.tasks.map((e) => getTask(e.id)));
  }

  Future<Task> getTask(int taskId) async {
    var response = await http.get(Uri.parse("$host/get_task/$taskId"));
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return Task(taskId, json["name"], json["memory_limit"],
          json["time_limit"], json["author_name"], json["description"]);
    } else {
      throw Exception();
    }
  }

  Future<void> submitSolution(
      String jwt, Task task, Uint8List submission, String language) async {
    var b64 = base64.encode(submission.toList());
    var response = await http.post(Uri.parse("$host/submit"),
        body: jsonEncode(<String, dynamic>{
          "task_id": task.id,
          "source_code": b64,
          "language": language,
        }),
        headers: <String, String>{
          "Authorization": jwt,
          "Content-Type": "application/json"
        });
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(json['message']);
    }
  }
}
