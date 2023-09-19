import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/models/channel_card_model.dart';

class AnimatedChannelCard extends ChannelCard {
  const AnimatedChannelCard({
    Key? key, isLive = false, required onFav, required onTap, required model
  }) : super(key: key, isLive: isLive, onFav: onFav, onTap: onTap, model: model);

  @override
  State<AnimatedChannelCard> createState() => _AnimatedChannelCardState();
}

class _AnimatedChannelCardState extends State<AnimatedChannelCard> with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 0, end: -.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn, reverseCurve: Curves.easeOut));
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapUp: (details) => _controller.reverse(),
    onTapDown: (details) => _controller.forward(),
    child: AnimatedBuilder(animation: _animation, builder: (context, child) => Transform.rotate(angle: _animation.value, child: ChannelCard(
      isLive: widget.isLive,
      onFav: widget.onFav,
      onTap: widget.onTap,
      model: widget.model
    )))
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ChannelCard extends StatefulWidget {
  const ChannelCard({super.key, this.isLive = false, required this.onFav, required this.onTap, required this.model});

  final bool isLive;
  final VoidCallback onFav;
  final VoidCallback onTap;
  final ChannelCardModel model;

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: Stack(children: [
      GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(width: 1.5, color: Colors.white.withOpacity(0.2)),
            boxShadow: [BoxShadow(blurRadius: 7, spreadRadius: 5, offset: const Offset(0, 3), color: Colors.white.withOpacity(0.1))]
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Stack(children: [
              Center(child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                child: CachedNetworkImage(
                  imageUrl: widget.model.logo,
                  errorWidget: (context, url, error) => const Icon(Icons.error, size: 50, color: Colors.white),
                  placeholder: (context, url) => LoadingAnimationWidget.fourRotatingDots(size: 20, color: Colors.white),
                  imageBuilder: (context, image) => Container(decoration: BoxDecoration(image: DecorationImage(fit: BoxFit.contain, image: image)))
                )
              ))]
            )
          )
        )
      ),
      Container(
        height: 45,
        decoration: BoxDecoration(gradient: LinearGradient(
          stops: const [0, 1],
          tileMode: TileMode.clamp,
          end: const FractionalOffset(1, 0),
          begin: const FractionalOffset(0, 0),
          colors: [MyTheme.logoDark, MyTheme.logoDark.withOpacity(.4)]
        )),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.model.name, overflow: TextOverflow.ellipsis, style: MyTheme.appText(color: MyTheme.darkBg)),
                Text(
                  widget.isLive ? widget.model.categories.join(' • ') : widget.model.languages.join(' • '),
                  overflow: TextOverflow.ellipsis,
                  style: MyTheme.appText(size: 12, weight: FontWeight.w500, color: MyTheme.darkBg)
                )
              ]
            ),
            Align(alignment: Alignment.topRight, child: IconButton(onPressed: widget.onFav, icon: const Icon(Icons.favorite_border, color: Colors.red)))
          ]
        )
      )
    ])
  );
}