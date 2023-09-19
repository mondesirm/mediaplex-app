import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
// import 'package:better_player/better_player.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mediaplex/utils/theme.dart';

class Player extends StatefulWidget {
  const Player({super.key, required this.model});

  final Object model;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late String fileName;
  late ChewieController chewieController;
  // late BetterPlayer betterPlayerController;
  late VideoPlayerController videoPlayerController;
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
      loadingWidget: Center(child: LoadingAnimationWidget.fourRotatingDots(color: MyTheme.logoLight, size: 30))
    )
  ); */

  void sendAnalytics() async {
    fileName = test.split('/').last;
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(test));
    // betterPlayerController = BetterPlayer.network(test, betterPlayerConfiguration: betterPlayerConfiguration);
    chewieController = ChewieController(looping: true, autoPlay: true, aspectRatio: 3 / 2, videoPlayerController: videoPlayerController);

    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // sharedPreferences.setString('lastPlayed', model.toString());
  }

  @override
  void initState() { sendAnalytics(); super.initState(); }

  @override
  void dispose() { videoPlayerController.dispose(); chewieController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async { Navigator.pop(context); return false; },
      child: Scaffold(
        appBar: MyTheme.appBar(context, screen: 'Player', child: Text('Playing $fileName', style: MyTheme.appText(size: 18))),
        body: Stack(children: [
          Container(decoration: MyTheme.boxDecoration()),
          Chewie(controller: ChewieController(
            looping: true,
            autoPlay: true,
            aspectRatio: 3 / 2,
            videoPlayerController: videoPlayerController
          ))
        ])
      )
    );
  }
}