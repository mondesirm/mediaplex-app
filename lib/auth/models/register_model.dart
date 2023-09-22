class Register {
  String? email;
  String? password;
  String? username;

  Register({this.email, this.password, this.username});

  Register.fromJson(Map<String, dynamic> json) {
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