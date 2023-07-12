import 'package:frontend/models/tag.dart';

class UserInfo {
  final int id;
  final String login;
  final String role;
  final String email;
  final List<Tag> tags;

  UserInfo(this.id, this.login, this.role, this.email, this.tags);
}
