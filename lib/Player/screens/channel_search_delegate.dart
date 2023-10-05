
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'channels_screen.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/player/player.dart';
import 'package:mediaplex/home/models/channel_model.dart';

class ChannelSearchDelegate extends SearchDelegate<String> {
  ChannelSearchDelegate(this.title, this.countries, this.channels);

  final Widget title;
  final List<String> countries;
  final List<Channel> channels;

  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];

  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));

  @override
  Widget buildResults(BuildContext context) {
    List<Channel> filtered = channels.where((_) => _.name!.toLowerCase().contains(query.toLowerCase())).toList();

    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: MyTheme.boxDecoration(),
      child: AnimationLimiter(child: ListView.builder(
        shrinkWrap: true,
        itemCount: countries.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(seconds: 1),
          child: SlideAnimation(
            horizontalOffset: 80,
            child: FadeInAnimation(child: Card(
              color: MyTheme.surface,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(countries[index]),
                    textColor: Colors.white,
                    trailing: ElevatedButton(
                      style: MyTheme.buttonStyle(bgColor: Colors.greenAccent),
                      child: Text('View Channels', style: MyTheme.appText(color: MyTheme.surface, weight: FontWeight.w500)),
                      onPressed: () {
                        close(context, '');
                        MyTheme.push(
                          context,
                          name: 'livetv/${countries[index].toLowerCase()}',
                          widget: ChannelsScreen(
                            models: channels.where((_) => _.country == countries[index]).toList(),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                title,
                                const SizedBox(width: 5),
                                Text(countries[index], style: MyTheme.appText(size: 14, weight: FontWeight.w500, color: MyTheme.logoDark))
                              ]
                            )
                          )
                        );
                      }
                    )
                  ),
                  ...filtered.where((_) => _.country == countries[index]).map((_) => ListTile(
                    dense: false,
                    title: Text(_.name!),
                    textColor: Colors.white,
                    trailing: Image.network(_.logo!),
                    subtitle: Text('${_.categories!.join(' • ')} | ${_.languages!.join(' • ')}'),
                    onTap: () {
                      close(context, '');
                      MyTheme.push(context, widget: Player(model: _));
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