import 'dart:convert';

import 'package:frontend/models/userinfo.dart';

import '../env/config.dart';
import '../models/tag.dart';
import 'package:http/http.dart' as http;

class TagRepository {
  Future<List<Tag>> getAllTags() async {
    var response = await http.get(Uri.parse("$host/tags_list"));
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json["tags_list"] as List<dynamic>)
        .map((tag) => Tag(tag["id"], tag["name"]))
        .toList();
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

  Future<void> addUserTag(String jwt, int userId, int tagId) async {
    var response = await http.post(Uri.parse("$host/add_tag_to_user"),
        body: jsonEncode(<String, dynamic>{
          "tag_id": tagId,
          "user_id": userId,
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

  Future<void> removeUserTag(String jwt, UserInfo userInfo, int tagId) async {
    var response = await http.post(Uri.parse("$host/edit_user"),
        body: jsonEncode(<String, dynamic>{
          "user_id": userInfo.id,
          "tags": userInfo.tags
              .map((e) => e.id)
              .where((element) => element != tagId)
              .toList(),
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

  Future<List<UserInfo>> getUsersByTag(String jwt, int tagId) async {
    var response = await http.get(Uri.parse("$host/get_users_by_tag/$tagId"),
        headers: <String, String>{
          "Authorization": jwt,
        });
    if (response.statusCode != 200) {
      var json = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(json['message']);
    }
    var json = jsonDecode(response.body) as List<dynamic>;
    return json.map((e) => UserInfo.fromJson(e)).toList();
  }
}
