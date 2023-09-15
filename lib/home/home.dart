// ignore_for_file: unused_field, await_only_futures, avoid_print, unused_local_variable

import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:mediaplex/utils/constants.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/ui_view/show_card.dart';
import 'package:mediaplex/home/models/channel_model.dart';
import 'package:mediaplex/home/service/home_service.dart';
import 'package:mediaplex/Player/screens/select_screen.dart';
import 'package:mediaplex/Player/screens/channels_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Timer _timer;
  HomeService service = HomeService();
  late Future<List<ChannelModel>> _channels;
  String formattedTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String formattedDate = DateFormat('MMM dd, yyyy').format(DateTime.now()).toString();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    const orientations = [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight];
    SystemChrome.setPreferredOrientations(orientations);
    _channels = service.fetchChannels(context);
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) => _update());
  }

  void _update() {
    setState(() {
      formattedTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
      formattedDate = DateFormat('MMM dd, yyyy').format(DateTime.now()).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: MyTheme.appBar(
          context,
          showSettings: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formattedTime, style: MyTheme.appText(size: 15, weight: FontWeight.w600, isShadow: true)),
              Text(formattedDate, style: MyTheme.appText(size: 11, weight: FontWeight.w500, color: Colors.white54))
            ]
          )
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  stops: [0, 1],
                  tileMode: TileMode.clamp,
                  end: FractionalOffset(1, 0),
                  begin: FractionalOffset(0, 0),
                  colors: [MyTheme.darkBlue, MyTheme.slightBlue]
                )
              )
            ),
            FutureBuilder<List<ChannelModel>>(
              future: _channels,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .6,
                        child: AnimationLimiter(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: showModels.length,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: ((context, index) {
                              List<ChannelModel> channelObjs = [];

                              for (ChannelModel models in snapshot.data!) {
                                if (models.categories!.isNotEmpty && models.categories![0].name == showModels[index].show_type) {
                                  channelObjs.add(models);
                                }
                              }

                              showModels[index].total_channels = index != 0 ? channelObjs.length : snapshot.data!.length;

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(seconds: 1),
                                child: SlideAnimation(
                                  horizontalOffset: 80,
                                  child: FadeInUp(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (index == 0 || index == 1) {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: ((context) => SelectScreen(
                                              topWidget: showModels[index].child,
                                              models: index == 0 ? snapshot.data! : channelObjs
                                            ))
                                          ));
                                        } else {
                                          Navigator.push(context, MaterialPageRoute(
                                            builder: ((context) => ChannelScreen(
                                              models: channelObjs,
                                              topWidget: showModels[index].child
                                            ))
                                          ));
                                        }
                                      },
                                      child: ShowCard(model: showModels[index])
                                    )
                                  )
                                )
                              );
                            })
                          )
                        )
                      )
                    )
                  );
                } else {
                  return Center(child: LoadingAnimationWidget.fourRotatingDots(color: MyTheme.logoLightColor, size: 30));
                }
              }
            )
          ]
        )
      )
    );
  }
}