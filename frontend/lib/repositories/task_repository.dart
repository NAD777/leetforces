import 'dart:convert';

import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

import '../models/contest.dart';
import '../models/task.dart';

class TaskRepository {
  Future<List<Task>> getTasks(Contest contest) async {
    return await Future.wait(contest.taskIds.map((e) => getTask(e)));
  }

  Future<Task> getTask(int taskId) async {
    var response = await http.get(Uri.parse("$host/get_task/$taskId"),
        headers: <String, String>{"Content-Type": "application/json"});
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return Task(taskId, json["name"], json["description"],
          json["memory_limit"], json["time_limit"], json["amount_of_tests"]);
    } else {
      throw Exception();
    }
  }
}
