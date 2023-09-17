import 'package:mediaplex/home/models/category_model.dart';
import 'package:mediaplex/home/models/country_model.dart';
import 'package:mediaplex/home/models/languages_model.dart';

class ChannelModel {
  String? url;
  String? logo;
  String? name;
  List<Country>? countries;
  List<Language>? languages;
  List<Category>? categories;

  ChannelModel({this.url, this.logo, this.name, this.countries, this.languages, this.categories});

  ChannelModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    logo = json['logo'];
    name = json['name'];

    if (json['categories'] != null) {
      categories = <Category>[];
      json['categories'].forEach((v) => categories!.add(Category.fromString(v)));
    }

    if (json['country'] != null) {
      countries = <Country>[];
      countries!.add(Country.fromString(json['country']));
    }

    if (json['languages'] != null) {
      languages = <Language>[];
      json['languages'].forEach((v) => languages!.add(Language.fromString(v)));
    }
  }

  Map<String, dynamic> toJson() => {
    'stream_link': url,
    'category': categories![0].name,
    'channel_name': name
  };
}