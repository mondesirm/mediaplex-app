import 'package:flutter/material.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/category_card_model.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard({super.key, required this.model});

  final CategoryCardModel model;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: MyTheme.surface,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(blurRadius: 2, spreadRadius: 3, offset: const Offset(.3, .1), color: Colors.black.withOpacity(.04))]
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(widget.model.data, size: 60, color: MyTheme.logoLight),
        const Spacer(),
        widget.model.child,
        const Spacer(),
        Row(children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: widget.model.count == 0 ? Colors.transparent : Colors.red,
            border: Border.all(width: .5, color: widget.model.count == 0 ? Colors.grey : Colors.red),
          )),
          const SizedBox(width: 5),
          Text(
            '${widget.model.count == 0 ? 'No' : widget.model.count} channel${widget.model.count == 1 ? '' : 's'}',
            style: MyTheme.appText(size: 12, weight: FontWeight.w500, color: Colors.white.withOpacity(.5))
          )
        ])
      ]
    )
  );
}