import 'package:intl/intl.dart';

class Media {
  int? size;
  String? url;
  String? path;
  String? type;
  String? owner;
  String? createdAt;
  String? description;

  Media({required this.size, required this.url, required this.path, required this.type, required this.owner, required this.description, required this.createdAt});

  Media.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    path = json['path'];
    type = json['type'];
    size = json['size'];
    owner = json['owner'];
    description = json['description'];
    createdAt = DateFormat('MMM d, y - H:m').format(json['createdAt']);
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'path': path,
    'type': type,
    'size': size,
    'owner': owner,
    'createdAt': createdAt,
    'description': description
  };
}