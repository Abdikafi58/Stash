import 'package:flutter/material.dart';
import 'screens/auth/auth_screen.dart'; 
import 'app_view.dart'; 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stash App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (ctx) => const AuthScreen(),
        '/home': (ctx) => const MyAppView(), 
      },
    );
  }
}

void main() {
  runApp(const MyApp());
}
