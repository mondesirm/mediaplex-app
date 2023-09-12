import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:better_player/better_player.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mediaplex/utils/theme.dart';

class Player extends StatefulWidget {
  const Player({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  late ChewieController chewieController;
  // late VideoPlayerController videoPlayerController;
  final videoPlayerController = VideoPlayerController.networkUrl(Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'));

  var betterPlayerConfiguration = BetterPlayerConfiguration(
    controlsConfiguration: BetterPlayerControlsConfiguration(
      showControls: true,
      enableFullscreen: false,
      textColor: Colors.white,
      iconsColor: Colors.white,
      showControlsOnInitialize: true,
      backgroundColor: Colors.transparent,
      overflowModalColor: Colors.transparent,
      loadingWidget: Center(child: LoadingAnimationWidget.fourRotatingDots(color: MyTheme.logoLightColor, size: 30))
    )
  );

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { Navigator.pop(context); return false; },
      // child: SafeArea(child: BetterPlayer.network('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', betterPlayerConfiguration: betterPlayerConfiguration))
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context)
          )
        ),
        body: SafeArea(child: Chewie(controller: ChewieController(
          videoPlayerController: videoPlayerController
        )))
      )
    );
  }
}