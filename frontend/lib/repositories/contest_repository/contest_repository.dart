import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/contest.dart';

class ContestRepository {
  Future<List<Contest>> getContests() async {
    var response = await http.get(
      Uri.parse("/list_contests"),
      //headers: <String, String>{""},
      // TODO: contests
    );
    var json = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      var list = json['contest_list'] as List<Map<String, dynamic>>;
      var contests = list
          .map((e) => Contest(id: e["contest_id"], name: e["contest_name"]))
          .toList();
      return contests;
    } else {
      throw Exception();
    }
  }
}
