import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../services/database_service.dart';
import '../widgets/crystal_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _db = DatabaseService();
  bool _biometricEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    final canCheck = await AuthService.canCheckBiometrics();
    setState(() => _biometricEnabled = canCheck);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              background: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF6B4EE6).withOpacity(0.3), const Color(0xFF0A0A0F)]))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSectionTitle('Data & Export'),
                  _buildExportTile(Icons.file_download, 'Export CSV', 'Export transactions to CSV', () => _exportCSV()),
                  _buildExportTile(Icons.picture_as_pdf, 'Export PDF', 'Generate PDF report', () => _exportPDF()),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Security'),
                  _buildBiometricTile(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('About'),
                  _buildInfoTile(Icons.info, 'Version', '1.0.0'),
                  _buildInfoTile(Icons.code, 'Package', 'com.lya.finance'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(title, style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600)),
    ).animate().fadeIn();
  }

  Widget _buildExportTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return CrystalCard(
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF6B4EE6).withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF6B4EE6))),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B4EE6))) : const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: _isLoading ? null : onTap,
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildBiometricTile() {
    return CrystalCard(
      child: SwitchListTile(
        secondary: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF00D9FF).withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.fingerprint, color: Color(0xFF00D9FF))),
        title: const Text('Biometric Lock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(_biometricEnabled ? 'Enabled' : 'Not available', style: TextStyle(color: Colors.white54, fontSize: 12)),
        value: _biometricEnabled,
        onChanged: _biometricEnabled ? (v) => _toggleBiometric(v) : null,
        activeColor: const Color(0xFF00D9FF),
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return CrystalCard(
      child: ListTile(
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: Colors.white70)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Text(value, style: TextStyle(color: Colors.white54)),
      ),
    ).animate().fadeIn().slideX(begin: -0.1);
  }

  Future<void> _exportCSV() async {
    setState(() => _isLoading = true);
    final transactions = await _db.getAllTransactions();
    final path = await ExportService.exportTransactionsToCSV(transactions);
    await ExportService.shareFile(path, 'Lya Finance Transactions');
    setState(() => _isLoading = false);
  }

  Future<void> _exportPDF() async {
    setState(() => _isLoading = true);
    final transactions = await _db.getAllTransactions();
    final stats = await _db.getTransactionStats();
    final path = await ExportService.generateTransactionPDF(
      transactions: transactions,
      totalIncome: stats['income'] ?? 0,
      totalExpense: stats['expense'] ?? 0,
      balance: stats['balance'] ?? 0,
    );
    await ExportService.shareFile(path, 'Lya Finance Report');
    setState(() => _isLoading = false);
  }

  void _toggleBiometric(bool value) {
    if (value) {
      AuthService.authenticateWithBiometrics(localizedReason: 'Enable biometric lock for Lya Finance');
    }
  }
}
