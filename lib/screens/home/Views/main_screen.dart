import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_data/expense_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stashapp/screens/home/blocs/get_expense_bloc/get_expense_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stashapp/screens/auth/auth_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stashapp/screens/stats/notification_service.dart';

class MainScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Expense> income;

  const MainScreen({
    super.key,
    required this.expenses,
    required this.income,
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late List<Expense> allTransactions;
  int totalIncome = 0;
  int totalExpense = 0;
  int? budgetLimit;
  bool isBudgetNotificationEnabled = true;
  bool hasNotified = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String? username; 

  @override
  void initState() {
    super.initState();
    allTransactions = [...widget.income, ...widget.expenses];
    calculateTotals();
    _loadBudgetLimit();
    _loadNotificationSetting();
    _fetchUsername(); 
    _checkBudgetLimitOnStart();
  }

  Future<void> _fetchUsername() async {
    if (currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();

        if (doc.exists) {
          setState(() {
            username = doc['username']; 
          });
        }
      } catch (e) {
        ("Error fetching username: $e");
      }
    }
  }

  Future<void> _loadBudgetLimit() async {
    final box = await Hive.openBox('app_data');
    setState(() {
      budgetLimit = box.get('budgetLimit', defaultValue: 0) as int;
    });
  }

  Future<void> _loadNotificationSetting() async {
    final box = await Hive.openBox('app_data');
    setState(() {
      isBudgetNotificationEnabled =
          box.get('budgetNotificationEnabled', defaultValue: true) as bool;
    });
  }

  void calculateTotals() {
    setState(() {
      totalIncome = widget.income.fold(0, (total, item) => total + item.amount);
      totalExpense = widget.expenses.fold(0, (total, item) => total + item.amount);
    });
  }

  void _checkBudgetLimitOnStart() {
    if (isBudgetNotificationEnabled &&
        budgetLimit != null &&
        totalExpense > budgetLimit! &&
        !hasNotified) {
      _sendNotification();
    }
  }

  void _sendNotification() {
    NotificationService.showNotification(
      title: 'Budget Exceeded',
      body: 'Your expenses have exceeded the set budget limit!',
    );
    setState(() {
      hasNotified = true;
    });
  }

  void _checkBudgetLimit() {
    if (isBudgetNotificationEnabled &&
        budgetLimit != null &&
        totalExpense > budgetLimit! &&
        !hasNotified) {
      _sendNotification();
    }
  }

  void deleteTransaction(int index) {
    final transaction = allTransactions[index];

    context.read<GetExpenseBloc>().add(DeleteExpense(transaction.expenseId));

    setState(() {
      allTransactions.removeAt(index);

      if (transaction.isIncome) {
        widget.income.remove(transaction);
      } else {
        widget.expenses.remove(transaction);
      }

      calculateTotals();
    });

    _checkBudgetLimit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction deleted')),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = totalIncome - totalExpense;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.indigo.shade500,
                                Colors.blue.shade400,
                                Colors.cyan.shade300,
                                Colors.teal.shade400,
                              ],
                              transform: const GradientRotation(pi / 4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Colors.grey.shade300,
                                offset: const Offset(3, 3),
                              )
                            ],
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome!",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        Text(
                          username ?? currentUser?.email ?? "User",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.logout, size: 28),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _logout();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
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
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Text(
                        'RM ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildIncomeExpenseInfo(
                              label: 'Income',
                              amount: totalIncome,
                              icon: CupertinoIcons.arrow_up,
                              iconColor: const Color.fromARGB(220, 9, 214, 16),
                            ),
                            _buildIncomeExpenseInfo(
                              label: 'Expense',
                              amount: totalExpense,
                              icon: CupertinoIcons.arrow_down,
                              iconColor: const Color.fromARGB(195, 214, 9, 9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.cyan.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        radius: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions History',
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: allTransactions.length,
                itemBuilder: (context, int i) {
                  final transaction = allTransactions[i];
                  return Dismissible(
                    key: Key(transaction.expenseId),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      deleteTransaction(i);
                    },
                    background: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.only(right: 16),
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color(transaction.category.color),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Image.asset(
                                        'assets/${transaction.category.icon}.png',
                                        scale: 1.7,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    transaction.category.name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'RM${transaction.amount}.00',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(transaction.date),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).colorScheme.outline,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseInfo({
    required String label,
    required int amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: const BoxDecoration(
            color: Colors.white30,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, size: 15, color: iconColor),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
            ),
            Text(
              'RM ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
