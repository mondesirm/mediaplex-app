import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'models/media_model.dart';
import 'package:mediaplex/utils/theme.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key, this.index = 0, required this.images});

  final int index;
  final List<Media> images;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  int _index = 0;
  bool _autoplay = true;
  bool _showThumbnails = false;
  final CarouselController _carousel = CarouselController();

  @override
  void initState() { super.initState(); _index = widget.index; }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'Gallery',
      actions: [
        if (widget.images.isNotEmpty) IconButton(
          splashRadius: 25,
          tooltip: _showThumbnails ? 'Hide Thumbnails' : 'Show Thumbnails',
          onPressed: () => setState(() => _showThumbnails = !_showThumbnails),
          icon: Icon(_showThumbnails ? Icons.grid_off : Icons.grid_on, color: _showThumbnails ? MyTheme.logoLight : Colors.grey)
        ),
        IconButton(
          splashRadius: 25,
          onPressed: () => setState(() => _autoplay = !_autoplay),
          tooltip: _autoplay ? 'Disable Autoplay' : 'Enable Autoplay',
          icon: Icon(Icons.loop, color: _autoplay ? MyTheme.logoLight : Colors.grey)
        )
      ],
      child: Align(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gallery', style: MyTheme.appText()),
          Text(widget.images[_index].path!, style: MyTheme.appText(size: 12, color: Colors.grey, weight: FontWeight.w500))
        ]
      ))
    ),
    body: DecoratedBox(
      decoration: MyTheme.boxDecoration(),
      child: widget.images.isEmpty ? Align(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('lottie/not_found.json', width: 180, height: 180),
          Text('No media found.', style: MyTheme.appText(size: 20))
        ]
      )) : Align(child: Tooltip(
        message: 'Swipe Horizontally',
        child: CarouselSlider.builder(
          carouselController: _carousel,
          itemCount: widget.images.length,
          options: CarouselOptions(
            aspectRatio: 1,
            autoPlay: false,
            initialPage: _index,
            viewportFraction: .2,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            scrollPhysics: const BouncingScrollPhysics(),
            onPageChanged: (index, reason) => setState(() => _index = index)
          ),
          itemBuilder: (context, index, realIndex) => Column(children: [
            DecoratedBox(
              decoration: MyTheme.boxDecoration(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(widget.images[_index].url!, fit: BoxFit.cover)
              )
            ),
            index == _index ? Column(children: [
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 500,
                    child: Text(
                      index.toString(),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: MyTheme.appText(size: 20)
                    )
                  ),
                  Text(
                    '${widget.images.isEmpty ? 'No' : widget.images.length} media${widget.images.length == 1 ? '' : 's'}',
                    style: MyTheme.appText(weight: FontWeight.w500, color: Colors.grey)
                  )
                ]
              )
            ]) : const SizedBox()
          ])
        )
      ))
    )
  );
}