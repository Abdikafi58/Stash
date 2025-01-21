import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_data/expense_data.dart';

class ExpenseEntity {
  final String expenseId;
  final Category category;
  final DateTime date;
  final int amount;
  final bool isIncome; 

  ExpenseEntity({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
    required this.isIncome,
  });

  Map<String, Object?> toDocument() {
    return {
      'expenseId': expenseId,
      'category': category.toEntity().toDocument(),
      'date': date,
      'amount': amount,
      'isIncome': isIncome,
    };
  }

  static ExpenseEntity fromDocument(Map<String, dynamic> doc) {
    return ExpenseEntity(
      expenseId: doc['expenseId'] ?? '',
      category: Category.fromEntity(
        CategoryEntity.fromDocument(doc['category'] ?? {}),
      ),
      date: (doc['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      amount: doc['amount'] ?? 0,
      isIncome: doc['isIncome'] ?? false,
    );
  }
}
