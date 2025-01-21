import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../expense_data.dart';

class FirebaseExpenseRepo implements ExpenseData {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get categoryCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not logged in");
    }
    return _firestore.collection('users').doc(user.uid).collection('categories');
  }

  CollectionReference<Map<String, dynamic>> get expenseCollection {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User is not logged in");
    }
    return _firestore.collection('users').doc(user.uid).collection('expenses');
  }

  @override
  Future<void> createCategory(Category category) async {
    try {
      await categoryCollection
          .doc(category.categoryId)
          .set(category.toEntity().toDocument());
    } catch (e) {
      log("Error creating category: $e");
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategory() async {
    try {
      return await categoryCollection.get().then((value) => value.docs.map(
            (e) => Category.fromEntity(CategoryEntity.fromDocument(e.data())),
          ).toList());
    } catch (e) {
      log("Error fetching categories: $e");
      rethrow;
    }
  }

  @override
  Future<void> createExpense(Expense expense) async {
    try {
      await expenseCollection
          .doc(expense.expenseId)
          .set(expense.toEntity().toDocument());
    } catch (e) {
      log("Error creating expense: $e");
      rethrow;
    }
  }

  @override
  Future<List<Expense>> getExpense() async {
    try {
      return await expenseCollection.get().then((snapshot) => snapshot.docs
          .map((doc) => Expense.fromEntity(ExpenseEntity.fromDocument(doc.data())))
          .toList());
    } catch (e) {
      log("Error fetching expenses: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await expenseCollection.doc(expenseId).delete();
      log("Expense with ID $expenseId deleted successfully.");
    } catch (e) {
      log("Error deleting expense with ID $expenseId: $e");
      rethrow;
    }
  }
}
