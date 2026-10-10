import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import '../providers/ledger_provider.dart';

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('হিসাব খাতা - লেনদেন'),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          const Center(
              child: Text(
                'কোনো লেনদেন পাওয়া যায়নি!\nনতুন লেনদেন যোগ করুন।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx.type == 'income';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${tx.category ?? "সাধারণ"} • ${tx.date.toLocal().toString().split(' ')[0]}'),
                    trailing: Text(
                      '${isIncome ? "+" : "-"} ৳${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // টেস্টের জন্য একটি ডামি ট্রানজাকশন যোগ করা হচ্ছে
          final newTx = TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'নমুনা হিসাব',
            amount: 500.0,
            type: 'income',
            date: DateTime.now(),
            category: 'বেতন/ আয়',
          );
          ref.read(transactionListProvider.notifier).addTransaction(newTx);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
