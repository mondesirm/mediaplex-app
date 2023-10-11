class Language {
  String? name;
  String? code;

  Language({this.name, this.code});

  Language.fromString(String str) {
    name = str;
    code = str;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code
  };
}