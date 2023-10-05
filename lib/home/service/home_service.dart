// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import 'package:mediaplex/utils/api.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/home/models/fav_model.dart';
import 'package:mediaplex/home/models/channel_model.dart';

class HomeService {
  final ApiService _service = ApiService();

  Future<List<Channel>> fetchChannels(BuildContext context) async {
    // var streams = await apiService.getAllData('api/streams.json');
    // var channels = await apiService.getAllData('api/channels.json');
    var streams = await _service.getAll('static/streams.json', isDb: true);
    var channels = await _service.getAll('static/channels.json', isDb: true);

    if (streams.isLeft || channels.isLeft) {
      MyTheme.showError(context, text: channels.left.message! + streams.left.message!);
      return [];
    } else {
      // Add the stream url to the corresponding channel
      var response = channels.right.map((_) {
        var stream = streams.right.firstWhere((s) => s['channel'] == _['id']);
        _['url'] = stream['url'];
        return _;
      });

      return response.map(Channel.fromJson).toList();
    }
  }

  Future<List<Fav>> fetchFavs(BuildContext context) async {
    var response = await _service.getAll('fav', isDb: true);

    if (response.isLeft) {
      MyTheme.showError(context, text: response.left.message!);
      return [];
    } else { return response.right.map(Fav.fromJson).toList(); }
  }

  Future<String> deleteFav(BuildContext context, {required Fav model}) async {
    var response = await _service.delete('fav/${model.id}', isDb: true);

    if (response.isLeft) { throw 'Cannot remove ${model.toJson()["name"]} from your favorites.'; }
    else { return '${model.toJson()["name"]} was removed from your favorites.'; }
  }
}