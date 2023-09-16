import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'widgets/show_card.dart';
import 'models/channel_model.dart';
import 'service/home_service.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/utils/constants.dart';
import 'package:mediaplex/player/screens/select_screen.dart';
import 'package:mediaplex/player/screens/channel_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ignore: unused_field
  late Timer _timer;
  HomeService service = HomeService();
  late Future<List<ChannelModel>> _channels;
  String formattedTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String formattedDate = DateFormat('MMM dd, yyyy').format(DateTime.now()).toString();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _channels = service.fetchChannels(context);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _update());
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formattedTime, style: MyTheme.appText(size: 15, weight: FontWeight.w600, isShadow: true)),
              Text(formattedDate, style: MyTheme.appText(size: 11, weight: FontWeight.w500, color: Colors.white54))
            ]
          )
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [MyTheme.darkBlue, MyTheme.slightBlue])
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<ChannelModel>>(
                    future: _channels,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return Center(child: LoadingAnimationWidget.fourRotatingDots(color: MyTheme.logoLightColor, size: 30));
                      if (snapshot.hasError) return Center(child: Text(snapshot.error.toString(), style: MyTheme.appText(size: 15, weight: FontWeight.w600, color: Colors.white)));

                      return OrientationBuilder(builder: (context, orientation) => GridView.count(
                        shrinkWrap: false,
                        crossAxisCount: 2,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
                        children: List.generate(showModels.length, (index) {
                          List<ChannelModel> channelObjs = [];

                          for (ChannelModel models in snapshot.data!) {
                            if (models.categories!.isNotEmpty && models.categories![0].name == showModels[index].show_type) {
                              channelObjs.add(models);
                            }
                          }

                          showModels[index].total_channels = index != 0 ? channelObjs.length : snapshot.data!.length;

                          return FadeInUp(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                              child: GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => index == 0 || index == 1
                                  ? SelectScreen(topWidget: showModels[index].child, models: index == 0 ? snapshot.data! : channelObjs)
                                  : ChannelScreen(models: channelObjs, topWidget: showModels[index].child)
                                )),
                                child: ShowCard(model: showModels[index])
                              )
                            )
                          );
                        })
                      ));
                    }
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}