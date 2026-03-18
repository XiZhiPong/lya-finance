import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../widgets/crystal_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _db = DatabaseService();
  final List<String> _categories = ['💰 Salary', '🍔 Food', '🚗 Transport', '🛍️ Shopping', '🎬 Entertainment', '💡 Bills', '🏥 Health', '💼 Business', '🎁 Gift', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(),
        backgroundColor: const Color(0xFF6B4EE6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Lya Finance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6B4EE6).withOpacity(0.4),
                      const Color(0xFF00D9FF).withOpacity(0.2),
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  Align(alignment: Alignment.centerLeft, child: Text('Recent Transactions', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 16),
                  _buildTransactionsList(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return StreamBuilder(
      stream: _db.watchTransactions(),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? [];
        double income = 0, expense = 0;
        for (final t in transactions) {
          if (t.type == TransactionType.income) income += t.amount;
          else expense += t.amount;
        }
        final balance = income - expense;

        return CrystalCard(
          child: Column(
            children: [
              Text('Total Balance', style: TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 8),
              Text('\$${balance.toStringAsFixed(2)}', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -1)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.arrow_downward, 'Income', income, Colors.green),
                  Container(width: 1, height: 40, color: Colors.white10),
                  _buildStatItem(Icons.arrow_upward, 'Expense', expense, Colors.red),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().scale();
      },
    );
  }

  Widget _buildStatItem(IconData icon, String label, double amount, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
        Text('\$${amount.toStringAsFixed(0)}', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return StreamBuilder(
      stream: _db.watchTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 60, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text('No transactions yet', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          );
        }
        final transactions = snapshot.data!..sort((a, b) => b.date.compareTo(a.date));
        return Column(children: transactions.take(20).map((t) => _buildTransactionItem(t)).toList());
      },
    );
  }

  Widget _buildTransactionItem(Transaction t) {
    final isIncome = t.type == TransactionType.income;
    return CrystalCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(t.category, style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${isIncome ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}', style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(DateFormat('MMM d').format(t.date), style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  void _showAddTransactionDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    TransactionType type = TransactionType.expense;
    String category = _categories[1];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Add Transaction', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                    ButtonSegment(value: TransactionType.income, label: Text('Income')),
                  ],
                  selected: {type},
                  onSelectionChanged: (s) => setState(() => type = s.first),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? const Color(0xFF6B4EE6) : Colors.transparent),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.white70), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: amountController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Amount', labelStyle: TextStyle(color: Colors.white70), prefixText: '\$', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: const Color(0xFF1A1A2E),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (v) => category = v!,
                  decoration: InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.white70), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  _db.addTransaction(Transaction(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    type: type,
                    category: category,
                    date: DateTime.now(),
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Color(0xFF6B4EE6), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
