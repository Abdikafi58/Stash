import 'package:expense_data/expense_data.dart';

class Expense {
  String expenseId;
  Category category;
  DateTime date;
  int amount;
  bool isIncome; 

  Expense({
    required this.expenseId,
    required this.category,
    required this.date,
    required this.amount,
    this.isIncome = false, 
  });

  static final empty = Expense(
    expenseId: '',
    category: Category.empty,
    date: DateTime.now(),
    amount: 0,
    isIncome: false, 
  );

  ExpenseEntity toEntity() {
    return ExpenseEntity(
      expenseId: expenseId,
      category: category,
      date: date,
      amount: amount,
      isIncome: isIncome, 
    );
  }

  static Expense fromEntity(ExpenseEntity entity) {
    return Expense(
      expenseId: entity.expenseId,
      category: entity.category,
      date: entity.date,
      amount: entity.amount,
      isIncome: entity.isIncome,
    );
  }
}
