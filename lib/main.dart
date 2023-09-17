// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home/home_screen.dart';
import 'auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Paint.enableDithering = true;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget home = Scaffold();

  void switchHome() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? session = sharedPreferences.getString('session');
    setState(() => home = session == null ? LoginScreen() : HomeScreen());
  }

  @override
  void initState() { switchHome(); super.initState(); }

  @override
  Widget build(BuildContext context) => MaterialApp(home: home, title: 'mediaplex', debugShowCheckedModeBanner: false);
}