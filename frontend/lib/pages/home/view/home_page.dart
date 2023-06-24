import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/pages/contests/view/contests_view.dart';

import '../../authentication/bloc/authentication_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => const HomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // var theme = EasyDynamicTheme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('LeetForces'),
            actions: [
              // IconButton(
              //   onPressed: () {},
              //   icon: Icon(
              //     theme == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              //   ),
              // ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person_outline_rounded),
              ),
              IconButton(
                onPressed: () {
                  context.read<AuthenticationBloc>().add(
                    AuthenticationLogoutRequested(),
                  );
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          ContestsView(),
        ],
      ),
      // body: BlocProvider(
      //   create: (context) {
      //     return HomeBloc(
      //       contestRepository:
      //           RepositoryProvider.of<ContestRepository>(context),
      //     );
      //   },
      //   child: const HomeView(),
      // ),
    );
  }
}
