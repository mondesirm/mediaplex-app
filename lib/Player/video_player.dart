import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
// import 'package:better_player/better_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';

import 'package:mediaplex/utils/theme.dart';

class Player extends StatefulWidget {
  const Player({super.key, required this.model});

  final dynamic model;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late String _fileName;
  late ChewieController _chewie;
  // late BetterPlayer _betterPlayer;
  late VideoPlayerController _videoPlayer;
  String test = 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  /* BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
    controlsConfiguration: BetterPlayerControlsConfiguration(
      showControls: true,
      enableFullscreen: false,
      textColor: Colors.white,
      iconsColor: Colors.white,
      showControlsOnInitialize: true,
      backgroundColor: Colors.transparent,
      overflowModalColor: Colors.transparent,
      loadingWidget: Center(child: MyTheme.loadingAnimation())
    )
  ); */

  void init() async {
    _fileName = widget.model.name ?? test.split('/').last;
    _videoPlayer = VideoPlayerController.networkUrl(Uri.parse(test));
    // betterPlayerController = BetterPlayer.network(test, betterPlayerConfiguration: betterPlayerConfiguration);
    _chewie = ChewieController(looping: true, autoPlay: true, aspectRatio: 3 / 2, videoPlayerController: _videoPlayer);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('lastPlayed', jsonEncode(widget.model));
  }

  @override
  void initState() { super.initState(); init(); }

  @override
  void dispose() { _videoPlayer.dispose(); _chewie.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(context, screen: 'Player', child: Text('Playing $_fileName', style: MyTheme.appText())),
    body: Container(
      decoration: MyTheme.boxDecoration(),
      child: Chewie(controller: ChewieController(
        looping: true,
        autoPlay: true,
        aspectRatio: 3 / 2,
        videoPlayerController: _videoPlayer
      ))
    )
  );
}