import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:animate_do/animate_do.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/fav_model.dart';
import 'package:mediaplex/home/widgets/fav_card.dart';
import 'package:mediaplex/home/service/home_service.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({super.key});

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  List<Fav> models = [];
  HomeService service = HomeService();
  late Future<List<Fav>> _channels;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _channels = service.fetchFavChannels(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyTheme.appBar(context, screen: 'FavScreen', child: Expanded(child: Text('My Favorites', overflow: TextOverflow.ellipsis, style: MyTheme.appText(size: 18)))),
      body: Stack(
        children: [
          Container(decoration: MyTheme.boxDecoration()),
          FutureBuilder<List<Fav>>(
            future: _channels,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                models = snapshot.data!;

                return models.isEmpty
                  ? Center(child: Text('No channels to watch.', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * .9,
                          child: AnimationLimiter(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: models.length,
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: ((context, index) => AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(seconds: 1),
                                child: SlideAnimation(
                                  horizontalOffset: 80,
                                  child: FadeInAnimation(
                                    child: FavCard(
                                      index: index + 1,
                                      model: models[index],
                                      onTap: () => showDialog(context: context, builder: (BuildContext context) => _buildPopupDialog(context, model: models[index]))
                                    )
                                  )
                                )
                              ))
                            )
                          )
                        )
                      )
                    );
              } else { return Center(child: LoadingAnimationWidget.fourRotatingDots(size: 30, color: MyTheme.logoLight)); }
            }
          )
        ]
      )
    );
  }

  Widget _buildPopupDialog(BuildContext context, {required Fav model}) => AlertDialog(
    backgroundColor: MyTheme.surface,
    actionsAlignment: MainAxisAlignment.spaceBetween,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    actionsPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Do you want to remove this channel \nfrom your favorites?', style: MyTheme.appText(weight: FontWeight.w500))
      ]
    ),
    actions: <Widget>[
      SizedBox(
        width: 100,
        child: ElevatedButton(
          style: MyTheme.buttonStyle(backColor: MyTheme.logoLight),
          onPressed: () {
            service.deleteFavChannel(context: context, model: model).then((value) {
              final snackBar = SnackBar(backgroundColor: (MyTheme.lightBg), content: Text(value, style: MyTheme.appText(size: 12, weight: FontWeight.w500)));

              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              setState(() => models.remove(model));
              Navigator.of(context).pop();
            });
          },
          child: const Text('Yes')
        )
      ),
      SizedBox(
        width: 100,
        child: ElevatedButton(style: MyTheme.buttonStyle(backColor: MyTheme.logoLight), onPressed: () => Navigator.of(context).pop(), child: const Text('No'))
      )
    ]
  );
}