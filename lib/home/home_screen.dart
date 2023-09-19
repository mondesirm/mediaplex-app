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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  late Timer _timer;
  HomeService service = HomeService();
  late Future<List<ChannelModel>> _channels;
  String time = DateFormat.jm().format(DateTime.now()).toString();
  String date = DateFormat.yMMMd().format(DateTime.now()).toString();

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
      time = DateFormat.jm().format(DateTime.now()).toString();
      date = DateFormat.yMMMd().format(DateTime.now()).toString();
    });
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async => false,
    child: Scaffold(
      appBar: MyTheme.appBar(context, leading: false, child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: MyTheme.appText()),
          Text(date, style: MyTheme.appText(size: 12, weight: FontWeight.w500, color: Colors.grey))
        ]
      )),
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: MyTheme.boxDecoration(),
        child: Column(children: [
          Expanded(child: FutureBuilder<List<ChannelModel>>(
            future: _channels,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text(snapshot.error.toString(), style: MyTheme.appText(size: 20)));
              if (snapshot.hasError) return Center(child: Text('Something went wrong...', style: MyTheme.appText(size: 20)));

              if (snapshot.hasData) {
                return OrientationBuilder(builder: (context, orientation) => GridView.count(
                  shrinkWrap: false,
                  physics: const BouncingScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).size.width > 525 ? 3 : MediaQuery.of(context).size.width > 345 ? 2 : 1,
                  scrollDirection: orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
                  children: List.generate(showModels.length, (index) {
                    List<ChannelModel> channelObjs = [];

                    for (ChannelModel models in snapshot.data!) {
                      if (models.categories!.isNotEmpty && models.categories!.contains(showModels[index].type.toLowerCase())) {
                        channelObjs.add(models);
                      }
                    }

                    showModels[index].count = index != 0 ? channelObjs.length : snapshot.data!.length;

                    return FadeInUp(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: GestureDetector(
                          onTap: () => MyTheme.push(context, widget: index == 0 || index == 1
                            ? SelectScreen(topWidget: showModels[index].child, models: index == 0 ? snapshot.data! : channelObjs)
                            : ChannelScreen(models: channelObjs, topWidget: showModels[index].child)
                          ),
                          child: ShowCard(model: showModels[index])
                        )
                      )
                    );
                  })
                ));
              } else { return Center(child: LoadingAnimationWidget.fourRotatingDots(size: 30, color: MyTheme.logoLight)); }
            }
          ))
        ])
      )
    )
  );
}