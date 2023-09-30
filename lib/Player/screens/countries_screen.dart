import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'channels_screen.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/utils/constants.dart';
import 'package:mediaplex/home/models/channel_model.dart';

class CountriesScreen extends StatefulWidget {
  const CountriesScreen({super.key, required this.title, required this.models});

  final Widget title;
  final List<Channel> models;

  @override
  State<CountriesScreen> createState() => _CountriesScreenState();
}

class _CountriesScreenState extends State<CountriesScreen> {
  int _index = 0;
  bool _showAll = false;
  late List<String> _countries;
  final CarouselController _carousel = CarouselController();

  @override
  void initState() {
    super.initState();
    _countries = widget.models.map((e) => e.country!.isNotEmpty ? e.country!.toLowerCase() : '').toSet().toList();
  }

  void _toggleShowAll() {
    if (_showAll) { _countries = widget.models.map((e) => e.country!.isNotEmpty ? e.country!.toLowerCase() : '').toSet().toList(); }
    else { _countries = countryIcons; }
    _showAll = !_showAll;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'SelectScreen',
      actions: [
        if (widget.models.isNotEmpty) IconButton(
          splashRadius: 25,
          onPressed: () => setState(() => _toggleShowAll()),
          tooltip: _showAll ? 'Show available only' : 'Show all countries',
          icon: Icon(_showAll ? Icons.tv_off : Icons.tv, color: MyTheme.logoLight)
        )
      ],
      child: widget.title
    ),
    body: Container(
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
      ) : Stack(children: [
        Align(
          alignment: Alignment.center,
          child: SizedBox(
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
                  enableInfiniteScroll: false,
                  scrollPhysics: const BouncingScrollPhysics(),
                  onPageChanged: (index, reason) => setState(() => _index = index)
                ),
                itemBuilder: ((context, index, realIndex) {
                  int count = 0;
                  String countryName = '';

                  List<Channel> countryChannels = widget.models.where((e) {
                    return e.country!.isNotEmpty ? e.country!.toLowerCase() == _countries[index] : false;
                  }).toList();

                  if (countryChannels.isNotEmpty) {
                    for (Channel model in countryChannels) {
                      if (model.country!.isNotEmpty) {
                        countryName = model.country!;
                        break;
                      }
                    }

                    count = countryChannels.length;
                  }

                  return Column(children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: ((context) => ChannelScreen(
                        models: countryChannels,
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.title,
                            const SizedBox(width: 5),
                            Text(countryName, style: MyTheme.appText(size: 14, weight: FontWeight.w500, color: MyTheme.logoDark))
                          ]
                        )
                      )))),
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
                              countryName,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: MyTheme.appText(size: 20)
                            )
                          ),
                          Text(
                            '${count == 0 ? 'No' : count} channel${count == 1 ? '' : 's'}',
                            style: MyTheme.appText(weight: FontWeight.w500, color: Colors.grey)
                          )
                        ]
                      )
                    ]) : const SizedBox()
                  ]);
                })
              ),
            )
          )
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: MyTheme.darkBg, borderRadius: BorderRadius.circular(15)),
            child: Tooltip(
              message: 'Total Channels',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.tv, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('All', style: MyTheme.appText()),
                  const SizedBox(width: 20),
                  Text(widget.models.length.toString(), style: MyTheme.appText())
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
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  gradient: LinearGradient(end: Alignment.centerRight, begin: Alignment.centerLeft, colors: [MyTheme.logoDark, MyTheme.logoLight])
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