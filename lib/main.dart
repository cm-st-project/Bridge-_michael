import 'package:flutter/foundation.dart'; // for kDebugMode
import 'package:flutter/material.dart';
import '/route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // DEBUG-ONLY reset (runs only when using flutter run, not App Store builds)
  if (kDebugMode) {
    await prefs.remove('welcomeCompleted');
  }

  final completed = prefs.getBool('welcomeCompleted') ?? false;
  print('WELCOME COMPLETED STATUS: $completed');

  runApp(MyApp(welcomeCompleted: completed));
}

class MyApp extends StatelessWidget {
  final bool welcomeCompleted;
  const MyApp({super.key, required this.welcomeCompleted});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: welcomeCompleted ? const RoutePage() : const WelcomePage(),
    );
  }
}
