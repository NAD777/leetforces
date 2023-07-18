import 'dart:convert';
import 'dart:typed_data';

import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

import '../models/contest.dart';
import '../models/submission.dart';
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

  Future<TaskInfo> getTaskInfo(int taskId) async {
    var response = await http.get(Uri.parse("$host/get_task_info/$taskId"));
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return TaskInfo(
          json["master_filename"], json["master_file"], json["amount_test"]);
    } else {
      throw Exception();
    }
  }

  Future<int> submitSolution(
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
    return json["submission_id"];
  }

  Future<List<Submission>> getSubmissions(String jwt, int taskId) async {
    var response = await http.get(Uri.parse("$host/get_submission/$taskId"),
        headers: <String, String>{
          "Authorization": jwt,
        });
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body) as List<dynamic>;
      return json.map((e) {
        return Submission(
            e["submission_id"],
            e["user_id"],
            e["task_id"],
            e["source_code"],
            e["language"],
            e["status"],
            e["test_number"],
            e["submission_time"],
            e["memory"],
            e["runtime"],
            e["user_login"]);
      }).toList();
    } else {
      var json = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(json['message']);
    }
  }

  Future<bool> editTask(String token, int taskId,
      {String? name,
      String? description,
      int? memoryLimit,
      int? timeLimit,
      int? amountOfTests,
      String? masterFilename,
      String? masterSolution}) async {
    var dict = <String, dynamic>{"task_id": taskId};
    if (name != null) {
      dict["name"] = name;
    }
    if (description != null) {
      dict["description"] = description;
    }
    if (memoryLimit != null) {
      dict["memory_limit"] = memoryLimit;
    }
    if (timeLimit != null) {
      dict["time_limit"] = timeLimit;
    }
    if (amountOfTests != null) {
      dict["amount_of_tests"] = amountOfTests;
    }
    if (masterFilename != null) {
      dict["master_filename"] = masterFilename;
    }
    if (masterSolution != null) {
      dict["master_solution"] = masterSolution;
    }
    var json = jsonEncode(dict);
    var response = await http.post(Uri.parse("$host/edit_task"),
        headers: <String, String>{
          "Authorization": token,
          "Content-Type": "application/json"
        },
        body: json);
    return response.statusCode == 200;
  }

  Future<int> createTask(
      String token,
      String name,
      String description,
      int memoryLimit,
      int timeLimit,
      int amountOfTests,
      String masterFilename,
      String masterSolution) async {
    var dict = <String, dynamic>{
      "name": name,
      "description": description,
      "memory_limit": memoryLimit,
      "time_limit": timeLimit,
      "amount_of_tests": amountOfTests,
      "master_filename": masterFilename,
      "master_solution": masterSolution,
    };
    var json = jsonEncode(dict);
    var response = await http.post(Uri.parse("$host/create_task"),
        headers: <String, String>{
          "Authorization": token,
          "Content-Type": "application/json"
        },
        body: json);
    var resp = jsonDecode(response.body);
    if ((response.statusCode == 200)) {
      return resp["task_number"];
    }
    throw Exception(resp["message"]);
  }
}
