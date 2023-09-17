import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/player.dart';
import 'package:mediaplex/home/models/channel_model.dart';
import 'package:mediaplex/player/widgets/channel_card.dart';
import 'package:mediaplex/player/service/player_service.dart';
import 'package:mediaplex/player/models/channel_card_model.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key, this.isLive = false, required this.topWidget, required this.models});

  final bool isLive;
  final Widget topWidget;
  final List<ChannelModel> models;

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  PlayerService service = PlayerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyTheme.appBar(context, screen: 'ChannelScreen', child: widget.topWidget),
      body: Stack(children: [
        Container(decoration: MyTheme.boxDecoration()),
        widget.models.isEmpty ? Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset('lottie/not_found.json', width: 180, height: 180),
              Text('No channels found.', style: MyTheme.appText(size: 20))
            ]
          )
        ) : Padding(
          padding: const EdgeInsets.all(10),
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.8,
            padding: const EdgeInsets.all(10),
            physics: const BouncingScrollPhysics(),
            key: const PageStorageKey<String>('GridView'),
            children: List.generate(widget.models.length, (index) => AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(seconds: 1, milliseconds: 500),
              // columnCount: MediaQuery.of(context).size.width > 1000 ? 4 : 2,
              child: SlideAnimation(
                horizontalOffset: 80,
                child: FadeInAnimation(
                  child: AnimatedChannelCard(
                    isLive: widget.isLive,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Player(videoUrl: widget.models[index].url!))),
                    onFav: () => showDialog(context: context, builder: (BuildContext context) => _buildPopupDialog(context, model: widget.models[index])),
                    model: ChannelCardModel(
                      channel_name: widget.models[index].name!,
                      languages: widget.models[index].languages!.isNotEmpty ? widget.models[index].languages![0].name! : 'None',
                      code: widget.models[index].countries!.isNotEmpty ? widget.models[index].countries![0].code! : 'International',
                      image_url: widget.models[index].logo != null ? widget.models[index].logo! : 'https://i.imgur.com/rzrOS3N.png',
                      channel_category: widget.models[index].categories!.isNotEmpty ? widget.models[index].categories![0].name! : 'Entertainment'
                    )
                  )
                )
              )
            ))
          )
        )
      ])
    );
  }

  Widget _buildPopupDialog(BuildContext context, {required ChannelModel model}) => AlertDialog(
    backgroundColor: MyTheme.surface,
    actionsAlignment: MainAxisAlignment.spaceBetween,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    actionsPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Do you want to add this channel to your favorites?',
          style: MyTheme.appText(weight: FontWeight.w500)
        )
      ]
    ),
    actions: [
      SizedBox(
        width: 100,
        child: ElevatedButton(
          style: MyTheme.buttonStyle(backColor: MyTheme.logoLight),
          onPressed: () {
            service.addToFav(context: context, model: model).then((value) {
              final snackBar = SnackBar(backgroundColor: MyTheme.lightBg, content: Text(value, style: MyTheme.appText(size: 12, weight: FontWeight.w500)));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              Navigator.of(context).pop();
            });
          },
          child: const Text('Yes')
        )
      ),
      SizedBox(
        width: 100,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: MyTheme.buttonStyle(backColor: MyTheme.logoLight),
          child: const Text('No')
        )
      )
    ]
  );
}