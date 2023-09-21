class Fav {
  int? id;
  String? url;
  String? name;
  String? category;

  Fav({this.id, this.url, this.name, this.category});

  Fav.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    name = json['name'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'name': name,
    'category': category
  };
}