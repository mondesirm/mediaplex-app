import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

import 'models/channel_model.dart';
import 'service/home_service.dart';
import 'widgets/category_card.dart';
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
  late Timer timer;
  // late String? lastScreen;
  HomeService service = HomeService();
  late Future<List<Channel>> _channels;
  String time = DateFormat.jm().format(DateTime.now()).toString();
  String date = DateFormat.yMMMd().format(DateTime.now()).toString();

  // void init() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   lastScreen = preferences.getString('lastScreen');
  //   if (lastScreen == null) preferences.setString('lastScreen', 'HomeScreen');
  //   if (lastScreen != 'HomeScreen') MyTheme.push(context, widget: lastScreen == 'FavScreen' ? const FavScreen() : const ProfileScreen());
  // }

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _channels = service.fetchChannels(context);
    timer = Timer.periodic(const Duration(seconds: 1), (timer) => _update());
    // init();
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
      appBar: MyTheme.appBar(context, leading: false, screen: 'HomeScreen', child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: MyTheme.appText()),
          Text(date, style: MyTheme.appText(size: 12, weight: FontWeight.w500, color: Colors.grey))
        ]
      )),
      body: Container(
        padding: const EdgeInsets.all(10),
        decoration: MyTheme.boxDecoration(),
        child: FutureBuilder<List<Channel>>(
          future: _channels,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Something went wrong...\nPlease try again later.', textAlign: TextAlign.center, style: MyTheme.appText(size: 20)));

            if (snapshot.hasData) {
              return OrientationBuilder(builder: (context, orientation) => GridView.count(
                physics: const BouncingScrollPhysics(),
                crossAxisCount: MediaQuery.sizeOf(context).width > 525 ? 3 : MediaQuery.sizeOf(context).width > 345 ? 2 : 1,
                scrollDirection: orientation == Orientation.landscape ? Axis.horizontal : Axis.vertical,
                children: List.generate(categoryCards.length, (index) {
                  List<Channel> models = [];

                  for (Channel channels in snapshot.data!) {
                    if (channels.categories!.isNotEmpty && channels.categories!.contains(categoryCards[index].type.toLowerCase())) {
                      models.add(channels);
                    }
                  }

                  categoryCards[index].count = index != 0 ? models.length : snapshot.data!.length;

                  return FadeInUp(child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: InkWell(
                      autofocus: index == 0,
                      onTap: () => MyTheme.push(
                        context,
                        name: 'livetv${index == 0 ? '' : '/${categoryCards[index].type.toLowerCase()}'}/all',
                        widget: ChannelScreen(topWidget: categoryCards[index].child, models: index == 0 ? snapshot.data! : models)
                      ),
                      onLongPress: () => MyTheme.push(
                        context,
                        name: 'livetv${index == 0 ? '' : '/${categoryCards[index].type.toLowerCase()}'}',
                        widget: SelectScreen(topWidget: categoryCards[index].child, models: index == 0 ? snapshot.data! : models)
                      ),
                      child: CategoryCard(model: categoryCards[index])
                    )
                  ));
                })
              ));
            } else { return Center(child: MyTheme.loadingAnimation()); }
          }
        )
      )
    )
  );
}