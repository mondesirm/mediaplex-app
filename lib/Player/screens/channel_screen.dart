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
  final List<Channel> models;

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
              // columnCount: MediaQuery.sizeOf(context).width > 1000 ? 4 : 2,
              child: SlideAnimation(
                horizontalOffset: 80,
                child: FadeInAnimation(
                  child: AnimatedChannelCard(
                    isLive: widget.isLive,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Player(model: widget.models[index]))),
                    onFav: () => showDialog(context: context, builder: (BuildContext context) => _buildPopupDialog(context, model: widget.models[index])),
                    model: ChannelCardModel(
                      logo: widget.models[index].logo!,
                      name: widget.models[index].name!,
                      country: widget.models[index].country!.isNotEmpty ? widget.models[index].country![0] : 'International',
                      languages: widget.models[index].languages!.isNotEmpty ? widget.models[index].languages! : ['Language Unknown'],
                      categories: widget.models[index].categories!.isNotEmpty ? widget.models[index].categories! : ['Uncategorized']
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

  Widget _buildPopupDialog(BuildContext context, {required Channel model}) => AlertDialog(
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
          style: MyTheme.buttonStyle(),
          onPressed: () {
            service.addFav(context, model: model).then((value) {
              MyTheme.showSnackBar(context, text: value);
              // Update like button
              // setState(() => widget.models.firstWhere((_) => _.url == model.url).isFav = true);
            }).catchError((error) {
              MyTheme.showError(context, text: error.toString());
            }).whenComplete(() => Navigator.pop(context));
          },
          child: const Text('Yes')
        )
      ),
      SizedBox(width: 100, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: MyTheme.buttonStyle(), child: const Text('No')))
    ]
  );
}