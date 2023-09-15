// ignore_for_file: must_be_immutable, unused_local_variable, avoid_print, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/channel_model.dart';
import 'package:mediaplex/Player/screens/channels_screen.dart';

class SelectScreen extends StatefulWidget {
  SelectScreen({super.key, required this.topWidget, required this.models});
  Widget topWidget;
  List<ChannelModel> models;

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  int _current = 0;
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    // We use the number of unique countries in widget.models instead of countryIcons
    var uniqueCountries = widget.models.map((e) => e.countries!.isNotEmpty ? e.countries![0].code!.toLowerCase() : '').toSet().toList();

    return Scaffold(
      appBar: MyTheme.appBar(context, child: widget.topWidget),
      body: Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: LinearGradient(
            stops: [0, 1],
            tileMode: TileMode.clamp,
            end: FractionalOffset(1, 0),
            begin: FractionalOffset(0, 0),
            colors: [MyTheme.darkBlue, MyTheme.slightBlue]
          ))
        ),
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .5,
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
                    int total_channels = 0;
                    String country_name = '';

                    List<ChannelModel> countryChannels = widget.models.where((e) {
                      return e.countries!.isNotEmpty ? e.countries![0].code!.toLowerCase() == uniqueCountries[index] : false;
                    }).toList();

                    if (countryChannels.isNotEmpty) {
                      for (ChannelModel model in countryChannels) {
                        if (model.countries!.isNotEmpty) {
                          country_name = model.countries![0].name!;
                          break;
                        }
                      }

                      total_channels = countryChannels.length;
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
                              Text(country_name, style: MyTheme.appText(size: 14, weight: FontWeight.w500, color: MyTheme.logoDarkColor))
                            ]
                          )
                        )))),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: index == _current ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 5, color: MyTheme.whiteColor)
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
                                country_name,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: MyTheme.appText(size: 20, weight: FontWeight.w600)
                              )
                            ),
                            Text(
                              '$total_channels channel${total_channels > 1 ? 's' : ''}',
                              style: MyTheme.appText(size: 15, weight: FontWeight.w500)
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
                style: ElevatedButton.styleFrom(backgroundColor: MyTheme.logoLightColor),
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
            decoration: BoxDecoration(color: MyTheme.darkBlue, borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.tv, color: MyTheme.whiteColor),
                const SizedBox(width: 8),
                Text('All', style: MyTheme.appText(size: 15, weight: FontWeight.w600)),
                const SizedBox(width: 20),
                Text(widget.models.length.toString(), style: MyTheme.appText(size: 15, weight: FontWeight.w600))
              ]
            )
          )
        )
      ])
    );
  }
}