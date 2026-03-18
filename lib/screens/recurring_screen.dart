import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recurring_transaction.dart';
import '../providers/app_provider.dart';
import '../widgets/liquid_card.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0AF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Recurring Transactions'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final recurring = provider.recurringService.getAll();
          
          if (recurring.isEmpty) {
            return center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 64,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recurring transactions',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: recurring.length,
            itemBuilder: (context, index) {
              final item = recurring[index];
              final isIncome = item.isIncome;
              final color = isIncome ? const Color(0xFF00D4AA) : const Color(0xFFF6B6B);
              
              return LiquidCard(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.frequencyLabel),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}\${item.amount.toStringAsFixed(2)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        backgroundColor: const Color(0xFF7B61FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
