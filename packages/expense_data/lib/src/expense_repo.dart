
import '../expense_data.dart';

abstract class ExpenseData {
  Future<void> createCategory(Category category);
  Future<List<Category>> getCategory();
  Future<void> createExpense(Expense expense);
  Future<List<Expense>> getExpense();
  Future<void> deleteExpense(String expenseId);
}
