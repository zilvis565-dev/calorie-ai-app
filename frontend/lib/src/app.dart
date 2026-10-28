import 'package:flutter/material.dart';

import 'pages/dashboard_page.dart';
import 'pages/foods_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'pages/register_page.dart';

class CalorieAiApp extends StatelessWidget {
  const CalorieAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie AI App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/dashboard': (_) => const DashboardPage(),
        '/foods': (_) => const FoodsPage(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
