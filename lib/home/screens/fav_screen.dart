import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool reverse = true;
  List<Fav> models = [];
  late Future<List<Fav>> _favorites;
  HomeService service = HomeService();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _favorites = service.fetchFavs(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'FavScreen',
      actions: [
        IconButton(
          splashRadius: 25,
          onPressed: () => setState(() => reverse = !reverse),
          icon: Icon(reverse ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: MyTheme.logoLight)
        )
      ],
      child: Expanded(child: Text('My Favorites', overflow: TextOverflow.ellipsis, style: MyTheme.appText()))
    ),
    body: Container(
      padding: const EdgeInsets.all(10),
      decoration: MyTheme.boxDecoration(),
      child: FutureBuilder<List<Fav>>(
        future: _favorites,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Something went wrong...\nPlease try again later.', textAlign: TextAlign.center, style: MyTheme.appText(size: 20)));

          if (snapshot.hasData) {
            models = snapshot.data!;

            return models.isEmpty
              ? Center(child: Text('No favorites found', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
              : Align(
                alignment: Alignment.topLeft,
                child: AnimationLimiter(child: ListView.builder(
                  reverse: reverse,
                  shrinkWrap: true,
                  itemCount: models.length,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: ((context, index) => AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(seconds: 1),
                    child: SlideAnimation(
                      horizontalOffset: 80,
                      child: FadeInAnimation(child: FavCard(
                        index: index + 1,
                        model: models[index],
                        onDelete: () => showDialog(context: context, builder: (BuildContext context) => _buildPopupDialog(context, model: models[index]))
                      ))
                    )
                  ))
                ))
              );
          } else { return Center(child: MyTheme.loadingAnimation()); }
        }
      )
    )
  );

  Widget _buildPopupDialog(BuildContext context, {required Fav model}) => AlertDialog(
    backgroundColor: MyTheme.surface,
    actionsAlignment: MainAxisAlignment.spaceBetween,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    actionsPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Do you want to remove this channel from your favorites?', style: MyTheme.appText(weight: FontWeight.w500))
      ]
    ),
    actions: <Widget>[
      SizedBox(
        width: 100,
        child: ElevatedButton(
          style: MyTheme.buttonStyle(),
          onPressed: () {
            service.deleteFav(context, model: model).then((value) {
              MyTheme.showSnackBar(context, text: value);
              setState(() => models.remove(model));
            }).catchError((error) {
              MyTheme.showError(context, text: error.toString());
            }).whenComplete(() => Navigator.of(context).pop());
          },
          child: const Text('Yes')
        )
      ),
      SizedBox(width: 100, child: ElevatedButton(style: MyTheme.buttonStyle(), onPressed: () => Navigator.of(context).pop(), child: const Text('No')))
    ]
  );
}