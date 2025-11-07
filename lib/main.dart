import 'package:flutter/material.dart';
import '/route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome/welcome_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final completed = prefs.getBool('welcomeCompleted') ?? false;
  await dotenv.load(fileName: "assets/.env.example");
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
      home: welcomeCompleted ? const WelcomePage() : const RoutePage(),
    );
  }
}
