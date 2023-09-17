class SessionModel {
  String? tokenType;
  String? accessToken;

  SessionModel({this.tokenType, this.accessToken});

  SessionModel.fromJson(Map<String, dynamic> json) {
    tokenType = json['token_type'];
    accessToken = json['access_token'];
  }

  Map<String, dynamic> toJson() => {
    'token_type': tokenType,
    'access_token': accessToken
  };
}