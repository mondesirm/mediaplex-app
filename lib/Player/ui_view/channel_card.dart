// ignore_for_file: must_be_immutable, prefer_const_constructors, sized_box_for_whitespace
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/Player/models/channel_card_model.dart';

class ChannelCard extends StatefulWidget {
  ChannelCard({super.key, required this.model, required this.onFav, this.isLive = false, required this.onTap});
  bool isLive;
  VoidCallback onFav;
  VoidCallback onTap;
  ChannelCardModel model;

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onTap,
            child: Column(children: [
              Container(
                width: 200,
                height: 150,
                decoration: BoxDecoration(
                  color: MyTheme.slightDarkBlue,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
                ),
                child: Center(child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                  child: CachedNetworkImage(
                    imageUrl: widget.model.image_url,
                    errorWidget: (context, url, error) => Icon(Icons.error, size: 50, color: Colors.white),
                    placeholder: (context, url) => LoadingAnimationWidget.fourRotatingDots(size: 20, color: MyTheme.whiteColor),
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(color: Colors.white, image: DecorationImage(fit: BoxFit.contain, image: imageProvider))
                    )
                  )
                ))
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                    gradient: LinearGradient(
                      stops: const [0, 1],
                      tileMode: TileMode.clamp,
                      end: const FractionalOffset(1, 0),
                      begin: const FractionalOffset(0, 0),
                      colors: [MyTheme.logoDarkColor, MyTheme.logoDarkColor.withOpacity(.4)]
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 180,
                        child: Text(
                          widget.model.channel_name,
                          overflow: TextOverflow.ellipsis,
                          style: MyTheme.appText(
                              size: 15, weight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        overflow: TextOverflow.ellipsis,
                        widget.isLive ? widget.model.channel_category : widget.model.languages,
                        style: MyTheme.appText(size: 12, weight: FontWeight.w500, color: MyTheme.whiteColor.withOpacity(.7))
                      )
                    ]
                  )
                )
              )
            ])
          ),
          Align(alignment: Alignment.topRight, child: IconButton(onPressed: widget.onFav, icon: Icon(Icons.more_vert, color: MyTheme.whiteColor)))
        ]
      )
    );
  }
}