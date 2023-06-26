import 'dart:convert';

import 'package:frontend/env/config.dart';
import 'package:http/http.dart' as http;

import '../models/contest.dart';

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
      return Contest(
          id: contestId,
          name: json["name"],
          description: json["description"],
          taskIds: json["task_ids"]);
    } else {
      throw Exception();
    }
  }
}
