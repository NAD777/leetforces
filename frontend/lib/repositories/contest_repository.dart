import 'dart:convert';

import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

import '../models/contest.dart';
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
        tags: (json["tags"] as List).map((tag) => tag as String).toList()
      );
    } else {
      throw Exception();
    }
  }

  Future<int> editContestNameAndDescription(
      String auth, int contestId, String name, String description) async {
    var response = await http.post(Uri.parse("$host/edit_contest"),
        headers: <String, String>{
          "Authorization": auth,
          "Content-Type": "application/json"
        },
        body: jsonEncode(<String, dynamic>{
          "contest_id": contestId,
          "contest_name": name,
          "description": description,
        }));
    // var json = jsonDecode(response.body) as Map<String, dynamic>;

    return response.statusCode;
  }
}
