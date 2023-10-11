import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'channel_search_delegate.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/player.dart';
import 'package:mediaplex/home/models/channel_model.dart';
import 'package:mediaplex/player/widgets/channel_card.dart';
import 'package:mediaplex/player/service/player_service.dart';
import 'package:mediaplex/player/models/channel_card_model.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key, required this.title, required this.channels, this.showSearch = true});

  final Widget title;
  final bool showSearch;
  final List<Channel> channels;

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  int _index = 0;
  bool _autoplay = true;
  bool _listView = true;
  final PlayerService _service = PlayerService();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'ChannelsScreen',
      actions: [
        if (widget.channels.isNotEmpty) IconButton(
          splashRadius: 25,
          onPressed: () => setState(() => _autoplay = !_autoplay),
          tooltip: _autoplay ? 'Disable Autoplay' : 'Enable Autoplay',
          icon: Icon(Icons.motion_photos_auto, color: _autoplay ? MyTheme.logoLight : Colors.grey)
        ),
        if (widget.channels.isNotEmpty) IconButton(
          splashRadius: 25,
          tooltip: _listView ? 'Grid View' : 'List View',
          onPressed: () => setState(() => _listView = !_listView),
          icon: Icon(_listView ? Icons.grid_view : Icons.view_list, color: MyTheme.logoLight)
        ),
        if (widget.showSearch) IconButton(
          splashRadius: 25,
          tooltip: 'Search',
          icon: const Icon(Icons.search, color: MyTheme.logoLight),
          onPressed: () => showSearch(context: context, delegate: ChannelSearchDelegate(widget.title, [widget.channels[0].country!], widget.channels))
        )
      ],
      child: widget.title
    ),
    body: Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: MyTheme.boxDecoration(),
      child: widget.channels.isEmpty ? Align(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('lottie/not_found.json', width: 180, height: 180),
          Text('No channels found.', style: MyTheme.appText(size: 20))
        ]
      )) : OrientationBuilder(builder: (context, orientation) => _listView ? (orientation == Orientation.landscape ? Row.new : Column.new)(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container(
            padding: const EdgeInsets.all(24),
            width: orientation == Orientation.landscape ? null : 300,
            height: orientation == Orientation.landscape ? 300 : null,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(width: 1.5, color: Colors.white.withOpacity(.2)),
              boxShadow: [BoxShadow(blurRadius: 7, spreadRadius: 5, offset: const Offset(0, 3), color: Colors.white.withOpacity(.1))]
            ),
            child: CachedNetworkImage(
              imageUrl: widget.channels[_index].logo!,
              placeholder: (context, url) => MyTheme.loadingAnimation(),
              errorWidget: (context, url, error) => const Icon(Icons.error, size: 50, color: Colors.white),
              imageBuilder: (context, image) => Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), image: DecorationImage(image: image)))
            )
          )),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: AnimationLimiter(child: CarouselSlider.builder(
            itemCount: widget.channels.length,
            itemBuilder: (context, index, realIndex) => AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 700),
              child: SlideAnimation(child: FadeInAnimation(child: GestureDetector(
                onTap: () => MyTheme.push(context, name: 'player', widget: Player(model: widget.channels[index])),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: index == _index ? Colors.black .withOpacity(.6) : Colors.black .withOpacity(.3)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(
                        widget.channels[index].name!,
                        style: TextStyle(color: index == _index ? Colors.white.withOpacity(.7) : Colors.white.withOpacity(.3))
                      )),
                      Text(
                        widget.channels[index].languages!.join(' • '),
                        style: TextStyle(color: index == _index ? Colors.white.withOpacity(.7) : Colors.white.withOpacity(.3))
                      )
                    ]
                  )
                )
              )))
            ),
            options: CarouselOptions(
              aspectRatio: 1,
              autoPlay: _autoplay,
              viewportFraction: .2,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              scrollDirection: Axis.vertical,
              scrollPhysics: const BouncingScrollPhysics(),
              onPageChanged: (index, reason) => setState(() => _index = index)
            )
          )))
        ]
      ) : GridView.count(
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        physics: const BouncingScrollPhysics(),
        scrollDirection: orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
        crossAxisCount: MediaQuery.sizeOf(context).width > 1024 ? 4 : MediaQuery.sizeOf(context).width > 768 ? 3 : MediaQuery.sizeOf(context).width > 450 ? 2 : 1,
        children: List.generate(widget.channels.length, (index) => AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 500),
          // columnCount: MediaQuery.sizeOf(context).width > 1000 ? 4 : 2,
          child: SlideAnimation(child: FadeInAnimation(child: ChannelCard(
            onTap: () => MyTheme.push(context, name: 'player', widget: Player(model: widget.channels[index])),
            // widget.models[index]
            onFav: () => MyTheme.showAlertDialog(context, title: 'Add Favorite', text: 'Do you want to add ${widget.channels[index].name} to your favorites?', onConfirm: () {
              _service.addFav(context, model: widget.channels[index]).then((value) {
                // setState(() { widget.models.firstWhere((_) => _.url == widget.models[index].url).isFav = true; });
                MyTheme.showSnackBar(context, text: value);
              }).catchError((error) {
                MyTheme.showError(context, text: error.toString());
              });
            }),
            model: ChannelCardModel(
              logo: widget.channels[index].logo!,
              name: widget.channels[index].name!,
              country: widget.channels[index].country!.isNotEmpty ? widget.channels[index].country![0] : 'International',
              languages: widget.channels[index].languages!.isNotEmpty ? widget.channels[index].languages! : ['Language Unknown'],
              categories: widget.channels[index].categories!.isNotEmpty ? widget.channels[index].categories! : ['Uncategorized']
            )
          )))
        ))
      ))
    )
  );
}