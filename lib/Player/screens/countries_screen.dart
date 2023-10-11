import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'channels_screen.dart';
import 'channel_search_delegate.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/channel_model.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key, required this.title, required this.channels});

  final Widget title;
  final List<Channel> channels;

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  int _index = 0;
  bool _wrap = false;
  late List<String> _countries;
  final CarouselController _carousel = CarouselController();
  // final TextEditingController _search = TextEditingController();

  @override
  void initState() { super.initState(); _countries = widget.channels.map((_) => _.country!).where((_) => _ != '').toSet().toList(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'CountriesScreen',
      actions: [
        if (widget.channels.isNotEmpty) IconButton(
          splashRadius: 25,
          onPressed: () => setState(() => _wrap = !_wrap),
          tooltip: _wrap ? 'Disable Wrap' : 'Enable Wrap',
          icon: Icon(Icons.loop, color: _wrap ? MyTheme.logoLight : Colors.grey)
        ),
        // IconButton(
        //   splashRadius: 25,
        //   tooltip: 'Search',
        //   icon: const Icon(Icons.search, color: MyTheme.logoLight),
        //   onPressed: () => MyTheme.showInputDialog(context, controller: _search)
        // ),
        IconButton(
          splashRadius: 25,
          tooltip: 'Search',
          icon: const Icon(Icons.search, color: MyTheme.logoLight),
          onPressed: () => showSearch(context: context, delegate: ChannelSearchDelegate(widget.title, _countries, widget.channels))
        )
      ],
      child: widget.title
    ),
    body: DecoratedBox(
      decoration: MyTheme.boxDecoration(),
      child: widget.channels.isEmpty ? Align(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('lottie/not_found.json', width: 180, height: 180),
          Text('No channels found.', style: MyTheme.appText(size: 20))
        ]
      )) : Stack(children: [
        Align(child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: MediaQuery.sizeOf(context).height * .5,
          child: Tooltip(
            message: 'Swipe Horizontally',
            child: CarouselSlider.builder(
              itemCount: _countries.length,
              carouselController: _carousel,
              options: CarouselOptions(
                aspectRatio: 1,
                autoPlay: false,
                initialPage: _index,
                viewportFraction: .2,
                enlargeCenterPage: true,
                enableInfiniteScroll: _wrap,
                scrollPhysics: const BouncingScrollPhysics(),
                onPageChanged: (index, reason) => setState(() => _index = index)
              ),
              itemBuilder: (context, index, realIndex) {
                List<Channel> channels = widget.channels.where((_) => _.country == _countries[index]).toList();

                return Column(children: [
                  InkWell(
                    onTap: () => MyTheme.push(
                      context,
                      name: 'livetv/${_countries[index].toLowerCase()}',
                      widget: ChannelsScreen(
                        channels: channels,
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.title,
                            const SizedBox(width: 5),
                            Text(_countries[index], style: MyTheme.appText(size: 14, weight: FontWeight.w500, color: MyTheme.logoDark))
                          ]
                        )
                      )
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: index == _index ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 5, color: Colors.white)
                      ) : null,
                      child: Image.asset('countries/${_countries[index]}.png', width: 120, height: 120, fit: BoxFit.contain)
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
                            widget.channels[index].country!,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: MyTheme.appText(size: 20)
                          )
                        ),
                        Text(
                          '${channels.isEmpty ? 'No' : channels.length} channel${channels.length == 1 ? '' : 's'}',
                          style: MyTheme.appText(weight: FontWeight.w500, color: Colors.grey)
                        )
                      ]
                    )
                  ]) : const SizedBox()
                ]);
              }
            )
          )
        )),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: MyTheme.darkBg, borderRadius: BorderRadius.circular(15)),
            child: Tooltip(
              message: '${widget.channels.length.toString()} channel${widget.channels.length == 1 ? '' : 's'}',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.tv, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(widget.channels.length.toString(), style: MyTheme.appText())
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