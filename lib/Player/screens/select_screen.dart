import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/channel_model.dart';
import 'package:mediaplex/player/screens/channel_screen.dart';

class SelectScreen extends StatefulWidget {
  const SelectScreen({super.key, required this.topWidget, required this.models});

  final Widget topWidget;
  final List<Channel> models;

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  int _current = 0;
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    // We use the number of unique countries in widget.models instead of countryIcons
    var uniqueCountries = widget.models.map((e) => e.country!.isNotEmpty ? e.country!.toLowerCase() : '').toSet().toList();

    return Scaffold(
      appBar: MyTheme.appBar(context, screen: 'SelectScreen', child: widget.topWidget),
      body: Stack(children: [
        Container(decoration: MyTheme.boxDecoration()),
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height * .5,
                child: CarouselSlider.builder(
                  itemCount: uniqueCountries.length,
                  carouselController: buttonCarouselController,
                  options: CarouselOptions(
                    aspectRatio: 1,
                    autoPlay: false,
                    initialPage: _current,
                    viewportFraction: .2,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    scrollPhysics: const BouncingScrollPhysics(),
                    onPageChanged: (index, reason) => setState(() => _current = index)
                  ),
                  itemBuilder: ((context, index, realIndex) {
                    int count = 0;
                    String countryName = '';

                    List<Channel> countryChannels = widget.models.where((e) {
                      return e.country!.isNotEmpty ? e.country!.toLowerCase() == uniqueCountries[index] : false;
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
                          isLive: true,
                          models: countryChannels,
                          topWidget: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              widget.topWidget,
                              const SizedBox(width: 5),
                              Text(countryName, style: MyTheme.appText(size: 14, weight: FontWeight.w500, color: MyTheme.logoDark))
                            ]
                          )
                        )))),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: index == _current ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 5, color: Colors.white)
                          ) : null,
                          child: Image.asset('countries/${uniqueCountries[index]}.png', width: 120, height: 120, fit: BoxFit.contain)
                        )
                      ),
                      index == _current ? Column(children: [
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
                )
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onLongPress: () => buttonCarouselController.animateToPage(_current + 20),
                style: ElevatedButton.styleFrom(backgroundColor: MyTheme.logoLight),
                onPressed: () => buttonCarouselController.nextPage(curve: Curves.linear, duration: const Duration(milliseconds: 100)),
                child: const Icon(Icons.arrow_forward, size: 24)
              )
            ]
          )
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: MyTheme.darkBg, borderRadius: BorderRadius.circular(15)),
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
      ])
    );
  }
}