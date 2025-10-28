import 'package:event_management/features/auth/presentation/pages/change_password_sceen.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Management',
      theme: ThemeData.light(),
      home: const Scaffold(body: Scaffold(body: ChangePasswordScreen())),
    );
  }
}
