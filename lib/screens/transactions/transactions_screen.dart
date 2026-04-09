import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../blocs/transaction/transaction_bloc.dart';
import '../../models/transaction.dart';
import '../../widgets/common/common_widgets.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _searchController = TextEditingController();
  TransactionType? _selectedType;
  TransactionCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter() {
    context.read<TransactionBloc>().add(FilterTransactions(
          query: _searchController.text,
          type: _selectedType,
          category: _selectedCategory,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _filter(),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _filter();
                            },
                          )
                        : null,
                  ),
                ),
                const Gap(10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AppChip(
                        label: 'All',
                        selected: _selectedType == null,
                        onTap: () {
                          setState(() => _selectedType = null);
                          _filter();
                        },
                      ),
                      const Gap(8),
                      AppChip(
                        label: '💚 Income',
                        selected: _selectedType == TransactionType.income,
                        onTap: () {
                          setState(() => _selectedType =
                              _selectedType == TransactionType.income
                                  ? null
                                  : TransactionType.income);
                          _filter();
                        },
                      ),
                      const Gap(8),
                      AppChip(
                        label: '❤️ Expense',
                        selected: _selectedType == TransactionType.expense,
                        onTap: () {
                          setState(() => _selectedType =
                              _selectedType == TransactionType.expense
                                  ? null
                                  : TransactionType.expense);
                          _filter();
                        },
                      ),
                      const Gap(8),
                      ...TransactionCategory.values.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AppChip(
                            label: '${cat.emoji} ${cat.label}',
                            selected: _selectedCategory == cat,
                            onTap: () {
                              setState(() => _selectedCategory =
                                  _selectedCategory == cat ? null : cat);
                              _filter();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TransactionLoaded) {
                  if (state.filtered.isEmpty) {
                    return const EmptyState(
                      emoji: '🔍',
                      title: 'No transactions found',
                      subtitle:
                          'Try adjusting your filters\nor add a new transaction',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final t = state.filtered[index];
                      return TransactionTile(
                        transaction: t,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddTransactionScreen(transaction: t),
                          ),
                        ),
                        onDelete: () => context
                            .read<TransactionBloc>()
                            .add(DeleteTransaction(t.id)),
                      ).animate().fadeIn(
                          delay: Duration(milliseconds: index * 40),
                          duration: 250.ms);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
