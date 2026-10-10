import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';

/// লেজারের লেনদেনগুলোর স্টেট পরিচালনা করার জন্য প্রোভাইডার
final transactionListProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier() : super([]);

  // নতুন লেনদেন যোগ করার মেথড
  void addTransaction(TransactionModel transaction) {
    state = [...state, transaction];
  }

  // লেনদেন ডিলিট করার মেথড
  void removeTransaction(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}
