// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/show_model.dart';

class ShowCard extends StatefulWidget {
  ShowCard({super.key, required this.model});
  ShowModel model;

  @override
  State<ShowCard> createState() => _ShowCardState();
}

class _ShowCardState extends State<ShowCard> {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(20),
    width: MediaQuery.of(context).size.height * 0.6,
    padding: const EdgeInsets.only(top: 42, left: 20, right: 20, bottom: 20),
    decoration: BoxDecoration(
      color: MyTheme.slightDarkBlue,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(blurRadius: 2, spreadRadius: 3, offset: const Offset(0.3, 0.1), color: Colors.black.withOpacity(0.04))]
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(widget.model.data, size: 60, color: MyTheme.logoLightColor),
        const SizedBox(height: 10),
        widget.model.child,
        const SizedBox(height: 10),
        Row(children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(3)) ),
          const SizedBox(width: 5),
          Text(
            '${widget.model.total_channels} channel${widget.model.total_channels > 1 ? 's' : ''}',
            style: MyTheme.appText(size: 12, weight: FontWeight.w500, color: MyTheme.whiteColor.withOpacity(0.6))
          )
        ])
      ]
    )
  );
}