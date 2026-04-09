import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gap/gap.dart';
import 'package:collection/collection.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../models/transaction.dart';
import '../../utils/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/common/common_widgets.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TransactionLoaded) {
            if (state.transactions.isEmpty) {
              return const EmptyState(
                emoji: '📊',
                title: 'No data yet',
                subtitle: 'Add some transactions to\nsee your insights!',
              );
            }
            return _InsightsContent(transactions: state.transactions);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  final List<Transaction> transactions;

  const _InsightsContent({required this.transactions});

  Map<TransactionCategory, double> get _expenseByCategory {
    final expenses =
        transactions.where((t) => t.type == TransactionType.expense);
    final map = <TransactionCategory, double>{};
    for (final t in expenses) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  Map<int, double> get _expenseByDayOfWeek {
    final now = DateTime.now();
    final map = <int, double>{};
    for (var i = 0; i < 7; i++) {
      map[i] = 0;
    }
    for (final t in transactions) {
      final diff = now.difference(t.date).inDays;
      if (diff < 7 && t.type == TransactionType.expense) {
        final weekday = (6 - diff).clamp(0, 6);
        map[weekday] = (map[weekday] ?? 0) + t.amount;
      }
    }
    return map;
  }

  double get _totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (s, t) => s + t.amount);

  double get _totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (s, t) => s + t.amount);

  @override
  Widget build(BuildContext context) {
    final catData = _expenseByCategory;
    final topCategory = catData.entries.isEmpty
        ? null
        : catData.entries.reduce((a, b) => a.value > b.value ? a : b);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Total Income',
                amount: _totalIncome,
                color: AppTheme.accentGreen,
                emoji: '💚',
              ).animate().fadeIn(duration: 400.ms),
            ),
            const Gap(12),
            Expanded(
              child: _SummaryCard(
                label: 'Total Spent',
                amount: _totalExpense,
                color: AppTheme.accentRed,
                emoji: '❤️',
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            ),
          ],
        ),
        const Gap(24),

        // Top spending category
        if (topCategory != null) ...[
          const SectionHeader(title: 'Top Spending Category'),
          const Gap(12),
          _TopCategoryCard(
            category: topCategory.key,
            amount: topCategory.value,
            percentage: _totalExpense > 0
                ? (topCategory.value / _totalExpense * 100)
                : 0,
          ).animate().fadeIn(delay: 150.ms),
          const Gap(24),
        ],

        // Weekly spending bar chart
        const SectionHeader(title: 'This Week\'s Spending'),
        const Gap(12),
        _WeeklyChart(weekData: _expenseByDayOfWeek)
            .animate()
            .fadeIn(delay: 200.ms),
        const Gap(24),

        // Category breakdown pie chart
        if (catData.isNotEmpty) ...[
          const SectionHeader(title: 'Spending Breakdown'),
          const Gap(12),
          _CategoryPieChart(data: catData).animate().fadeIn(delay: 250.ms),
          const Gap(24),
          const SectionHeader(title: 'By Category'),
          const Gap(12),
          ...catData.entries.sorted((a, b) => b.value.compareTo(a.value)).map(
                (e) => _CategoryRow(
                  category: e.key,
                  amount: e.value,
                  percentage: _totalExpense > 0 ? (e.value / _totalExpense) : 0,
                ).animate().fadeIn(delay: 300.ms),
              ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String emoji;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: .2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const Gap(8),
          Text(
            Formatters.currency(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
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
    );
  }
}

class _TopCategoryCard extends StatelessWidget {
  final TransactionCategory category;
  final double amount;
  final double percentage;

  const _TopCategoryCard({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentRed.withValues(alpha: .15),
            AppTheme.accentOrange.withValues(alpha: .08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentRed.withValues(alpha: .2)),
      ),
      child: Row(
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 36)),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% of total spending',
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
            Formatters.currency(amount),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: AppTheme.accentRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Map<int, double> weekData;

  const _WeeklyChart({required this.weekData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = weekData.values.isEmpty
        ? 1.0
        : weekData.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: .05), blurRadius: 12)
              ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppTheme.primaryLight,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        Formatters.currency(rod.toY),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        days[value.toInt()],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: weekData.entries.map((e) {
                  final isToday = e.key == 6;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: isToday
                            ? AppTheme.primaryLight
                            : AppTheme.primaryLight.withValues(alpha: .35),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<TransactionCategory, double> data;

  const _CategoryPieChart({required this.data});

  static const _colors = [
    AppTheme.primaryLight,
    AppTheme.accentGreen,
    AppTheme.accentRed,
    AppTheme.accentOrange,
    Color(0xFF60E0FA),
    Color(0xFFB983FF),
    Color(0xFFFF8FAB),
    Color(0xFF59D2FE),
    Color(0xFF40C9A2),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = data.values.fold(0.0, (s, v) => s + v);
    final entries = data.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: .05), blurRadius: 12)
              ],
      ),
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: 55,
            sections: entries.asMap().entries.map((e) {
              final color = _colors[e.key % _colors.length];
              final pct = total > 0 ? (e.value.value / total * 100) : 0.0;
              return PieChartSectionData(
                value: e.value.value,
                title: pct > 8 ? '${pct.toStringAsFixed(0)}%' : '',
                color: color,
                radius: 60,
                titleStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final TransactionCategory category;
  final double amount;
  final double percentage;

  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(category.emoji, style: const TextStyle(fontSize: 22)),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category.label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      Formatters.currency(amount),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const Gap(6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor:
                        AppTheme.primaryLight.withValues(alpha: .1),
                    valueColor:
                        const AlwaysStoppedAnimation(AppTheme.primaryLight),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
