import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediaplex/utils/theme.dart';

class Player extends StatefulWidget {
  const Player({super.key, required this.model});

  final dynamic model;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late String _fileName;
  late Future<void> _initialize;
  late VideoPlayerController _controller;
  // String test = 'https://cdn.002radio.com:3909/live/radio002live.m3u8';
  // String test = 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  void init() async {
    _fileName = widget.model.name ?? widget.model.url.split('/').last;
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.model.url));
    _initialize = _controller.initialize();
    _controller.setLooping(true);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('lastPlayed', jsonEncode(widget.model));
  }

  @override
  void initState() { super.initState(); init(); }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(context, screen: 'Player', child: Text('Playing $_fileName', style: MyTheme.appText())),
    body: Container(
      decoration: MyTheme.boxDecoration(),
      child: Center(child: FutureBuilder(
        future: _initialize,
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
        ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
        : MyTheme.loadingAnimation()
      ))
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => setState(() { _controller.value.isPlaying ? _controller.pause() : _controller.play(); }),
      child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow)
    )
  );
}