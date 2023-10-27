//flutter Myapp example

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediaplex/livestream_agora/screens/livestreamPage.dart';

void main() {
  runApp(LiveStream());
}

class LiveStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
        child: MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LivestreamPage(),
    ));
  }
}
