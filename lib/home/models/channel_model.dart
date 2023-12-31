class Channel {
  String? url;
  String? logo;
  String? name;
  String? country;
  List<String>? languages;
  List<String>? categories;

  Channel({this.url, this.logo, this.name, this.country, this.languages, this.categories});

  Channel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    logo = json['logo'];
    name = json['name'];
    country = json['country'];
    languages = json['languages'].cast<String>();
    categories = json['categories'].cast<String>();
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'name': name,
    'category': categories!.map((_) => _[0].toUpperCase() + _.substring(1)).toList().join(' • ')
  };
}