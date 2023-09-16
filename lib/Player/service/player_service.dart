import 'package:flutter/material.dart';

import 'package:mediaplex/common/api.dart';
import 'package:mediaplex/home/models/channel_model.dart';

class PlayerService {
  final ApiService _service = ApiService();

  Future<String> addToFav({required BuildContext context, required ChannelModel model}) async {
    var response = await _service.postHeaderData('fav/add', model.toJson(), isDb: true);

    if (response.isLeft) return '${model.toJson()["channel_name"]} is already in your favorites.';
    return '${model.toJson()["channel_name"]} was added to your favorites.';
  }
}