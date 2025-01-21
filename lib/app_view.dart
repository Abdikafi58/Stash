import 'package:expense_data/expense_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stashapp/screens/home/blocs/get_expense_bloc/get_expense_bloc.dart';
import 'package:stashapp/screens/auth/auth_screen.dart';

class MyAppView extends StatelessWidget {
  const MyAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Stashapp",
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade100,
          onSurface: Colors.black,
          primary: const Color(0xFF00B2E7),
          secondary: const Color(0xFFE064F7),
          tertiary: const Color(0xFFFF8D6C),
          outline: Colors.grey,
        ),
      ),
      home: BlocProvider(
        create: (context) => GetExpenseBloc(FirebaseExpenseRepo())..add(GetExpense()),
        child: const AuthScreen(),
      ),
    );
  }
}

