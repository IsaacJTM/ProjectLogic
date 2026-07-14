import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() => runApp(const LogisticsProApp());

class LogisticsProApp extends StatelessWidget {
  const LogisticsProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logistics Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginPage(),
    );
  }
}
