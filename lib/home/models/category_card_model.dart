import 'package:flutter/cupertino.dart';

class CategoryCardModel {
  int count;
  String type;
  Widget child;
  IconData data;

  CategoryCardModel({required this.data, required this.child, required this.count, required this.type});
}