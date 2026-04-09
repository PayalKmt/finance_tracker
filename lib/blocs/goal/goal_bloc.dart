import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/goal.dart';
import '../../repositories/goal_repository.dart';

part 'goal_event.dart';
part 'goal_state.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository repository;

  GoalBloc({required this.repository}) : super(GoalInitial()) {
    on<LoadGoals>(_onLoad);
    on<AddGoal>(_onAdd);
    on<UpdateGoal>(_onUpdate);
    on<DeleteGoal>(_onDelete);
    on<UpdateGoalProgress>(_onUpdateProgress);
  }

  Future<void> _onLoad(LoadGoals event, Emitter<GoalState> emit) async {
    emit(GoalLoading());
    try {
      final goals = await repository.getGoals();
      emit(GoalLoaded(goals: goals));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onAdd(AddGoal event, Emitter<GoalState> emit) async {
    if (state is GoalLoaded) {
      final current = state as GoalLoaded;
      await repository.addGoal(event.goal);
      emit(GoalLoaded(goals: [...current.goals, event.goal]));
    }
  }

  Future<void> _onUpdate(UpdateGoal event, Emitter<GoalState> emit) async {
    if (state is GoalLoaded) {
      final current = state as GoalLoaded;
      await repository.updateGoal(event.goal);
      final updated = current.goals
          .map((g) => g.id == event.goal.id ? event.goal : g)
          .toList();
      emit(GoalLoaded(goals: updated));
    }
  }

  Future<void> _onDelete(DeleteGoal event, Emitter<GoalState> emit) async {
    if (state is GoalLoaded) {
      final current = state as GoalLoaded;
      await repository.deleteGoal(event.id);
      emit(GoalLoaded(
          goals: current.goals.where((g) => g.id != event.id).toList()));
    }
  }

  Future<void> _onUpdateProgress(
      UpdateGoalProgress event, Emitter<GoalState> emit) async {
    if (state is GoalLoaded) {
      final current = state as GoalLoaded;
      final goal = current.goals.firstWhere((g) => g.id == event.id);
      final updated = goal.copyWith(currentAmount: event.amount);
      await repository.updateGoal(updated);
      final updatedList = current.goals
          .map((g) => g.id == event.id ? updated : g)
          .toList();
      emit(GoalLoaded(goals: updatedList));
    }
  }
}
