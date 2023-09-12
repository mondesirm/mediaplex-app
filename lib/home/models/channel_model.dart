import 'package:mediaplex/home/models/categories_model.dart';
import 'package:mediaplex/home/models/countries_model.dart';
import 'package:mediaplex/home/models/languages_model.dart';

class ChannelModel {
  String? name;
  String? logo;
  String? url;
  List<Category>? categories;
  List<Country>? countries;
  List<Language>? languages;

  ChannelModel({this.name, this.logo, this.url, this.categories, this.countries, this.languages});

  ChannelModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    logo = json['logo'];
    url = json['url'];
    if (json['categories'] != null) {
      categories = <Category>[];
      json['categories'].forEach((v) {
        categories!.add(Category.fromString(v));
      });
    }
    if (json['country'] != null) {
      countries = <Country>[];
      countries!.add(Country.fromString(json['country']));
    }

    if (json['languages'] != null) {
      languages = <Language>[];
      json['languages'].forEach((v) {
        languages!.add(Language.fromString(v));
      });
    }
  }

  Map<String, dynamic> toJson() => {
    'stream_link': url,
    'category': categories![0].name,
    'channel_name': name
  };
}