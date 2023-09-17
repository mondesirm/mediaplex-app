class Fav {
  String? streamLink;
  String? category;
  String? channelName;

  Fav({this.streamLink, this.category, this.channelName});

  Fav.fromJson(Map<String, dynamic> json) {
    streamLink = json['stream_link'];
    category = json['category'];
    channelName = json['channel_name'];
  }

  Map<String, dynamic> toJson() => {
    'stream_link': streamLink,
    'category': category,
    'channel_name': channelName
  };
}