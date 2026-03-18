import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class ExportService {
  static Future<String> exportTransactionsToCSV(List<Transaction> transactions) async {
    final List<List<dynamic>> rows = [['Date', 'Type', 'Category', 'Title', 'Amount', 'Description']];
    for (final t in transactions) {
      rows.add([DateFormat('yyyy-MM-dd HH:mm').format(t.date), t.type.toString().split('.').last, t.category, t.title, t.amount.toStringAsFixed(2), t.description ?? '']);
    }
    final csv = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/lya_finance_transactions.csv';
    await File(path).writeAsString(csv);
    return path;
  }

  static Future<String> generateTransactionPDF({required List<Transaction> transactions, required double totalIncome, required double totalExpense, required double balance}) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(pageFormat: PdfPageFormat.a4, build: (context) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text('Lya Finance Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      pw.Text('Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
      pw.SizedBox(height: 20),
      pw.Container(padding: const pw.EdgeInsets.all(12), decoration: pw.BoxDecoration(border: pw.Border.all(), borderRadius: pw.BorderRadius.circular(8)), child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Summary', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Total Income: \$${totalIncome.toStringAsFixed(2)}'),
        pw.Text('Total Expense: \$${totalExpense.toStringAsFixed(2)}'),
        pw.Text('Balance: \$${balance.toStringAsFixed(2)}'),
      ])),
      pw.SizedBox(height: 20),
      pw.Text('Transactions', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      pw.Table.fromTextArray(headers: ['Date', 'Type', 'Category', 'Title', 'Amount'], data: transactions.map((t) => [DateFormat('yyyy-MM-dd').format(t.date), t.type.toString().split('.').last, t.category, t.title, '\$${t.amount.toStringAsFixed(2)}']).toList()),
    ])));
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/lya_finance_report.pdf';
    await File(path).writeAsBytes(await pdf.save());
    return path;
  }

  static Future<void> shareFile(String filePath, String subject) async {
    await Share.shareXFiles([XFile(filePath)], subject: subject);
  }
}
