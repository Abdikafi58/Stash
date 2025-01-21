import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_data/expense_data.dart';

part 'get_expense_event.dart';
part 'get_expense_state.dart';

class GetExpenseBloc extends Bloc<GetExpenseEvent, GetExpenseState> {
  final ExpenseData expenseData;

  GetExpenseBloc(this.expenseData) : super(GetExpenseInitial()) {
    on<GetExpense>((event, emit) async {
      emit(GetExpenseLoading());
      try {
        List<Expense> expense = await expenseData.getExpense();
        emit(GetExpenseSuccess(expense));
      } catch (e) {
        emit(GetExpenseFailure());
      }
    });

    on<DeleteExpense>((event, emit) async {
      if (state is GetExpenseSuccess) {
        final currentState = state as GetExpenseSuccess;
        final updatedExpenses = List<Expense>.from(currentState.expense)
          ..removeWhere((expense) => expense.expenseId == event.expenseId);

        try {
          await expenseData.deleteExpense(event.expenseId); // This will delete from backend
          emit(GetExpenseSuccess(updatedExpenses)); // Update the state with the new list
        } catch (e) {
          emit(GetExpenseFailure());
        }
      }
    });
  }
}
