import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/fav_model.dart';
import 'package:mediaplex/home/widgets/fav_card.dart';
import 'package:mediaplex/home/service/home_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  bool _reverse = true;
  List<Fav> _models = [];
  late TabController _tab;
  List<dynamic> _history = [];
  late Future<List<Fav>> _favorites;
  final HomeService _service = HomeService();

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    _favorites = _service.fetchFavs(context);
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() => _tabIndex = _tab.index));
  }

  @override
  void initState() { super.initState(); init(); }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _clearHistory() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() => _history = []);
    preferences.setString('history', '[]');
  }

  void _removeHistoryItem(dynamic model) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() => _history.removeWhere((_) => _['url'] == model.url));
    preferences.setString('history', jsonEncode(_history));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MyTheme.appBar(
      context,
      screen: 'LibraryScreen',
      bottom: TabBar(
        controller: _tab,
        tabs: const [
          Tab(text: 'History',  icon: Icon(Icons.history, color: MyTheme.secondary)),
          Tab(text: 'Favorites', icon: Icon(Icons.favorite, color: MyTheme.secondary)),
          Tab(text: 'My Media', icon: Icon(Icons.star, color: MyTheme.secondary))
        ]
      ),
      actions: [
        if (_tabIndex == 0 && _history.isNotEmpty) IconButton(
          splashRadius: 25,
          tooltip: 'Clear History',
          onPressed: _clearHistory,
          icon: const Icon(Icons.clear_all, color: Colors.red)
        ),
        if (_tabIndex == 1) IconButton(
          splashRadius: 25,
          onPressed: () => setState(() => _reverse = !_reverse),
          tooltip: _reverse ? 'Sort Older First' : 'Sort Newer First',
          icon: Icon(_reverse ? Icons.keyboard_double_arrow_down : Icons.keyboard_double_arrow_up, color: MyTheme.logoLight)
        ),
        IconButton(
          splashRadius: 25,
          tooltip: 'Upload Media',
          icon: const Icon(Icons.upload_file, color: MyTheme.logoLight),
          onPressed: () => MyTheme.showSnackBar(context, text: 'Coming soon!')
        )
      ],
      child: Expanded(child: Text('My Library', overflow: TextOverflow.ellipsis, style: MyTheme.appText()))
    ),
    body: TabBarView(
      controller: _tab,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: MyTheme.boxDecoration(),
          child: FutureBuilder<SharedPreferences>(
            future: SharedPreferences.getInstance(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Something went wrong...\nPlease try again later.', textAlign: TextAlign.center, style: MyTheme.appText(size: 20)));

              if (snapshot.hasData) { _history = jsonDecode(snapshot.data!.getString('history') ?? '[]'); }
              else { return Center(child: MyTheme.loadingAnimation()); }

              return _history.isEmpty
                ? Center(child: Text('No history found', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
                : Column(children: [
                  Text('Your last played items (max 9)', style: MyTheme.appText(size: 20, weight: FontWeight.w400)),
                  Align(
                    alignment: Alignment.topLeft,
                    child: AnimationLimiter(child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _history.length,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: ((context, index) => AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(seconds: 1),
                        child: SlideAnimation(
                          horizontalOffset: 80,
                          child: FadeInAnimation(child: FavCard(
                            index: index + 1,
                            model: Fav.fromJson(_history[index]),
                            onDelete: () => _removeHistoryItem(Fav.fromJson(_history[index]))
                          ))
                        )
                      ))
                    ))
                  )
                ]);
            }
          )
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: MyTheme.boxDecoration(),
          child: FutureBuilder<List<Fav>>(
            future: _favorites,
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Something went wrong...\nPlease try again later.', textAlign: TextAlign.center, style: MyTheme.appText(size: 20)));

              if (snapshot.hasData) {
                _models = snapshot.data!;

                return _models.isEmpty
                  ? Center(child: Text('No favorites found', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
                  : Column(children: [
                    Text('Your ${_models.length} favorite${_models.length == 1 ? '' : 's'}', style: MyTheme.appText(size: 20, weight: FontWeight.w400)),
                    Align(
                      alignment: Alignment.topLeft,
                      child: AnimationLimiter(child: ListView.builder(
                        reverse: _reverse,
                        shrinkWrap: true,
                        itemCount: _models.length,
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: ((context, index) => AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(seconds: 1),
                          child: SlideAnimation(
                            horizontalOffset: 80,
                            child: FadeInAnimation(child: FavCard(
                              index: index + 1,
                              model: _models[index],
                              onDelete: () => MyTheme.showAlertDialog(context, title: 'Remove Favorite', text: 'Do you want to remove ${_models[index].name} from your favorites?', onConfirm: () {
                                _service.deleteFav(context, model: _models[index]).then((value) {
                                  MyTheme.showSnackBar(context, text: value);
                                  setState(() => _models.remove(_models[index]));
                                }).catchError((error) {
                                  MyTheme.showError(context, text: error.toString());
                                });
                              })
                            ))
                          )
                        ))
                      ))
                    )
                  ]);
              } else { return Center(child: MyTheme.loadingAnimation()); }
            }
          )
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: MyTheme.boxDecoration(),
          child: Center(child: Text('Coming soon...', style: MyTheme.appText(size: 25, weight: FontWeight.bold)))
        )
      ]
    )
  );
}