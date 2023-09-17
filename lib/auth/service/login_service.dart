// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediaplex/common/api.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/auth/models/login_model.dart';
import 'package:mediaplex/auth/models/session_model.dart';

class LoginService {
  final ApiService _service = ApiService();

  Future<dynamic> loginUser({required LoginModel model, required BuildContext context}) async {
    var response = await _service.postData('login/', model.toJson(), isDb: true);

    if (response.isLeft) return MyTheme.showError(context: context, text: response.left.message!);

    SessionModel token = SessionModel.fromJson(response.right);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('session', token.accessToken!);
    return token;
  }
}