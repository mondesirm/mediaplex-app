import 'package:flutter/material.dart';

class ManagerPage extends StatefulWidget {
  final String channelName;

  const ManagerPage({
    Key? key,
    required this.channelName,
  }) : super(key: key);

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Manager Page")
      )
    );
  }
}