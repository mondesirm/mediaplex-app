class LoginModel {
  String? password;
  String? username;

  LoginModel({this.password, this.username});

  LoginModel.fromJson(Map<String, dynamic> json) {
    password = json['password'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() => {
    'password': password,
    'username': username
  };
}