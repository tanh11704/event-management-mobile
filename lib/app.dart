import 'package:event_management/core/router/app_router.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Event Management',

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto', // (Giả sử bạn dùng font này)
      ),

      routerConfig: appRouter,
    );
  }
}
