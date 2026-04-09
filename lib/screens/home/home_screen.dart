import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../blocs/goal/goal_bloc.dart';
import '../../models/transaction.dart';
import '../../models/goal.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/common_widgets.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transactions_screen.dart';
import '../goals/goals_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<TransactionBloc>().add(LoadTransactions());
            context.read<GoalBloc>().add(LoadGoals());
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const Gap(24),
                      _buildBalanceCard(context),
                      const Gap(28),
                      _buildQuickActions(context),
                      const Gap(28),
                      _buildGoalsSummary(context),
                      const Gap(28),
                      SectionHeader(
                        title: 'Recent Transactions',
                        action: 'See All',
                        onAction: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TransactionsScreen()),
                        ),
                      ),
                      const Gap(12),
                    ],
                  ),
                ),
              ),
              _buildRecentTransactions(context),
              const SliverToBoxAdapter(child: Gap(100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: AppTheme.primaryLight,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ).animate().slideY(begin: 1, end: 0, delay: 300.ms, duration: 400.ms),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: .6),
              ),
            ),
            const Text(
              'My Finances 💰',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.notifications_outlined,
              color: AppTheme.primaryLight),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }

  Widget _buildBalanceCard(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          return BalanceCard(
            balance: state.balance,
            income: state.totalIncome,
            expense: state.totalExpense,
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
        }
        return const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.add_circle_outline_rounded,
        'label': 'Income',
        'color': AppTheme.accentGreen
      },
      {
        'icon': Icons.remove_circle_outline_rounded,
        'label': 'Expense',
        'color': AppTheme.accentRed
      },
      {
        'icon': Icons.flag_outlined,
        'label': 'Goals',
        'color': AppTheme.accentOrange
      },
      {
        'icon': Icons.bar_chart_rounded,
        'label': 'Insights',
        'color': AppTheme.primaryLight
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const Gap(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.asMap().entries.map((entry) {
            final i = entry.key;
            final a = entry.value;
            return _QuickActionItem(
              icon: a['icon'] as IconData,
              label: a['label'] as String,
              color: a['color'] as Color,
              onTap: () {
                if (a['label'] == 'Goals') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const GoalsScreen()));
                } else if (a['label'] == 'Income') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(
                          initialType: TransactionType.income),
                    ),
                  );
                } else if (a['label'] == 'Expense') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(
                          initialType: TransactionType.expense),
                    ),
                  );
                }
              },
            ).animate().fadeIn(delay: Duration(milliseconds: 150 + i * 60));
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalsSummary(BuildContext context) {
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        if (state is! GoalLoaded || state.activeGoals.isEmpty) {
          return const SizedBox.shrink();
        }
        final goal = state.activeGoals.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Active Goals',
              action: 'See All',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoalsScreen()),
              ),
            ),
            const Gap(12),
            _GoalSummaryCard(goal: goal),
          ],
        ).animate().fadeIn(delay: 200.ms);
      },
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is TransactionLoaded) {
          final recent = state.transactions.take(5).toList();
          if (recent.isEmpty) {
            return const SliverToBoxAdapter(
              child: EmptyState(
                emoji: '💳',
                title: 'No transactions yet',
                subtitle: 'Add your first transaction\nto get started!',
              ),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => TransactionTile(
                  transaction: recent[index],
                  onDelete: () => context
                      .read<TransactionBloc>()
                      .add(DeleteTransaction(recent[index].id)),
                ).animate().fadeIn(
                    delay: Duration(milliseconds: index * 60),
                    duration: 300.ms),
                childCount: recent.length,
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const Gap(6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalSummaryCard extends StatelessWidget {
  final Goal goal;

  const _GoalSummaryCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(goal.emoji ?? '🎯', style: const TextStyle(fontSize: 28)),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    Text(
                      '${Formatters.currency(goal.currentAmount)} of ${Formatters.currency(goal.targetAmount)}',
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
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppTheme.primaryLight,
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: AppTheme.primaryLight.withValues(alpha: .15),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
