import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/userinfo.dart';
import 'package:frontend/repositories/user_repository.dart';
import 'package:frontend/widgets/tags_list_view.dart';
import 'package:frontend/widgets/template.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserInfo? userInfo;

  @override
  void initState() {
    super.initState();
    RepositoryProvider.of<UserRepository>(context).getUserInfo().then((value) {
      setState(() {
        userInfo = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Template(
      content: Center(
        child: userInfo == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: <Widget>[
                  const CircleAvatar(
                    radius: 50,
                  ),
                  const SizedBox(height: 20),
                  TagsListView(
                    tags: userInfo!.tags,
                    isAdmin: false,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${userInfo?.login}',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.headlineMedium?.fontSize,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${userInfo?.email}',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.headlineMedium?.fontSize,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${userInfo?.role}',
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.headlineMedium?.fontSize,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
