import 'package:flutter/material.dart';
import 'package:mediaplex/livestream_agora/screens/managerPage.dart';
import 'package:mediaplex/livestream_agora/screens/userPage.dart';

class LivestreamPage extends StatefulWidget {
  const LivestreamPage({super.key});

  @override
  State<LivestreamPage> createState() => _LivestreamPageState();
}

class _LivestreamPageState extends State<LivestreamPage> {
  final _channelName = TextEditingController();
  final _userName = TextEditingController();

  goToManagerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManagerPage(
        channelName: _channelName.text,
      )),
    );
  }

  goToUserPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserPage(
        channelName: _channelName.text,
        userName: _userName.text,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width *0.2,
              child: TextField(
                controller: _userName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  
                  ),
                  labelText: 'User Name',
                ),
              ),
              ),
              SizedBox(
              width: MediaQuery.of(context).size.width *0.2,
              child: TextField(
                controller: _channelName,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  
                  ),
                  labelText: 'Channel Name',
                ),
              ),
              )
            TextButton(
              onPressed: goToUserPage(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Participant',
                  ),
                  Icon(
                    Icons.live_tv,
                  )
                ],
              ),
            ),
            TextButton(
              
              onPressed: goToManagerPage(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Manager',
                  ),
                  Icon(Icons.cut)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
