import 'package:equatable/equatable.dart';

enum GoalType { savings, noSpend, budget, streak }

enum GoalStatus { active, completed, failed }

class Goal extends Equatable {
  final String id;
  final String title;
  final String description;
  final GoalType type;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final GoalStatus status;
  final int streakDays;
  final String? emoji;

  const Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetAmount,
    required this.currentAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.streakDays = 0,
    this.emoji,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => currentAmount >= targetAmount;

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalType? type,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? endDate,
    GoalStatus? status,
    int? streakDays,
    String? emoji,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      streakDays: streakDays ?? this.streakDays,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.index,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'status': status.index,
        'streakDays': streakDays,
        'emoji': emoji,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        type: GoalType.values[json['type']],
        targetAmount: json['targetAmount'].toDouble(),
        currentAmount: json['currentAmount'].toDouble(),
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        status: GoalStatus.values[json['status']],
        streakDays: json['streakDays'] ?? 0,
        emoji: json['emoji'],
      );

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        type,
        targetAmount,
        currentAmount,
        startDate,
        endDate,
        status,
        streakDays,
        emoji,
      ];
}
