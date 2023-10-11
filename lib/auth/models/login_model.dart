class Login {
  String? email;
  String? password;

  Login({this.email, this.password});

  Login.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password
  };
}