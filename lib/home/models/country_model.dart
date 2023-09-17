class Country {
  String? name;
  String? code;

  Country({this.name, this.code});

  Country.fromString(String str) {
    name = str;
    code = str;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code
  };
}