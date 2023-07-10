import 'package:frontend/models/tag.dart';

class UserInfo {
  final String login;
  final String role;
  final String email;
  final List<Tag> tags;

  UserInfo(this.login, this.role, this.email, this.tags);
}
