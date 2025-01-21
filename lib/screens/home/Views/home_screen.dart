import 'package:expense_data/expense_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stashapp/screens/home/Views/main_screen.dart';
import 'package:stashapp/screens/home/blocs/get_expense_bloc/get_expense_bloc.dart';
import 'package:stashapp/screens/plus_expense/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:stashapp/screens/plus_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:stashapp/screens/plus_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:stashapp/screens/plus_expense/views/add_expense.dart';
import 'package:stashapp/screens/stats/stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  late Color selectedItem;
  Color unselectedItem = Colors.grey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedItem = Theme.of(context).colorScheme.primary;
  }

  Future<void> _navigateToAddExpense() async {
    var newExpense = await Navigator.push(
      context,
      MaterialPageRoute<Expense>(
        builder: (BuildContext context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => CreateCategoryBloc(FirebaseExpenseRepo()),
            ),
            BlocProvider(
              create: (context) =>
                  GetCategoriesBloc(FirebaseExpenseRepo())..add(GetCategories()),
            ),
            BlocProvider(
              create: (context) => CreateExpenseBloc(FirebaseExpenseRepo()),
            ),
          ],
          child: const AddExpense(),
        ),
      ),
    );

    if (newExpense != null && mounted) {
      context.read<GetExpenseBloc>().add(GetExpense());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetExpenseBloc, GetExpenseState>(
      builder: (context, state) {
        if (state is GetExpenseSuccess) {
          final List<Expense> expenses =
              state.expense.where((e) => !e.isIncome).toList();
          final List<Expense> income =
              state.expense.where((e) => e.isIncome).toList();

          return Scaffold(
            bottomNavigationBar: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              child: BottomNavigationBar(
                currentIndex: index,
                onTap: (value) {
                  setState(() {
                    index = value;
                  });
                },
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: unselectedItem,
                showSelectedLabels: true, 
                showUnselectedLabels: true,
                elevation: 3,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      CupertinoIcons.home,
                      color: index == 0 ? selectedItem : unselectedItem,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      CupertinoIcons.graph_square_fill,
                      color: index == 1 ? selectedItem : unselectedItem,
                    ),
                    label: 'Stats', 
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: _navigateToAddExpense,
              elevation: 5,
              backgroundColor: Colors.transparent,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade500,
                      Colors.blue.shade400,
                      Colors.cyan.shade300,
                      Colors.teal.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.add,
                  color: Colors.white,
                ),
              ),
            ),
            body: index == 0
                ? MainScreen(expenses: expenses, income: income)
                : StatsScreen(expenses: expenses, income: income),
          );
        } else if (state is GetExpenseLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is GetExpenseFailure) {
          return const Scaffold(
            body: Center(
              child: Text('Failed to load expenses'),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
