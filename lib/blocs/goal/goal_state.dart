part of 'goal_bloc.dart';

abstract class GoalState extends Equatable {
  const GoalState();
  @override
  List<Object?> get props => [];
}

class GoalInitial extends GoalState {}

class GoalLoading extends GoalState {}

class GoalLoaded extends GoalState {
  final List<Goal> goals;

  const GoalLoaded({required this.goals});

  List<Goal> get activeGoals =>
      goals.where((g) => g.status == GoalStatus.active).toList();

  List<Goal> get completedGoals =>
      goals.where((g) => g.status == GoalStatus.completed).toList();

  @override
  List<Object?> get props => [goals];
}

class GoalError extends GoalState {
  final String message;
  const GoalError(this.message);
  @override
  List<Object?> get props => [message];
}
