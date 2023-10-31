// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';

import 'package:mediaplex/utils/api.dart';
import 'package:mediaplex/utils/theme.dart';
import 'package:mediaplex/auth/models/user_model.dart';
import 'package:mediaplex/auth/models/login_model.dart';
import 'package:mediaplex/auth/service/auth_service.dart';

class UserService {
  final ApiService _service = ApiService();

  Future<Profile> fetchProfile(BuildContext context) async {
    var response = await _service.get('profile', isDb: true);
    return Profile.fromJson(response.isLeft ? {} : response.right);
  }

  Future<dynamic> updateProfile(BuildContext context,
      {required ProfileUpdate model}) async {
    var response = await _service.patch('profile', model.toJson(), isDb: true);

    if (response.isLeft)
      return MyTheme.showError(context, text: response.left.message!);

    await AuthService().login(context,
        model: Login(
            email: model.email,
            password: model.newPassword!.isEmpty
                ? model.oldPassword
                : model.newPassword));
    return Profile.fromJson(response.right);
  }

  Future<List<Profile>> fetchUsers(BuildContext context) async {
    
    var response = await _service.getList('user', isDb: true);
    print(response.right);
    
 
    return response.isLeft
        ? []
        : List<Profile>.from(response.right.map((e) => Profile.fromJson(e)));
  }
}
