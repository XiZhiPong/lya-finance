import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 2)
class Budget {
  @HiveField(0) final String id;
  @HiveField(1) final String category;
  @HiveField(2) final double amount;
  @HiveField(3) final double spent;
  @HiveField(4) final DateTime month;

  Budget({required this.id, required this.category, required this.amount, this.spent = 0.0, required this.month});

  Budget copyWith({String? id, String? category, double? amount, double? spent, DateTime? month}) {
    return Budget(id: id ?? this.id, category: category ?? this.category, amount: amount ?? this.amount, spent: spent ?? this.spent, month: month ?? this.month);
  }

  double get remaining => amount - spent;
  double get percentage => amount > 0 ? (spent / amount).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spent > amount;
}
