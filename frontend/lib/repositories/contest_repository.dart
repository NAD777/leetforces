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
              .toList());
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

  Future<int> setTasksToContest(
      String auth, int contestId, List<int> tasks) async {
    var response = await http.post(Uri.parse("$host/edit_contest"),
        headers: <String, String>{
          "Authorization": auth,
          "Content-Type": "application/json"
        },
        body: jsonEncode(
            <String, dynamic>{"contest_id": contestId, "tasks_ids": tasks}));
    return response.statusCode;
  }

  Future<int?> addTag(String auth, String tagName) async {
    var response = await http.post(Uri.parse("$host/add_tag"),
        headers: <String, String>{
          "Authorization": auth,
          "Content-Type": "application/json"
        },
        body: jsonEncode(<String, dynamic>{"tag_name": tagName}));
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body) as Map<String, dynamic>;
      return json["tag_id"];
    } else {
      return null;
    }
  }

  Future<List<Tag>> getAllTags() async {
    var response = await http.get(Uri.parse("$host/tags_list"));
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json["tags_list"] as List<dynamic>)
        .map((tag) => Tag(tag["id"], tag["name"]))
        .toList();
  }

  Future<bool> addTagToContest(String auth, Contest contest, int tagId) async {
    var response = await http.post(Uri.parse("$host/edit_contest"),
        headers: <String, String>{
          "Authorization": auth,
          "Content-Type": "application/json"
        },
        body: jsonEncode(<String, dynamic>{
          "contest_id": contest.id,
          "tags": contest.tags.map((e) => e.id).followedBy({tagId}).toList()
        }));
    return response.statusCode == 200;
  }

  Future<bool> removeTagFromContest(
      String auth, Contest contest, int tagId) async {
    var response = await http.post(Uri.parse("$host/edit_contest"),
        headers: <String, String>{
          "Authorization": auth,
          "Content-Type": "application/json"
        },
        body: jsonEncode(<String, dynamic>{
          "contest_id": contest.id,
          "tags": contest.tags
              .map((e) => e.id)
              .where((element) => element != tagId)
              .toList()
        }));
    return response.statusCode == 200;
  }
}
