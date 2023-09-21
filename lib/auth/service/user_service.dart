// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediaplex/common/api.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/auth/models/user_model.dart';
import 'package:mediaplex/auth/models/session_model.dart';

class UserService {
  final ApiService _service = ApiService();

  Future<Profile> fetchProfile(BuildContext context) async {
    var response = await _service.get('profile', isDb: true);

    if (response.isLeft) {
      MyTheme.showError(context, text: response.left.message!);
      return Profile.fromJson({});
    } else { return Profile.fromJson(response.right); }
  }

  Future<dynamic> update(BuildContext context, {required Profile model}) async {
    var response = await _service.patch('profile', model.toJson(), isDb: true);

    if (response.isLeft) return MyTheme.showError(context, text: response.left.message!);

    SessionModel token = SessionModel.fromJson(response.right);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('token', token.accessToken!);
    return token;
  }
}