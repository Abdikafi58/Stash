import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_data/expense_data.dart';



part 'create_category_event.dart';
part 'create_category_state.dart';

class CreateCategoryBloc extends Bloc<CreateCategoryEvent, CreateCategoryState> {
  final ExpenseData expenseData;

  CreateCategoryBloc(this.expenseData) : super(CreateCategoryInitial()) {
    on<CreateCategory>((event, emit) async {
      emit(CreateCategoryLoading());
      try {
        await expenseData.createCategory(event.category);
        emit(CreateCategorySuccess());
        
      } catch (e) {
        emit(CreateCategoryFailure());

      }
    });
  }
}
