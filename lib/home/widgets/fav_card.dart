// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/player.dart';
import 'package:mediaplex/home/models/fav_model.dart';

class FavCard extends StatefulWidget {
  FavCard({super.key, required this.model, required this.index,required this.onTap});
  Fav model;
  int index;
  VoidCallback onTap;

  @override
  State<FavCard> createState() => _FavCardState();
}

class _FavCardState extends State<FavCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.2),
                offset: const Offset(.3, .1),
                spreadRadius: 2,
                blurRadius: 1)
          ],
          color: MyTheme.surface,
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.index.toString(),
                style: MyTheme.appText(size: 40, weight: FontWeight.bold, color: MyTheme.logoDark)
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .5,
                    child: Text(
                      widget.model.channelName!,
                      overflow: TextOverflow.ellipsis,
                      style:
                          MyTheme.appText(size: 20, weight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    widget.model.category!,
                    style: MyTheme.appText(
                        size: 14,
                        color: Colors.white.withOpacity(.5))
                  )
                ]
              )
            ]
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40,
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return Player(videoUrl: widget.model.streamLink!);
                    }));
                  },
                  style: MyTheme.buttonStyle(
                      backColor: MyTheme.logoLight, fontSize: 13),
                  child: const Text("Watch"),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                  onPressed: widget.onTap,
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ))
            ],
          )
        ],
      ),
    );
  }
}
