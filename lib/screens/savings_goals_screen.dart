import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/savings_goal.dart';
import '../services/database_service.dart';
import '../widgets/crystal_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final DatabaseService _db = DatabaseService();
  final List<String> emojis = ['🎯', '✈️', '🚗', '🏠', '💍', '🎓', '📱', '💻', '🎮', '👗'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(),
        backgroundColor: const Color(0xFF00D9FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Savings Goals', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFFFF6B9D).withOpacity(0.3), const Color(0xFF0A0A0F)]))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder(
                stream: _db.watchSavingsGoals(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState();
                  final goals = snapshot.data!;
                  return Column(children: goals.map((g) => _buildGoalCard(g)).toList());
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
          Icon(Icons.savings, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text('No savings goals yet', style: TextStyle(color: Colors.white54, fontSize: 18)),
          const SizedBox(height: 8),
          Text('Create a goal to start saving!', style: TextStyle(color: Colors.white38, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    final isCompleted = goal.percentage >= 1.0;
    return CrystalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(goal.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(goal.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              if (goal.description.isNotEmpty) Text(goal.description, style: TextStyle(color: Colors.white54, fontSize: 12)),
            ])),
            if (isCompleted) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.3), borderRadius: BorderRadius.circular(8)), child: const Text('DONE', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 14,
            percent: goal.percentage.clamp(0.0, 1.0),
            backgroundColor: Colors.white10,
            progressColor: isCompleted ? Colors.green : const Color(0xFF00D9FF),
            barRadius: const Radius.circular(7),
            center: Text('${(goal.percentage * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('\$${goal.currentAmount.toStringAsFixed(0)} saved', style: TextStyle(color: Colors.white70, fontSize: 14)),
            Text('\$${goal.targetAmount.toStringAsFixed(0)} goal', style: TextStyle(color: Colors.white54, fontSize: 14)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${goal.daysLeft} days left', style: TextStyle(color: goal.isNearDeadline && !isCompleted ? Colors.orange : Colors.white38, fontSize: 12)),
            if (!isCompleted) TextButton(onPressed: () => _showAddAmountDialog(goal), child: const Text('+ Add', style: TextStyle(color: Color(0xFF00D9FF)))),
          ]),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String emoji = '🎯';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Create Savings Goal', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(spacing: 8, children: emojis.map((e) => GestureDetector(
                  onTap: () => setState(() => emoji = e),
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: emoji == e ? const Color(0xFF6B4EE6) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Text(e, style: const TextStyle(fontSize: 24))),
                )).toList()),
                const SizedBox(height: 16),
                TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Goal Title', labelStyle: TextStyle(color: Colors.white70), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: amountController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: 'Target Amount', labelStyle: TextStyle(color: Colors.white70), prefixText: '\$', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
            TextButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && amountController.text.isNotEmpty) {
                  _db.addSavingsGoal(SavingsGoal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    targetAmount: double.parse(amountController.text),
                    deadline: DateTime.now().add(const Duration(days: 365)),
                    createdAt: DateTime.now(),
                    emoji: emoji,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Create', style: TextStyle(color: Color(0xFF00D9FF), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAmountDialog(SavingsGoal goal) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('Add to ${goal.title}', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(labelText: 'Amount', labelStyle: TextStyle(color: Colors.white70), prefixText: '\$', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                _db.updateSavingsGoal(goal.copyWith(currentAmount: goal.currentAmount + double.parse(amountController.text)));
                Navigator.pop(context);
              }
            },
            child: const Text('Add', style: TextStyle(color: Color(0xFF00D9FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
