class ChannelModel {
  String? url;
  String? logo;
  String? name;
  String? country;
  List<String>? languages;
  List<String>? categories;

  ChannelModel({this.url, this.logo, this.name, this.country, this.languages, this.categories});

  ChannelModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    logo = json['logo'];
    name = json['name'];
    country = json['country'];
    // languages = json['languages']! ?? [];
    // categories = json['categories']! ?? [];

    if (json['categories'] != null) {
      categories = <String>[];
      json['categories'].forEach((v) => categories!.add(v));
    }

    if (json['languages'] != null) {
      languages = <String>[];
      json['languages'].forEach((v) => languages!.add(v));
    }
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'name': name,
    'category': categories!.join(' • ')
  };
}