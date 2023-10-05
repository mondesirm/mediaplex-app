import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
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
  bool _looping = true;
  late String _fileName;
  late List<dynamic> _history;
  late Future<void> _initialize;
  late VideoPlayerController _videoPlayer;
  String test = 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  void init() async {
    _fileName = widget.model.name ?? widget.model.url.split('/').last;
    _videoPlayer = VideoPlayerController.networkUrl(Uri.parse(test));
    _initialize = _videoPlayer.initialize();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    _history = jsonDecode(preferences.getString('history') ?? '[]');

    // Remove any duplicates and insert the current video at the top
    _history.removeWhere((e) => e['url'] == widget.model.url);
    _history.insert(0, widget.model.toJson());

    // Remove any videos beyond 9 and save the list
    if (_history.length > 9) _history.removeRange(9, _history.length);
    preferences.setString('history', jsonEncode(_history));
  }

  @override
  void initState() { super.initState(); init(); }

  @override
  void dispose() { _videoPlayer.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'Player',
      actions: [
        IconButton(
          splashRadius: 25,
          tooltip: _looping ? 'Disable Looping' : 'Enable Looping',
          onPressed: () => setState(() => _looping = !_looping),
          icon: Icon(Icons.loop, color: _looping ? MyTheme.logoLight : Colors.grey)
        )
      ],
      child: Align(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Player', style: MyTheme.appText()),
          Text(_fileName, style: MyTheme.appText(size: 12, color: Colors.grey, weight: FontWeight.w500))
        ]
      ))
    ),
    body: DecoratedBox(
      decoration: MyTheme.boxDecoration(),
      child: FutureBuilder(
        future: _initialize,
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done ? Chewie(controller: ChewieController(
          autoPlay: true,
          looping: _looping,
          videoPlayerController: _videoPlayer
        )) : Center(child: MyTheme.loadingAnimation())
      )
    )
  );
}