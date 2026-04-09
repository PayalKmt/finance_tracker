import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';
import '../../blocs/goal/goal_bloc.dart';
import '../../models/goal.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/common_widgets.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals & Challenges')),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          if (state is GoalLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GoalLoaded) {
            if (state.goals.isEmpty) {
              return const EmptyState(
                emoji: '🎯',
                title: 'No goals yet',
                subtitle: 'Create your first goal\nto start saving smarter!',
              );
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (state.activeGoals.isNotEmpty) ...[
                  const SectionHeader(title: '🔥 Active'),
                  const Gap(12),
                  ...state.activeGoals.asMap().entries.map(
                        (e) => GoalCard(goal: e.value)
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: e.key * 80))
                            .slideY(begin: 0.1, end: 0),
                      ),
                  const Gap(20),
                ],
                if (state.completedGoals.isNotEmpty) ...[
                  const SectionHeader(title: '✅ Completed'),
                  const Gap(12),
                  ...state.completedGoals.map((g) => GoalCard(goal: g)),
                ],
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalSheet(context),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Goal',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<GoalBloc>(),
        child: const AddGoalSheet(),
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final Goal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = goal.status == GoalStatus.completed;

    Color progressColor;
    switch (goal.type) {
      case GoalType.savings:
        progressColor = AppTheme.accentGreen;
        break;
      case GoalType.noSpend:
        progressColor = AppTheme.accentOrange;
        break;
      case GoalType.budget:
        progressColor =
            goal.progress > 0.8 ? AppTheme.accentRed : AppTheme.primaryLight;
        break;
      case GoalType.streak:
        progressColor = AppTheme.accentOrange;
        break;
    }

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppTheme.accentRed.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: AppTheme.accentRed),
      ),
      onDismissed: (_) => context.read<GoalBloc>().add(DeleteGoal(goal.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
          border: isCompleted
              ? Border.all(color: AppTheme.accentGreen.withValues(alpha: .5))
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(goal.emoji ?? '🎯', style: const TextStyle(fontSize: 32)),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ),
                          if (goal.type == GoalType.streak)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentOrange
                                    .withValues(alpha: .15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🔥 ${goal.streakDays}d',
                                style: const TextStyle(
                                  color: AppTheme.accentOrange,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        goal.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: .6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Formatters.currency(goal.currentAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: progressColor,
                  ),
                ),
                Text(
                  'of ${Formatters.currency(goal.targetAmount)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: .5),
                  ),
                ),
                Text(
                  goal.daysRemaining > 0
                      ? '${goal.daysRemaining}d left'
                      : 'Ended',
                  style: TextStyle(
                    fontSize: 12,
                    color: goal.daysRemaining <= 3
                        ? AppTheme.accentRed
                        : Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: .5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Gap(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: progressColor.withValues(alpha: .15),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            if (!isCompleted && goal.type == GoalType.savings) ...[
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showUpdateProgress(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: progressColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Update Progress',
                        style: TextStyle(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showUpdateProgress(BuildContext context) {
    final ctrl =
        TextEditingController(text: goal.currentAmount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Progress'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: '₹ ',
            hintText: 'Current saved amount',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(ctrl.text);
              if (amount != null) {
                context.read<GoalBloc>().add(UpdateGoalProgress(
                      id: goal.id,
                      amount: amount,
                    ));
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class AddGoalSheet extends StatefulWidget {
  const AddGoalSheet({super.key});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _targetController = TextEditingController();
  GoalType _type = GoalType.savings;
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _emoji = '🎯';

  final _emojis = [
    '🎯',
    '🛡️',
    '🏖️',
    '🚗',
    '🏠',
    '💍',
    '📱',
    '🚫',
    '🍱',
    '💪'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.isEmpty || _targetController.text.isEmpty) return;

    final goal = Goal(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      type: _type,
      targetAmount: double.tryParse(_targetController.text) ?? 0,
      currentAmount: 0,
      startDate: DateTime.now(),
      endDate: _endDate,
      status: GoalStatus.active,
      emoji: _emoji,
    );

    context.read<GoalBloc>().add(AddGoal(goal));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),
            const Text('New Goal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const Gap(20),

            // Emoji picker
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _emojis.map((e) {
                  final selected = _emoji == e;
                  return GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryLight.withValues(alpha: .2)
                            : isDark
                                ? AppTheme.cardDark
                                : const Color(0xFFF0EEFF),
                        borderRadius: BorderRadius.circular(12),
                        border: selected
                            ? Border.all(color: AppTheme.primaryLight)
                            : null,
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Goal title'),
            ),
            const Gap(12),
            TextField(
              controller: _descController,
              decoration:
                  const InputDecoration(hintText: 'Description (optional)'),
            ),
            const Gap(12),
            TextField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Target amount',
                prefixText: '₹ ',
              ),
            ),
            const Gap(16),

            // Goal type
            const Text('Type',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const Gap(10),
            Wrap(
              spacing: 8,
              children: GoalType.values.map((t) {
                final labels = {
                  GoalType.savings: '💰 Savings',
                  GoalType.noSpend: '🚫 No-Spend',
                  GoalType.budget: '📊 Budget',
                  GoalType.streak: '🔥 Streak',
                };
                return AppChip(
                  label: labels[t]!,
                  selected: _type == t,
                  onTap: () => setState(() => _type = t),
                );
              }).toList(),
            ),
            const Gap(16),

            // End date
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _endDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : const Color(0xFFF0EEFF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppTheme.primaryLight, size: 18),
                    const Gap(10),
                    Text(
                      'End date: ${_endDate.day}/${_endDate.month}/${_endDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(24),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Create Goal',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
