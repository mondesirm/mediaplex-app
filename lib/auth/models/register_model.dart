class RegisterModel {
  String? email;
  String? password;
  String? username;

  RegisterModel({this.email, this.password, this.username});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'username': username
  };
}