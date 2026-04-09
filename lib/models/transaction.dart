import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  food,
  transport,
  shopping,
  entertainment,
  health,
  utilities,
  salary,
  investment,
  other,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Food & Dining';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.health:
        return 'Health';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.investment:
        return 'Investment';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case TransactionCategory.food:
        return '🍔';
      case TransactionCategory.transport:
        return '🚌';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.entertainment:
        return '🎬';
      case TransactionCategory.health:
        return '💊';
      case TransactionCategory.utilities:
        return '💡';
      case TransactionCategory.salary:
        return '💼';
      case TransactionCategory.investment:
        return '📈';
      case TransactionCategory.other:
        return '💰';
    }
  }
}

class Transaction extends Equatable {
  final String id;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String title;
  final String? notes;

  const Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.title,
    this.notes,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? title,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      title: title ?? this.title,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'type': type.index,
        'category': category.index,
        'date': date.toIso8601String(),
        'title': title,
        'notes': notes,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        amount: json['amount'].toDouble(),
        type: TransactionType.values[json['type']],
        category: TransactionCategory.values[json['category']],
        date: DateTime.parse(json['date']),
        title: json['title'],
        notes: json['notes'],
      );

  @override
  List<Object?> get props => [id, amount, type, category, date, title, notes];
}
