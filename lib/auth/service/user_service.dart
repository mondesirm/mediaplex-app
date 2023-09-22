// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import 'package:mediaplex/utils/api.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/auth/models/user_model.dart';

class UserService {
  final ApiService _service = ApiService();

  Future<Profile> fetchProfile(BuildContext context) async {
    var response = await _service.get('profile', isDb: true);
    return Profile.fromJson(response.isLeft ? {} : response.right);
  }

  Future<dynamic> updateProfile(BuildContext context, {required ProfileUpdate model}) async {
    var response = await _service.patch('profile', model.toJson(), isDb: true);

    if (response.isLeft) return MyTheme.showError(context, text: response.left.message!);
    return Profile.fromJson(response.right);
  }
}