import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
 
  final String channelName;
  final String userName;

   const UserPage({
    Key? key,
    required this.channelName,
    required this.userName,
  }) : super(key: key);
  

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("User Page")
      )
    );
  }
}