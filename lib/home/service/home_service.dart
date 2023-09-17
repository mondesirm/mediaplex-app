// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mediaplex/common/api.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/fav_model.dart';
import 'package:mediaplex/home/models/channel_model.dart';

class HomeService {
  ApiService apiService = ApiService();

  Future<List<ChannelModel>> fetchChannels(BuildContext context) async {
    // var streams = await apiService.getAllData('api/streams.json');
    // var channels = await apiService.getAllData('api/channels.json');
    // var countries = await apiService.getAllData('api/countries.json');
    var streams = await apiService.getAllData('static/streams.json', isDb: true);
    var channels = await apiService.getAllData('static/channels.json', isDb: true);
    // var countries = await apiService.getAllData('static/countries.json', isDb: true);

    if (streams.isLeft || channels.isLeft) {
      MyTheme.showError(context: context, text: channels.left.message! + streams.left.message!);
      return [];
    } else {
      // Merge channels and streams based on channel name
      var response = channels.right.map((_) {
        var stream = streams.right.firstWhere((s) => s['channel'] == _['id']);
        // var country = countries.right.firstWhere((c) => c['code'] == _['country']);
        _['url'] = stream['url'];
        // _['country'] = {};
        // _['country']['code'] = country['code'];
        // _['country']['name'] = country['name'];
        return _;
      });

      // print(response.first);
      return response.map((e) => ChannelModel.fromJson(e)).toList();
    }
  }

  Future<List<Fav>> fetchFavChannels(BuildContext context) async {
    var response = await apiService.getAllData('fav/', isDb: true);

    if (response.isLeft) {
      MyTheme.showError(context: context, text: response.left.message!);
      return [];
    } else { return response.right.map((e) => Fav.fromJson(e)).toList(); }
  }

  Future<String> deleteFavChannel({required BuildContext context, required Fav model}) async {
    var response = await apiService.deleteData('fav/delete', model.toJson(), isDb: true);

    if (response.isLeft) { return 'Cannot delete this channel'; }
    else { return 'Removed from your favorites'; }
  }
}