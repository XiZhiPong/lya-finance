import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/budget.dart';
import '../services/database_service.dart';
import '../widgets/crystal_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final DatabaseService _db = DatabaseService();
  final List<String> categories = ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(),
        backgroundColor: const Color(0xFF6B4EE6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Budget', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF00D9FF).withOpacity(0.3), const Color(0xFF0A0A0F)]))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder(
                stream: _db.watchBudgets(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }
                  final budgets = snapshot.data!;
                  return Column(children: budgets.map((b) => _buildBudgetCard(b)).toList());
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text('No budgets yet', style: TextStyle(color: Colors.white54, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Tap + to create your first budget', style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final isOver = budget.isOverBudget;
    final color = isOver ? Colors.red : (budget.percentage > 0.8 ? Colors.orange : const Color(0xFF6B4EE6));
    
    return CrystalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(budget.category, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            if (isOver) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.red.withOpacity(0.3), borderRadius: BorderRadius.circular(8)), child: const Text('OVER', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 12,
            percent: budget.percentage.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            progressColor: color,
            barRadius: const Radius.circular(6),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${budget.spent.toStringAsFixed(0)} spent', style: TextStyle(color: Colors.white70, fontSize: 14)),
            Text('\$${budget.amount.toStringAsFixed(0)} budget', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ]),
          const SizedBox(height: 8),
          Text('\$${budget.remaining.abs().toStringAsFixed(2)} ${isOver ? 'over' : 'remaining'}', style: TextStyle(color: isOver ? Colors.red : Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  void _showAddBudgetDialog() {
    String selectedCategory = categories.first;
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Create Budget', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              dropdownColor: const Color(0xFF1A1A2E),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => selectedCategory = v!,
              decoration: InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.white70), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Budget Amount', labelStyle: TextStyle(color: Colors.white70), prefixText: '\$', prefixStyle: const TextStyle(color: Colors.white), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                _db.addBudget(Budget(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  category: selectedCategory,
                  amount: double.parse(amountController.text),
                  month: DateTime.now(),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Create', style: TextStyle(color: Color(0xFF6B4EE6), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
