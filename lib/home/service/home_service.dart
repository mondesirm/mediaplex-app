// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mediaplex/common/api.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/fav_model.dart';
import 'package:mediaplex/home/models/channel_model.dart';

class HomeService {
  ApiService apiService = ApiService();

  Future<List<ChannelModel>> fetchChannels(BuildContext context) async {
    // var channels = await apiService.getAllData('api/channels.json');
    // var streams = await apiService.getAllData('api/streams.json');
    var channels = await apiService.getAllData('static/channels.json', isDb: true);
    var streams = await apiService.getAllData('static/streams.json', isDb: true);

    if (channels.isLeft || streams.isLeft) {
      MyTheme.moveToErrorPage(context: context, text: channels.left.message! + streams.left.message!);
      return [];
    } else {
      // Merge channels and streams based on channel name
      var response = channels.right.map((e) {
        var stream = streams.right.firstWhere((element) => element['channel'] == e['id']);
        e['url'] = stream['url'];
        return e;
      });

      // print(response.first);

      return response.map((e) => ChannelModel.fromJson(e)).toList();
    }

}
  Future<List<FavModel>> fetchFavChannels(BuildContext context) async {
    var response = await apiService.getAllData('fav/', isDb: true);

    if (response.isLeft) {
      MyTheme.moveToErrorPage(context: context, text: response.left.message!);
      return [];
    } else { return response.right.map((e) => FavModel.fromJson(e)).toList(); }
  }

  Future<String> deleteFavChannel({required BuildContext context, required FavModel model}) async {
    var response = await apiService.deleteData('fav/delete', model.toJson(), isDb: true);

    if (response.isLeft) { return 'Cannot delete this channel'; }
    else { return 'Removed from your favorites'; }
  }
}