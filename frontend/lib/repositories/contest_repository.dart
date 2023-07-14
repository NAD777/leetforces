import 'dart:convert';

import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

import '../models/contest.dart';
import '../models/tag.dart';
import '../models/task.dart';

class ContestRepository {
  Future<List<ContestSimple>> getContests() async {
    var response = await http.get(
      Uri.parse("$host/list_contests"),
    );
    var json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      var list = json['contest_list'] as List<dynamic>;
      var contests = list
          .map((e) =>
              ContestSimple(id: e["contest_id"], name: e["contest_name"]))
          .toList();
      return contests;
    } else {
      throw Exception();
    }
  }

  Future<Contest> getContestInfo(int contestId) async {
    var response = await http.get(
      Uri.parse("$host/get_contest/$contestId"),
    );
    var json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      var d = (json["tasks"] as List<dynamic>)
          .map((e) => SimpleTask(e["task_id"], e["name"], e["memory_limit"],
              e["time_limit"], e["author_id"]))
          .toList();
      return Contest(
          id: contestId,
          name: json["name"],
          description: json["description"],
          tasks: d,
          tags: (json["tags"] as List<dynamic>)
              .map((tag) => Tag(tag["id"], tag["name"]))
              .toList(),
          isClosed: json["is_closed"]);
    } else {
      throw Exception();
    }
  }

  Future<bool> editContest(String auth, int contestId,
      {String? name,
      String? description,
      List<int>? tasks,
      int? authorId,
      bool? isClosed,
      List<int>? tags}) async {
    var dict = <String, dynamic>{"contest_id": contestId};
    if (name != null) {
      dict["contest_name"] = name;
    }
    if (description != null) {
      dict["description"] = description;
    }
    if (tasks != null) {
      dict["tasks_ids"] = tasks;
    }
    if (authorId != null) {
      dict["author_id"] = authorId;
    }
    if (isClosed != null) {
      dict["is_closed"] = isClosed;
    }
    if (tags != null) {
      dict["tags"] = tags;
    }
    var json = jsonEncode(dict);
    var response = await http.post(Uri.parse("$host/edit_contest"),
        headers: <String, String>{
          "Authorization": auth,
          "Content-Type": "application/json"
        },
        body: json);
    return response.statusCode == 200;
  }
}
