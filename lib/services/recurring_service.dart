import 'package:hive/hive.dart';
import '../models/recurring_transaction.dart';
import '../models/transaction.dart';
import 'database_service.dart';

class RecurringService {
  static const String _boxName = 'recurring_transactions';
  late Box<RecurringTransaction> _box;

  Future<void> init() async {
    _box = await Hive.openBox<RecurringTransaction>(_boxName);
  }

  List<RecurringTransaction> getAll() {
    return _box.values.toList();
  }

  List<RecurringTransaction> getActive() {
    return _box.values.where((r) => r.isActive).toList();
  }

  Future<void> add(RecurringTransaction recurring) async {
    await _box.put(recurring.id, recurring);
  }

  Future<void> update(RecurringTransaction recurring) async {
    await _box.put(recurring.id, recurring);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleActive(String id) async {
    final recurring = _box.get(id);
    if (recurring != null) {
      recurring.isActive = !recurring.isActive;
      await recurring.save();
    }
  }

  Future<int> processDueTransactions(DatabaseService db) async {
    int processedCount = 0;
    final now = DateTime.now();
    
    for (final recurring in getActive()) {
      if (recurring.shouldProcess) {
        final transaction = Transaction(
          title: recurring.title,
          amount: recurring.amount,
          isIncome: recurring.isIncome,
          category: recurring.category,
          date: now,
          note: 'Auto: ${recurring.frequencyLabel}${recurring.note != null ? ' - ${recurring.note}' : ''}',
        );
        
        await db.addTransaction(transaction);
        recurring.lastProcessed = now;
        await recurring.save();
        processedCount++;
      }
    }
    
    return processedCount;
  }

  List<RecurringTransaction> getUpcoming({int days = 30}) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    
    return getActive().where((r) {
      final next = r.nextOccurrence;
      return next.isAfter(now) && next.isBefore(future);
    }).toList();
  }

  double getProjectedMonthlyAmount() {
    double total = 0;
    
    for (final recurring in getActive()) {
      double monthlyAmount = 0;
      
      switch (recurring.frequency) {
        case 'daily':
          monthlyAmount = recurring.amount * 30;
          break;
        case 'weekly':
          monthlyAmount = recurring.amount * 4.33;
          break;
        case 'monthly':
          monthlyAmount = recurring.amount;
          break;
        case 'yearly':
          monthlyAmount = recurring.amount / 12;
          break;
      }
      
      if (recurring.isIncome) {
        total += monthlyAmount;
      } else {
        total -= monthlyAmount;
      }
    }
    
    return total;
  }
}
