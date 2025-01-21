import 'package:expense_data/expense_data.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:stashapp/screens/plus_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:stashapp/screens/plus_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:stashapp/screens/plus_expense/views/category_creation.dart';
import 'package:uuid/uuid.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController expenseController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  late Expense expense;
  bool isLoading = false;
  bool isIncome = false;

  List<Category> customCategories = [];

  @override
  void initState() {
    super.initState();
    resetExpense();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resetExpense();
  }

  void resetExpense() {
    expense = Expense.empty;
    expense.expenseId = const Uuid().v1();
    expense.category = Category.empty;
    categoryController.clear();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  Future<void> _refreshCategories() async {
    context.read<GetCategoriesBloc>().add(GetCategories());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          Navigator.pop(context, expense);
        } else if (state is CreateExpenseLoading) {
          setState(() {
            isLoading = true;
          });
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                final categories = [...state.categories, ...customCategories];
                
                return RefreshIndicator(
                  onRefresh: _refreshCategories,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ChoiceChip(
                                label: const Text(
                                  "Expense",
                                  style: TextStyle(color: Colors.black),
                                ),
                                selected: !isIncome,
                                selectedColor: Colors.teal,
                                onSelected: (selected) {
                                  setState(() {
                                    isIncome = false;
                                  });
                                },
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text(
                                  "Income",
                                  style: TextStyle(color: Colors.black),
                                ),
                                selected: isIncome,
                                selectedColor: Colors.teal,
                                onSelected: (selected) {
                                  setState(() {
                                    isIncome = true;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isIncome ? "Add Income" : "Add Expense",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextFormField(
                              controller: expenseController,
                              keyboardType: TextInputType.number,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                prefixIcon: const Icon(
                                  FontAwesomeIcons.dollarSign,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: categoryController,
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: expense.category == Category.empty
                                  ? Colors.grey.shade100
                                  : Color(expense.category.color),
                              prefixIcon: expense.category == Category.empty
                                  ? const Icon(
                                      FontAwesomeIcons.list,
                                      size: 16,
                                      color: Colors.grey,
                                    )
                                  : Image.asset(
                                      'assets/${expense.category.icon}.png',
                                      scale: 2,
                                    ),
                              suffixIcon: IconButton(
                                  onPressed: () async {
                                    var newCategory = await getCategoryCreation(context);
                                    if (newCategory != null) {
                                      setState(() {
                                        customCategories.add(newCategory);
                                      });
                                    }
                                  },
                                  icon: const Icon(
                                    FontAwesomeIcons.circlePlus,
                                    size: 16,
                                    color: Colors.grey,
                                  )),
                              hintText: 'Category',
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.vertical(top: Radius.circular(12)),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                          Container(
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.vertical(bottom: Radius.circular(12)),
                            ),
                            child: ListView.builder(
                                itemCount: categories.length,
                                itemBuilder: (context, int i) {
                                  return Card(
                                    color: Color(categories[i].color),
                                    child: ListTile(
                                      onTap: () {
                                        setState(() {
                                          expense.category = Category(
                                            categoryId: categories[i].categoryId,
                                            name: categories[i].name,
                                            color: categories[i].color,
                                            icon: categories[i].icon,
                                            totalExpenses: 0,
                                          );
                                          categoryController.text = expense.category.name;
                                        });
                                      },
                                      leading: Image.asset(
                                        'assets/${categories[i].icon}.png',
                                        scale: 2,
                                      ),
                                      title: Text(
                                        categories[i].name,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                  );
                                }),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: dateController,
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            onTap: () async {
                              DateTime? newDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors.teal, 
                                        onPrimary: Colors.white, 
                                        onSurface: Colors.teal, 
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.teal, 
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (newDate != null) {
                                setState(() {
                                  dateController.text = DateFormat('dd/MM/yyyy').format(newDate);
                                  expense.date = newDate;
                                });
                              }
                              },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              prefixIcon: const Icon(
                                FontAwesomeIcons.calendar,
                                size: 16,
                                color: Colors.teal,
                              ),
                              hintText: 'Date',
                              hintStyle: const TextStyle(color: Colors.teal),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: kToolbarHeight,
                            child: isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : TextButton(
                                    onPressed: () {
                                      if (expenseController.text.isNotEmpty) {
                                        setState(() {
                                          expense.amount = int.parse(expenseController.text);
                                          expense.isIncome = isIncome;
                                        });
                                        context.read<CreateExpenseBloc>().add(CreateExpense(expense));
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12))),
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(fontSize: 22, color: Colors.white),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
