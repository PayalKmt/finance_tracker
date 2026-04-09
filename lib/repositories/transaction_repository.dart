import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class TransactionRepository {
  static const _key = 'transactions';

  Future<List<Transaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return _seedData();
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(transactions.map((t) => t.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> addTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    transactions.insert(0, transaction);
    await saveTransactions(transactions);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }

  List<Transaction> _seedData() {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1',
        amount: 85000,
        type: TransactionType.income,
        category: TransactionCategory.salary,
        date: now.subtract(const Duration(days: 1)),
        title: 'Monthly Salary',
        notes: 'June salary credited',
      ),
      Transaction(
        id: '2',
        amount: 1200,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(days: 1)),
        title: 'Lunch at Cafe',
        notes: 'Team lunch',
      ),
      Transaction(
        id: '3',
        amount: 3500,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: now.subtract(const Duration(days: 2)),
        title: 'Grocery Shopping',
      ),
      Transaction(
        id: '4',
        amount: 500,
        type: TransactionType.expense,
        category: TransactionCategory.transport,
        date: now.subtract(const Duration(days: 2)),
        title: 'Uber Ride',
      ),
      Transaction(
        id: '5',
        amount: 15000,
        type: TransactionType.income,
        category: TransactionCategory.investment,
        date: now.subtract(const Duration(days: 3)),
        title: 'Dividend Income',
        notes: 'Quarterly dividend',
      ),
      Transaction(
        id: '6',
        amount: 800,
        type: TransactionType.expense,
        category: TransactionCategory.entertainment,
        date: now.subtract(const Duration(days: 4)),
        title: 'Netflix Subscription',
      ),
      Transaction(
        id: '7',
        amount: 2200,
        type: TransactionType.expense,
        category: TransactionCategory.utilities,
        date: now.subtract(const Duration(days: 5)),
        title: 'Electricity Bill',
      ),
      Transaction(
        id: '8',
        amount: 950,
        type: TransactionType.expense,
        category: TransactionCategory.health,
        date: now.subtract(const Duration(days: 6)),
        title: 'Pharmacy',
        notes: 'Monthly medicines',
      ),
      Transaction(
        id: '9',
        amount: 450,
        type: TransactionType.expense,
        category: TransactionCategory.food,
        date: now.subtract(const Duration(days: 7)),
        title: 'Coffee & Snacks',
      ),
      Transaction(
        id: '10',
        amount: 5000,
        type: TransactionType.expense,
        category: TransactionCategory.shopping,
        date: now.subtract(const Duration(days: 8)),
        title: 'Online Purchase',
        notes: 'Amazon order',
      ),
    ];
  }
}
