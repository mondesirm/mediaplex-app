// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/fav_model.dart';
import 'package:mediaplex/home/ui_view/fav_card.dart';
import 'package:mediaplex/home/service/home_service.dart';

class FavScreen extends StatefulWidget {
  const FavScreen({super.key});

  @override
  State<FavScreen> createState() => _FavScreenState();
}

class _FavScreenState extends State<FavScreen> {
  HomeService service = HomeService();
  late Future<List<FavModel>> _channels;
  List<FavModel> models = [];

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    const orientations = [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ];
    SystemChrome.setPreferredOrientations(orientations);
    _channels = service.fetchFavChannels(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyTheme.appBar(context, child: Text("My Favorites", style: MyTheme.appText(size: 18, weight: FontWeight.w600))),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
                end: FractionalOffset(1.0, 0.0),
                begin: FractionalOffset(0.0, 0.0),
                colors: [MyTheme.darkBlue, MyTheme.slightBlue]
              )
            )
          ),
          FutureBuilder<List<FavModel>>(
            future: _channels,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                models = snapshot.data!;

                return models.isEmpty
                  ? Center(child: Text('No channels to watch.', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
                  : Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: AnimationLimiter(
                            child: ListView.builder(
                              itemCount: models.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: ((context, index) => AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(seconds: 1),
                                child: SlideAnimation(
                                  horizontalOffset: 80.0,
                                  child: FadeInAnimation(
                                    child: FavCard(
                                      index: index + 1,
                                      model: models[index],
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) => _buildPopupDialog(context, model: models[index]),
                                      )
                                    )
                                  )
                                )
                              ))
                            )
                          )
                        )
                      )
                    );
              } else { return Center(child: LoadingAnimationWidget.fourRotatingDots(size: 30, color: MyTheme.logoLightColor)); }
            }
          )
        ]
      )
    );
  }

  Widget _buildPopupDialog(BuildContext context, {required FavModel model}) {
    return AlertDialog(
      backgroundColor: MyTheme.slightDarkBlue,
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Do you want to remove this channel \nfrom your favorites?',
            style: MyTheme.appText(size: 15, weight: FontWeight.w500, color: MyTheme.whiteColor),
          )
        ]
      ),
      actions: <Widget>[
        SizedBox(
          width: 100,
          child: ElevatedButton(
            style: MyTheme.buttonStyle(backColor: MyTheme.logoLightColor),
            onPressed: () {
              service.deleteFavChannel(context: context, model: model).then((value) {
                final snackBar = SnackBar(
                  backgroundColor: (MyTheme.slightBlue),
                  content: Text(value, style: MyTheme.appText(size: 12, weight: FontWeight.w500))
                );

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
          child: ElevatedButton(
            style: MyTheme.buttonStyle(backColor: MyTheme.logoLightColor),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No')
          )
        )
      ]
    );
  }
}