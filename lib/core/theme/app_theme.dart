import 'package:flutter/material.dart';
import 'package:logistics_pro/core/theme/app_colors.dart';

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
    textTheme: TextTheme(
      titleMedium: TextStyle(
        fontFamily: 'Hanken Grotesk',
        fontSize: 20,
        color: AppColors.primary,
        fontWeight: FontWeight.w500
      ),
      titleSmall: TextStyle(
        fontFamily: 'Hanken Grotesk',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryDark
      ),
      labelMedium: TextStyle(
        fontSize: 13, 
        color: Colors.black54
      )
    )
  );
}
