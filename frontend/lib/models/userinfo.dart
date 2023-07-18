import 'package:frontend/models/tag.dart';

class UserInfo {
  final int id;
  final String login;
  final String role;
  final List<Tag> tags;

  UserInfo(this.id, this.login, this.role, this.tags);

  static UserInfo fromJson(dynamic json) {
    var tags = (json["tags"] as List<dynamic>)
        .map((tag) => Tag(tag["id"], tag["name"]))
        .toList();
    return UserInfo(
      json["id"],
      json["login"],
      json["role"],
      tags,
    );
  }
}

class EmailedUserInfo extends UserInfo {
  String email;

  EmailedUserInfo(super.id, super.login, super.role, this.email, super.tags);
}
