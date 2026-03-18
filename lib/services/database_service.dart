import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Box<Transaction>? _transactionBox;
  Box<Budget>? _budgetBox;
  Box<SavingsGoal>? _savingsGoalBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(SavingsGoalAdapter());
    _transactionBox = await Hive.openBox<Transaction>('transactions');
    _budgetBox = await Hive.openBox<Budget>('budgets');
    _savingsGoalBox = await Hive.openBox<SavingsGoal>('savings_goals');
  }

  // Transactions
  Future<void> addTransaction(Transaction transaction) async {
    await _transactionBox?.put(transaction.id, transaction);
    await _updateBudgetSpending(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionBox?.delete(id);
  }

  List<Transaction> getAllTransactions() {
    return _transactionBox?.values.toList() ?? [];
  }

  Stream<List<Transaction>> watchTransactions() {
    return _transactionBox?.watch().map((_) => getAllTransactions()) ?? Stream.value([]);
  }

  Future<Map<String, double>> getTransactionStats() async {
    final transactions = getAllTransactions();
    double income = 0;
    double expense = 0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) income += t.amount;
      else expense += t.amount;
    }
    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  // Budgets
  Future<void> addBudget(Budget budget) async {
    await _budgetBox?.put(budget.id, budget);
  }

  Future<void> updateBudget(Budget budget) async {
    await _budgetBox?.put(budget.id, budget);
  }

  Future<void> deleteBudget(String id) async {
    await _budgetBox?.delete(id);
  }

  List<Budget> getAllBudgets() {
    return _budgetBox?.values.toList() ?? [];
  }

  Stream<List<Budget>> watchBudgets() {
    return _budgetBox?.watch().map((_) => getAllBudgets()) ?? Stream.value([]);
  }

  Future<void> _updateBudgetSpending(Transaction transaction) async {
    if (transaction.type == TransactionType.expense) {
      final budgets = getAllBudgets();
      for (final budget in budgets) {
        if (budget.category == transaction.category && 
            budget.month.month == transaction.date.month &&
            budget.month.year == transaction.date.year) {
          await updateBudget(budget.copyWith(spent: budget.spent + transaction.amount));
        }
      }
    }
  }

  // Savings Goals
  Future<void> addSavingsGoal(SavingsGoal goal) async {
    await _savingsGoalBox?.put(goal.id, goal);
  }

  Future<void> updateSavingsGoal(SavingsGoal goal) async {
    await _savingsGoalBox?.put(goal.id, goal);
  }

  Future<void> deleteSavingsGoal(String id) async {
    await _savingsGoalBox?.delete(id);
  }

  List<SavingsGoal> getAllSavingsGoals() {
    return _savingsGoalBox?.values.toList() ?? [];
  }

  Stream<List<SavingsGoal>> watchSavingsGoals() {
    return _savingsGoalBox?.watch().map((_) => getAllSavingsGoals()) ?? Stream.value([]);
  }
}
