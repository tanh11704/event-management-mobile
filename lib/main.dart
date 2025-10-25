import 'package:event_management/app.dart';
import 'package:event_management/core/config/app_colors.dart';
import 'package:event_management/core/config/app_text_styles.dart';
import 'package:event_management/core/config/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      theme: AppTheme.light,
      home: const App(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coolGray50,
      appBar: AppBar(
        title: Text('Demo', style: AppTextStyles.heading2),
        backgroundColor: AppColors.vkuBlue,
      ),
      body: Center(
        child: Text(
          'Xin chào VKU',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
