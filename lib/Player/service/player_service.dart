import 'package:flutter/material.dart';

import 'package:mediaplex/utils/api.dart';
import 'package:mediaplex/home/models/channel_model.dart';

class PlayerService {
  final ApiService _service = ApiService();

  Future<String> addFav(BuildContext context, {required Channel model}) async {
    var response = await _service.post('fav', model.toJson(), isDb: true);

    if (response.isLeft) return '${model.toJson()["name"]} is already in your favorites.';
    return '${model.toJson()["name"]} was added to your favorites.';
  }
}