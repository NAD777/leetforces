import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/pages/home/bloc/home_bloc.dart';
import 'package:frontend/pages/home/view/home_view.dart';
import 'package:frontend/repositories/contest_repository/contest_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => const HomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = EasyDynamicTheme.of(context).themeMode;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // IconButton(
          //   onPressed: () {},
          //   icon: Icon(
          //     theme
          //   ),
          // ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
      body: BlocProvider(
        create: (context) {
          return HomeBloc(
            contestRepository:
                RepositoryProvider.of<ContestRepository>(context),
          );
        },
        child: const HomeView(),
      ),
    );
  }
}
