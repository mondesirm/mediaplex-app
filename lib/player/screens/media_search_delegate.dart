
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/gallery.dart';
import 'package:mediaplex/player/models/media_model.dart';

class MediaSearchDelegate extends SearchDelegate<String> {
  MediaSearchDelegate(this.items);

  final List<Media> items;

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) {
    List<String> types = items.map((_) => _.type!).where((_) => _ != '').toSet().toList();
    List<Media> filtered = items.where((_) => _.path!.toLowerCase().contains(query.toLowerCase())).toList();

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: MyTheme.boxDecoration(),
      child: filtered.isEmpty ? Center(child: Text('No items found', style: MyTheme.appText(size: 25, weight: FontWeight.bold))) : AnimationLimiter(child: ListView.builder(
        shrinkWrap: true,
        itemCount: types.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(seconds: 1),
          child: filtered.where((_) => _.type == types[index]).isEmpty ? const SizedBox() : SlideAnimation(
            horizontalOffset: 80,
            child: FadeInAnimation(child: Card(
              color: MyTheme.surface,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(title: Text(types[index]), textColor: Colors.white),
                  ...filtered.where((_) => _.type == types[index]).map((_) => ListTile(
                    dense: false,
                    title: Text(_.path!),
                    textColor: Colors.white,
                    trailing: Image.network(_.url!),
                    subtitle: Text('${_.createdAt} • ${_.size} bytes'),
                    onTap: () {
                      close(context, '');
                      MyTheme.push(context, replace: true, name: 'gallery', widget: Gallery(items: items, index: items.indexOf(_)));
                    }
                  )).toList()
                ]
              )
            ))
          )
        )
      ))
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: MyTheme.darkBg,
      titleTextStyle: MyTheme.appText(size: 20, weight: FontWeight.w500)
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: MyTheme.appText(size: 15, weight: FontWeight.normal),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
    )
  );
}