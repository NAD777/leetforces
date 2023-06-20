part of 'home_bloc.dart';

@immutable
sealed class HomeEvent extends Equatable {}

class HomeGotContestListEvent extends HomeEvent {
  HomeGotContestListEvent(this.contests);

  final List<Contest> contests;

  @override
  List<Object?> get props => contests;
}

class HomeGotError extends HomeEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
