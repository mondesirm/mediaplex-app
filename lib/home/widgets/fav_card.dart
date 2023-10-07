import 'package:flutter/material.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/player.dart';
import 'package:mediaplex/home/models/fav_model.dart';

class FavCard extends StatefulWidget {
  const FavCard({super.key, required this.model, required this.index, required this.onDelete});

  final Fav model;
  final int index;
  final VoidCallback onDelete;

  @override
  State<FavCard> createState() => _FavCardState();
}

class _FavCardState extends State<FavCard> {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(10),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: MyTheme.surface,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(blurRadius: 1, spreadRadius: 2, offset: const Offset(.3, .1), color: Colors.black.withOpacity(.2))]
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Row(children: [
          Text(widget.index.toString(), style: MyTheme.appText(size: 40, weight: FontWeight.bold, color: MyTheme.logoDark)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.model.name!, overflow: TextOverflow.ellipsis, style: MyTheme.appText(weight: FontWeight.bold)),
              Text(widget.model.category!, style: MyTheme.appText(size: 14, color: Colors.white.withOpacity(.5)))
            ]
          )
        ]),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MediaQuery.sizeOf(context).width > 500 ? SizedBox(
                width: 100,
                height: 40,
                child: ElevatedButton(
                  style: MyTheme.buttonStyle(),
                  onPressed: () => MyTheme.push(context, name: 'player', widget: Player(model: widget.model)),
                  child: const Text('Watch')
                )
              ) : IconButton(icon: const Icon(Icons.play_circle, color: MyTheme.logoLight), onPressed: () => MyTheme.push(
                context,
                name: 'player',
                widget: Player(model: widget.model)
              )),
              const SizedBox(width: 20),
              IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.remove_circle, color: Colors.red))
            ]
          )
        )
      ]
    )
  );
}