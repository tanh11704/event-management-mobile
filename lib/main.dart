import 'package:event_management/app/core/theme/app_colors.dart';
import 'package:event_management/app/core/theme/app_text_styles.dart';
import 'package:event_management/app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Event Management', theme: AppTheme.light, home: const HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.COOL_GRAY_50,
      appBar: AppBar(
        title: const Text('Demo', style: AppTextStyles.HEADING_2),
        backgroundColor: AppColors.VKU_BLUE,
      ),
      body: Center(child: Text('Xin chào VKU', style: Theme.of(context).textTheme.headlineLarge)),
    );
  }
}
