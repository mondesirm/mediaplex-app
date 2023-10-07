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
    // ignore: unnecessary_lambdas
    favs = json['favs'].map((_) => Fav.fromJson(_)).toList().cast<Fav>();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
    'favs': favs!.map((_) => _.toJson()).toList()
  };
}

class ProfileUpdate {
  String? email;
  String? username;
  String? newPassword;
  String? oldPassword;

  ProfileUpdate({this.email, this.username, this.oldPassword, this.newPassword});

  ProfileUpdate.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    username = json['username'];
    newPassword = json['new_password'];
    oldPassword = json['old_password'];
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'username': username,
    'new_password': newPassword,
    'old_password': oldPassword
  };
}