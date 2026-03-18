import 'package:hive/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 3)
class SavingsGoal {
  @HiveField(0) final String id;
  @HiveField(1) final String title;
  @HiveField(2) final String description;
  @HiveField(3) final double targetAmount;
  @HiveField(4) final double currentAmount;
  @HiveField(5) final DateTime deadline;
  @HiveField(6) final DateTime createdAt;
  @HiveField(7) final String emoji;
  @HiveField(8) final bool isCompleted;

  SavingsGoal({required this.id, required this.title, this.description = '', required this.targetAmount, this.currentAmount = 0.0, required this.deadline, required this.createdAt, this.emoji = '🎯', this.isCompleted = false});

  SavingsGoal copyWith({String? id, String? title, String? description, double? targetAmount, double? currentAmount, DateTime? deadline, DateTime? createdAt, String? emoji, bool? isCompleted}) {
    return SavingsGoal(id: id ?? this.id, title: title ?? this.title, description: description ?? this.description, targetAmount: targetAmount ?? this.targetAmount, currentAmount: currentAmount ?? this.currentAmount, deadline: deadline ?? this.deadline, createdAt: createdAt ?? this.createdAt, emoji: emoji ?? this.emoji, isCompleted: isCompleted ?? this.isCompleted);
  }

  double get percentage => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remaining => targetAmount - currentAmount;
  bool get isNearDeadline => deadline.difference(DateTime.now()).inDays <= 7;
  int get daysLeft => deadline.difference(DateTime.now()).inDays;
}
