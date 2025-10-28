import 'package:event_management/app.dart';
import 'package:event_management/core/di/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await dotenv.load();

  runApp(const MyApp());
}
