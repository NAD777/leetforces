// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:frontend/repositories/contest_repository/contest_repository.dart';
// import 'package:meta/meta.dart';
//
// import '../../../repositories/contest_repository/models/contest.dart';
//
// part 'home_event.dart';
//
// part 'home_state.dart';
//
// class HomeBloc extends Bloc<HomeEvent, HomeState> {
//   HomeBloc({required ContestRepository contestRepository})
//       : _contestRepository = contestRepository,
//         super(HomeState([])) {
//     on<HomeGotContestListEvent>(_onHomeGotContestListEvent);
//     _contestRepository
//         .getContests()
//         .then((value) => add(HomeGotContestListEvent(value)));
//   }
//
//   final ContestRepository _contestRepository;
//
//   void _onHomeGotContestListEvent(
//     HomeGotContestListEvent event,
//     Emitter<HomeState> emit,
//   ) {
//     emit(HomeState(event.contests));
//   }
// }
