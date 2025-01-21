import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_data/expense_data.dart';

part 'create_expense_event.dart';
part 'create_expense_state.dart';

class CreateExpenseBloc extends Bloc<CreateExpenseEvent, CreateExpenseState> {
  ExpenseData expenseData;
  CreateExpenseBloc(this.expenseData) : super(CreateExpenseInitial()) {
    on<CreateExpense>((event, emit) async {
      emit(CreateExpenseLoading());
      try {
        await expenseData.createExpense(event.expense);
        emit(CreateExpenseSuccess());
      } catch (e) {
        emit(CreateExpenseFailure());

      }
    });
  }
}
