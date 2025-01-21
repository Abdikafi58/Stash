import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stashapp/screens/auth/auth_screen.dart';
import 'package:stashapp/screens/stats/notification_service.dart';
import 'simple_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('app_data'); 
  NotificationService.initialize();
  NotificationService.requestNotificationPermissions();

  _startGlobalBudgetMonitoring();

  Bloc.observer = SimpleBlocObserver();

  runApp(const MyApp());
}

void _startGlobalBudgetMonitoring() async {
  final box = Hive.box('app_data');
  final int budgetLimit = box.get('budgetLimit', defaultValue: 0) as int;

  
  final expenses = box.get('expenses', defaultValue: 0) as int;

  if (expenses > budgetLimit) {
    NotificationService.showNotification(
      title: 'Budget Exceeded',
      body: 'Your expenses have exceeded the set budget limit!',
    );
  }


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StashApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthScreen(),
    );
  }
}
