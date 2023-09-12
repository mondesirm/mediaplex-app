// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:mediaplex/home/models/channel_model.dart';
import 'package:mediaplex/common/api.dart';

class PlayerService {
  ApiService _service = ApiService();

  Future<String> addToFav({required BuildContext context, required ChannelModel model}) async {
    var response = await _service.postHeaderData('fav/add', model.toJson(), isDb: true);

    if (response.isLeft) return 'This channel is already in your favorites.';
    return 'Added to favorites';
  }
}