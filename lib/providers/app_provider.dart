import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/recurring_transaction.dart';
import '../services/database_service.dart';
import '../services/recurring_service.dart';

class AppProvider extends ChangeNotifier {
  late DatabaseService _databaseService;
  late RecurringService _recurringService;
  bool _isLoading = true;
  bool _isBiometricEnabled = false;

  DatabaseService get databaseService => _databaseService;
  RecurringService get recurringService => _recurringService;
  bool get isLoading => _isLoading;
  bool get isBiometricEnabled => _isBiometricEnabled;

  Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(RecurringTransactionAdapter());
    
    _databaseService = DatabaseService();
    await _databaseService.init();
    
    _recurringService = RecurringService();
    await _recurringService.init();
    
    // Process due recurring transactions
    await _recurringService.processDueTransactions(_databaseService);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    notifyListeners();
  }

  void toggleBiometric(bool value) {
    _isBiometricEnabled = value;
    notifyListeners();
  }
}
