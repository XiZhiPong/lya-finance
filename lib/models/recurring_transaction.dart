import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'recurring_transaction.g.dart';

CAtHiveType(typeId: 3)
class RecurringTransaction extends HiveObject {
  HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  bool isIncome;

  @HiveField(4)
  String category;

  @HiveField(5)
  String frequency; // daily, weekly, monthly, yearly

  @HiveField(6)
  int dayOfMonth; // 1-31 for monthly

  @HiveField(7)
  int dayOfWeek; // 0-6 for weekly (0 = Monday)

  @HiveField(8)
  DateTime startDate;

  @HiveField(9)
  DateTime? endDate;

  @HiveField(10)
  bool isActive;

  @HiveField(11)
  DateTime lastProcessed;

  @HiveField(12)
  String? note;

  RecurringTransaction({
    String? id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.frequency,
    this.dayOfMonth = 1,
    this.dayOfWeek = 0,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.lastProcessed,
    this.note,
  }) : id = id ?? const Uuid().v4();

  String get frequencyLabel {
    switch (frequency) {
      case 'daily':
        return 'Every day';
      case 'weekly':
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return 'Every ${days[dayOfWeek]}';
      case 'monthly':
        return 'Every month on day $dayOfMonth';
      case 'yearly':
        return 'Every year';
      default:
        return frequency;
    }
  }

  bool get shouldProcess {
    if (!isActive) return false;
    if (endDate != null && DateTime.now().isAfter(endDate!)) return false;
    
    final now = DateTime.now();
    final last = lastProcessed;
    
    switch (frequency) {
      case 'daily':
        return now.difference(last).inDays >= 1;
      case 'weekly':
        return now.difference(last).inDays >= 7;
      case 'monthly':
        return now.month != last.month || now.year != last.year;
      case 'yearly':
        return now.year != last.year;
      default:
        return false;
    }
  }

  DateTime get nextOccurrence {
    final now = DateTime.now();
    
    switch (frequency) {
      case 'daily':
        return now.add(const Duration(days: 1));
      case 'weekly':
        return now.add(Duration(days: 7 - now.weekday + 1 + dayOfWeek));
      case 'monthly':
        var next = DateTime(now.year, now.month + 1, dayOfMonth);
        if (next.isBefore(now)) {
          next = DateTime(now.year, now.month + 2, dayOfMonth);
        }
        return next;
      case 'yearly':
        return DateTime(now.year + 1, startDate.month, startDate.day);
      default:
        return now;
    }
  }
}
