class Fav {
  String? url;
  String? name;
  String? category;

  Fav({this.url, this.name, this.category});

  Fav.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    name = json['name'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'name': name,
    'category': category
  };
}