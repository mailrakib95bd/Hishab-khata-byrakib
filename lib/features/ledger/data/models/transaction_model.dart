import 'cloud_firestore/cloud_firestore.dart'; // যদি ক্লাউড ফায়ারস্টোর ব্যবহার হয়

/// হিসাব খাতা লেনদেন ডেটা মডেল (PRD অনুযায়ী)
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' (আয়) অথবা 'expense' (ব্যয়)
  final DateTime date;
  final String? category;
  final String? note;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
    this.note,
  });

  // Firestore থেকে ডেটা রিড করার জন্য
  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'expense',
      date: (map['date'] != null) 
          ? (map['date'] as Timestamp).toDate() 
          : DateTime.now(),
      category: map['category'],
      note: map['note'],
    );
  }

  // Firestore-এ ডেটা সেভ বা রাইট করার জন্য
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'date': Timestamp.fromDate(date),
      'category': category,
      'note': note,
    };
  }
}
