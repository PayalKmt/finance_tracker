import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';

class GoalRepository {
  static const _key = 'goals';

  Future<List<Goal>> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return _seedGoals();
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Goal.fromJson(e)).toList();
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(goals.map((g) => g.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> addGoal(Goal goal) async {
    final goals = await getGoals();
    goals.add(goal);
    await saveGoals(goals);
  }

  Future<void> updateGoal(Goal goal) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = goal;
      await saveGoals(goals);
    }
  }

  Future<void> deleteGoal(String id) async {
    final goals = await getGoals();
    goals.removeWhere((g) => g.id == id);
    await saveGoals(goals);
  }

  List<Goal> _seedGoals() {
    final now = DateTime.now();
    return [
      Goal(
        id: '1',
        title: 'Emergency Fund',
        description: 'Save 3 months of expenses',
        type: GoalType.savings,
        targetAmount: 50000,
        currentAmount: 32000,
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 60)),
        status: GoalStatus.active,
        emoji: '🛡️',
      ),
      Goal(
        id: '2',
        title: 'No-Spend Weekend',
        description: 'Avoid all non-essential spending this weekend',
        type: GoalType.noSpend,
        targetAmount: 1,
        currentAmount: 0,
        startDate: now,
        endDate: now.add(const Duration(days: 2)),
        status: GoalStatus.active,
        streakDays: 5,
        emoji: '🚫',
      ),
      Goal(
        id: '3',
        title: 'Monthly Food Budget',
        description: 'Keep food expenses under ₹8,000',
        type: GoalType.budget,
        targetAmount: 8000,
        currentAmount: 5200,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        status: GoalStatus.active,
        emoji: '🍱',
      ),
    ];
  }
}
