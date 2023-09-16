import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
// import 'package:better_player/better_player.dart';
// import 'package:lecle_yoyo_player/lecle_yoyo_player.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mediaplex/utils/theme.dart';

class Player extends StatelessWidget {
  const Player({super.key, required this.videoUrl});

  final String videoUrl;

  // final betterPlayerConfiguration = BetterPlayerConfiguration(
  //   controlsConfiguration: BetterPlayerControlsConfiguration(
  //     showControls: true,
  //     enableFullscreen: false,
  //     textColor: Colors.white,
  //     iconsColor: Colors.white,
  //     showControlsOnInitialize: true,
  //     backgroundColor: Colors.transparent,
  //     overflowModalColor: Colors.transparent,
  //     loadingWidget: Center(child: LoadingAnimationWidget.fourRotatingDots(color: MyTheme.logoLightColor, size: 30))
  //   )
  // );

  @override
  Widget build(BuildContext context) {
    var url = 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
    // final betterPlayerController = BetterPlayer.network(url, betterPlayerConfiguration: betterPlayerConfiguration);
    final videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));

    // Get name of file
    var fileName = videoUrl.split('/').last;

    return WillPopScope(
      onWillPop: () async { Navigator.pop(context); return false; },
      child: Scaffold(
        appBar: MyTheme.appBar(context, screen: 'Player', child: Text('Playing $fileName', style: MyTheme.appText(size: 18, weight: FontWeight.w600))),
        body: Stack(children: [
          Container(decoration: const BoxDecoration(gradient: LinearGradient(
            stops: [0, 1],
            tileMode: TileMode.clamp,
            end: FractionalOffset(1, 0),
            begin: FractionalOffset(0, 0),
            colors: [MyTheme.darkBlue, MyTheme.slightDarkBlue]
          ))),
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