class Category {
  String? name;
  String? slug;

  Category({this.name, this.slug});

  Category.fromString(String str) {
    name = str[0].toUpperCase() + str.substring(1);
    slug = str;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'slug': slug
  };
}