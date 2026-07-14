import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF4F7FC),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F172A),
      primary: const Color(0xFF2563EB),
      secondary: const Color(0xFF10B981),
    ),
    fontFamily: 'Roboto',
  );
}
