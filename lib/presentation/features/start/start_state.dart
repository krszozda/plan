part of 'start_bloc.dart';

abstract class StartState extends Equatable {
  const StartState();
}

class StartInitial extends StartState {
  @override
  List<Object> get props => [];
}
