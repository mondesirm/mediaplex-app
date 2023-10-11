class Country {
  String? code;
  String? flag;
  String? name;
  List<String>? languages;

  Country({this.code, this.flag, this.name, this.languages});

  Country.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    flag = json['flag'];
    name = json['name'];
    languages = json['languages'];
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'flag': flag,
    'languages': languages
  };
}