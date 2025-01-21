import 'package:flutter/material.dart';
import 'package:stashapp/screens/stats/chart.dart';
import 'package:expense_data/expense_data.dart';
import 'package:stashapp/screens/stats/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StatsScreen extends StatefulWidget {
  final List<Expense> expenses;
  final List<Expense> income;

  const StatsScreen({
    super.key,
    required this.expenses,
    required this.income,
  });

  @override
  StatsScreenState createState() => StatsScreenState();
}

class StatsScreenState extends State<StatsScreen> {
  String selectedView = 'Daily';
  int? budgetLimit;
  bool isBudgetNotificationEnabled = true;
  bool hasNotified = false;
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBudgetLimit();
    _loadNotificationSetting();
    _checkBudgetOnStart();
  }

  Future<void> _loadBudgetLimit() async {
    final box = await Hive.openBox('app_data');
    setState(() {
      budgetLimit = box.get('budgetLimit', defaultValue: 0) as int;
      _budgetController.text = budgetLimit.toString();
    });
  }

  Future<void> _loadNotificationSetting() async {
    final box = await Hive.openBox('app_data');
    setState(() {
      isBudgetNotificationEnabled =
          box.get('budgetNotificationEnabled', defaultValue: true) as bool;
    });
  }

  Future<void> _saveBudgetLimit() async {
    final box = await Hive.openBox('app_data');
    await box.put('budgetLimit', budgetLimit);
  }

  Future<void> _saveNotificationSetting() async {
    final box = await Hive.openBox('app_data');
    await box.put('budgetNotificationEnabled', isBudgetNotificationEnabled);
  }

  void _checkBudgetOnStart() {
    final int totalExpenses =
        widget.expenses.fold(0, (sum, item) => sum + item.amount);
    if (isBudgetNotificationEnabled &&
        budgetLimit != null &&
        totalExpenses > budgetLimit! &&
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

  void _checkBudgetLimit(int totalExpenses) {
    if (isBudgetNotificationEnabled &&
        budgetLimit != null &&
        totalExpenses > budgetLimit! &&
        !hasNotified) {
      _sendNotification();
    }
  }

  void _onViewChanged(String view) {
    setState(() {
      selectedView = view;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalIncome =
        widget.income.fold(0, (sum, item) => sum + item.amount);
    final int totalExpenses =
        widget.expenses.fold(0, (sum, item) => sum + item.amount);
    final int balance = totalIncome - totalExpenses;

    _checkBudgetLimit(totalExpenses);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Financial Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGradientCard('Total Income', totalIncome,
                      Colors.green.shade300, Colors.green.shade700),
                  _buildGradientCard('Total Expenses', totalExpenses,
                      Colors.red.shade300, Colors.red.shade700),
                  _buildGradientCard('Balance', balance,
                      Colors.blue.shade300, Colors.blue.shade700),
                ],
              ),
              const SizedBox(height: 25),
              Center(
                child: ToggleButtons(
                  borderRadius: BorderRadius.circular(15),
                  isSelected: [
                    selectedView == 'Daily',
                    selectedView == 'Weekly',
                    selectedView == 'Monthly',
                    selectedView == 'Yearly',
                  ],
                  onPressed: (index) {
                    switch (index) {
                      case 0:
                        _onViewChanged('Daily');
                        break;
                      case 1:
                        _onViewChanged('Weekly');
                        break;
                      case 2:
                        _onViewChanged('Monthly');
                        break;
                      case 3:
                        _onViewChanged('Yearly');
                        break;
                    }
                  },
                  selectedColor: Colors.white,
                  fillColor: Theme.of(context).colorScheme.primary,
                  color: Colors.teal,
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('Daily'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('Weekly'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('Monthly'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('Yearly'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(4, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MyChart(
                    expenses: widget.expenses,
                    income: widget.income,
                    view: selectedView,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enable Budget Notification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                  Switch(
                    value: isBudgetNotificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        isBudgetNotificationEnabled = value;
                        if (!value) {
                          hasNotified = false;
                        }
                        _saveNotificationSetting();
                      });
                    },
                  ),
                ],
              ),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Set Budget Limit (RM)',
                  labelStyle: const TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check, color: Colors.teal),
                    onPressed: () {
                      setState(() {
                        budgetLimit = int.tryParse(_budgetController.text);
                      });
                      if (budgetLimit != null) {
                        _saveBudgetLimit();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Budget limit set to RM $budgetLimit'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a valid amount')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientCard(String title, int amount, Color color1, Color color2) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color2.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'RM $amount',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
