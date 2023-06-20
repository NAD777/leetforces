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
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
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
