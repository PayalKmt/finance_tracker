import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/transaction.dart';
import '../../repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;

  TransactionBloc({required this.repository}) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<AddTransaction>(_onAdd);
    on<UpdateTransaction>(_onUpdate);
    on<DeleteTransaction>(_onDelete);
    on<FilterTransactions>(_onFilter);
  }

  Future<void> _onLoad(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await repository.getTransactions();
      emit(TransactionLoaded(
        transactions: transactions,
        filtered: transactions,
      ));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onAdd(
      AddTransaction event, Emitter<TransactionState> emit) async {
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      await repository.addTransaction(event.transaction);
      final updated = [event.transaction, ...current.transactions];
      emit(TransactionLoaded(
        transactions: updated,
        filtered: _applyFilter(
            updated, current.searchQuery, current.typeFilter, current.categoryFilter),
        searchQuery: current.searchQuery,
        typeFilter: current.typeFilter,
        categoryFilter: current.categoryFilter,
      ));
    }
  }

  Future<void> _onUpdate(
      UpdateTransaction event, Emitter<TransactionState> emit) async {
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      await repository.updateTransaction(event.transaction);
      final updated = current.transactions
          .map((t) => t.id == event.transaction.id ? event.transaction : t)
          .toList();
      emit(TransactionLoaded(
        transactions: updated,
        filtered: _applyFilter(
            updated, current.searchQuery, current.typeFilter, current.categoryFilter),
        searchQuery: current.searchQuery,
        typeFilter: current.typeFilter,
        categoryFilter: current.categoryFilter,
      ));
    }
  }

  Future<void> _onDelete(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      await repository.deleteTransaction(event.id);
      final updated =
          current.transactions.where((t) => t.id != event.id).toList();
      emit(TransactionLoaded(
        transactions: updated,
        filtered: _applyFilter(
            updated, current.searchQuery, current.typeFilter, current.categoryFilter),
        searchQuery: current.searchQuery,
        typeFilter: current.typeFilter,
        categoryFilter: current.categoryFilter,
      ));
    }
  }

  void _onFilter(
      FilterTransactions event, Emitter<TransactionState> emit) {
    if (state is TransactionLoaded) {
      final current = state as TransactionLoaded;
      emit(TransactionLoaded(
        transactions: current.transactions,
        filtered: _applyFilter(
            current.transactions, event.query, event.type, event.category),
        searchQuery: event.query,
        typeFilter: event.type,
        categoryFilter: event.category,
      ));
    }
  }

  List<Transaction> _applyFilter(
    List<Transaction> transactions,
    String? query,
    TransactionType? type,
    TransactionCategory? category,
  ) {
    return transactions.where((t) {
      final matchQuery = query == null ||
          query.isEmpty ||
          t.title.toLowerCase().contains(query.toLowerCase()) ||
          (t.notes?.toLowerCase().contains(query.toLowerCase()) ?? false);
      final matchType = type == null || t.type == type;
      final matchCategory = category == null || t.category == category;
      return matchQuery && matchType && matchCategory;
    }).toList();
  }
}
