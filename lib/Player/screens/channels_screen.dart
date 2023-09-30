import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/player.dart';
import 'package:mediaplex/home/models/channel_model.dart';
import 'package:mediaplex/player/widgets/channel_card.dart';
import 'package:mediaplex/player/service/player_service.dart';
import 'package:mediaplex/player/models/channel_card_model.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key, required this.title, required this.models});

  final Widget title;
  final List<Channel> models;

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  int _index = 0;
  bool _listView = true;
  final PlayerService _service = PlayerService();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'ChannelScreen',
      actions: [
        IconButton(
          splashRadius: 25,
          tooltip: _listView ? 'Grid View' : 'List View',
          onPressed: () => setState(() => _listView = !_listView),
          icon: Icon(_listView ? Icons.grid_view : Icons.view_list, color: MyTheme.logoLight)
        )
      ],
      child: widget.title
    ),
    body: Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: MyTheme.boxDecoration(),
      child: widget.models.isEmpty ? Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('lottie/not_found.json', width: 180, height: 180),
            Text('No channels found.', style: MyTheme.appText(size: 20))
          ]
        )
      ) : OrientationBuilder(builder: (context, orientation) => _listView ? (orientation == Orientation.landscape ? Row.new : Column.new)(
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
              imageUrl: widget.models[_index].logo!,
              placeholder: (context, url) => MyTheme.loadingAnimation(),
              errorWidget: (context, url, error) => const Icon(Icons.error, size: 50, color: Colors.white),
              imageBuilder: (context, image) => Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), image: DecorationImage(image: image)))
            )
          )),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: AnimationLimiter(child: CarouselSlider.builder(
            itemCount: widget.models.length,
            itemBuilder: (context, index, realIndex) => AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 700),
              child: SlideAnimation(child: FadeInAnimation(child: GestureDetector(
                onTap: () => MyTheme.push(context, widget: Player(model: widget.models[index])),
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
                        widget.models[index].name!,
                        style: TextStyle(color: index == _index ? Colors.white.withOpacity(.7) : Colors.white.withOpacity(.3))
                      )),
                      Text(
                        widget.models[index].languages!.join(' • '),
                        style: TextStyle(color: index == _index ? Colors.white.withOpacity(.7) : Colors.white.withOpacity(.3))
                      )
                    ]
                  )
                )
              )))
            ),
            options: CarouselOptions(
              aspectRatio: 1,
              autoPlay: true,
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
        children: List.generate(widget.models.length, (index) => AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 500),
          // columnCount: MediaQuery.sizeOf(context).width > 1000 ? 4 : 2,
          child: SlideAnimation(child: FadeInAnimation(child: ChannelCard(
            onTap: () => MyTheme.push(context, widget: Player(model: widget.models[index])),
            // widget.models[index]
            onFav: () => MyTheme.showAlertDialog(context, title: 'Add Favorite', text: 'Do you want to add ${widget.models[index].name} to your favorites?', onConfirm: () {
              _service.addFav(context, model: widget.models[index]).then((value) {
                // setState(() => widget.models.firstWhere((_) => _.url == model.url).isFav = true);
                MyTheme.showSnackBar(context, text: value);
              }).catchError((error) {
                MyTheme.showError(context, text: error.toString());
              });
            }),
            model: ChannelCardModel(
              logo: widget.models[index].logo!,
              name: widget.models[index].name!,
              country: widget.models[index].country!.isNotEmpty ? widget.models[index].country![0] : 'International',
              languages: widget.models[index].languages!.isNotEmpty ? widget.models[index].languages! : ['Language Unknown'],
              categories: widget.models[index].categories!.isNotEmpty ? widget.models[index].categories! : ['Uncategorized']
            )
          )))
        ))
      ))
    )
  );
}