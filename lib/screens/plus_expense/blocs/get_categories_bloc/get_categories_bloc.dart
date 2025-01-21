import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_data/expense_data.dart';

part 'get_categories_event.dart';
part 'get_categories_state.dart';

class GetCategoriesBloc extends Bloc<GetCategoriesEvent, GetCategoriesState> {
  ExpenseData expenseData;

  GetCategoriesBloc(this.expenseData) : super(GetCategoriesInitial()) {
    on<GetCategories>((event, emit) async {
      emit(GetCategoriesLoading());
      try {
        List<Category> categories = await expenseData.getCategory();
        emit(GetCategoriesSuccess(categories));
        
      } catch (e) {
        emit(GetCategoriesFailure());
      }
    });
  }
}
