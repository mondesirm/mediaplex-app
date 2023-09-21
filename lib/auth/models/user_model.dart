import 'package:mediaplex/home/models/fav_model.dart';

class Profile {
  int? id;
  String? email;
  String? username;
  List<Fav>? favs;

  Profile({this.id, this.favs, this.email, this.username});

  Profile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    username = json['username'];
    favs = json['favs'] != null ? (json['favs'] as List).map((i) => Fav.fromJson(i)).toList() : null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'favs': favs!.map((_) => _.toJson()).toList()
  };
}

class ChangePassword {
  String? oldPassword;
  String? newPassword;

  ChangePassword({this.oldPassword, this.newPassword});

  ChangePassword.fromJson(Map<String, dynamic> json) {
    oldPassword = json['old_password'];
    newPassword = json['new_password'];
  }

  Map<String, dynamic> toJson() => {
    'old_password': oldPassword,
    'new_password': newPassword,
  };
}

class ResetPassword {
  String? email;

  ResetPassword({this.email});

  ResetPassword.fromJson(Map<String, dynamic> json) {
    email = json['email'];
  }

  Map<String, dynamic> toJson() => {
    'email': email,
  };
}