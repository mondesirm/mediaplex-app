import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'models/media_model.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/screens/media_search_delegate.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key, this.index = 0, required this.items});

  final int index;
  final List<Media> items;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  int _index = 0;
  bool _autoplay = true;
  // bool _showThumbnails = false;
  final CarouselController _carousel = CarouselController();

  @override
  void initState() { super.initState(); _index = widget.index; }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'Gallery',
      actions: [
        // if (widget.images.isNotEmpty) IconButton(
        //   splashRadius: 25,
        //   tooltip: _showThumbnails ? 'Hide Thumbnails' : 'Show Thumbnails',
        //   onPressed: () => setState(() => _showThumbnails = !_showThumbnails),
        //   icon: Icon(_showThumbnails ? Icons.grid_off : Icons.grid_on, color: _showThumbnails ? MyTheme.logoLight : Colors.grey)
        // ),
        IconButton(
          splashRadius: 25,
          onPressed: () => setState(() => _autoplay = !_autoplay),
          tooltip: _autoplay ? 'Disable Autoplay' : 'Enable Autoplay',
          icon: Icon(Icons.loop, color: _autoplay ? MyTheme.logoLight : Colors.grey)
        ),
        IconButton(
          splashRadius: 25,
          tooltip: 'Search',
          icon: const Icon(Icons.search, color: MyTheme.logoLight),
          onPressed: () => showSearch(context: context, delegate: MediaSearchDelegate(widget.items))
        )
      ],
      child: Align(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gallery', style: MyTheme.appText()),
          Text(widget.items[_index].path!, style: MyTheme.appText(size: 12, color: Colors.grey, weight: FontWeight.w500))
        ]
      ))
    ),
    body: DecoratedBox(
      decoration: MyTheme.boxDecoration(),
      child: widget.items.isEmpty ? Align(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('lottie/not_found.json', width: 180, height: 180),
          Text('No media found.', style: MyTheme.appText(size: 20))
        ]
      )) : Stack(children: [
        Align(child: Tooltip(
          message: 'Swipe Horizontally',
          child: CarouselSlider.builder(
            carouselController: _carousel,
            itemCount: widget.items.length,
            options: CarouselOptions(
              // aspectRatio: 1,
              height: MediaQuery.of(context).size.height,
              autoPlay: _autoplay,
              initialPage: _index,
              viewportFraction: .6,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              scrollPhysics: const BouncingScrollPhysics(),
              onPageChanged: (index, reason) => setState(() => _index = index)
            ),
            itemBuilder: (context, index, realIndex) => Column(children: [
              InkWell(
                onTap: () => _carousel.animateToPage(index),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(widget.items[index].url!, fit: BoxFit.cover)
                  )
                ),
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
                        widget.items[index].path!,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: MyTheme.appText(size: 20)
                      )
                    ),
                    Text(
                      '${widget.items[index].createdAt} • ${widget.items[index].size} bytes',
                      style: MyTheme.appText(weight: FontWeight.w500, color: Colors.grey)
                    ),
                    Text(widget.items[index].description!, style: MyTheme.appText(weight: FontWeight.w500, color: Colors.grey))
                  ]
                )
              ]) : const SizedBox()
            ])
          )
        )),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: MyTheme.darkBg, borderRadius: BorderRadius.circular(15)),
            child: Tooltip(
              message: '${widget.items.length.toString()} item${widget.items.length == 1 ? '' : 's'}',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.perm_media, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(widget.items.length.toString(), style: MyTheme.appText())
                ]
              )
            )
          )
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Tooltip(
            message: 'Next (Long Press to Skip 10)',
            child: InkWell(
              onLongPress: () => _carousel.animateToPage(_index + 10),
              onTap: () => _carousel.nextPage(curve: Curves.linear, duration: const Duration(milliseconds: 100)),
              child: Container(
                width: 80,
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [MyTheme.logoDark, MyTheme.logoLight]),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                ),
                child: const Icon(Icons.arrow_forward_ios_outlined, color: Colors.white)
              )
            )
          )
        )
      ])
    )
  );
}