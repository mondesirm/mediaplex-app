import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'home/home_screen.dart';
import 'auth/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _home = const Scaffold();

  void switchHome() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? session = preferences.getString('token');
    setState(() => _home = session == null ? const LoginScreen() : const HomeScreen());
  }

  @override
  void initState() { switchHome(); super.initState(); }

  @override
  Widget build(BuildContext context) => MaterialApp(home: _home, title: dotenv.env['APP_NAME']!, debugShowCheckedModeBanner: false);
}