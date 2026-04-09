part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();
  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final List<Transaction> filtered;
  final String? searchQuery;
  final TransactionType? typeFilter;
  final TransactionCategory? categoryFilter;

  const TransactionLoaded({
    required this.transactions,
    required this.filtered,
    this.searchQuery,
    this.typeFilter,
    this.categoryFilter,
  });

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props =>
      [transactions, filtered, searchQuery, typeFilter, categoryFilter];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
  @override
  List<Object?> get props => [message];
}
