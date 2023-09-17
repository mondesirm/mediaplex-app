import 'package:flutter/cupertino.dart';

class ShowModel {
  int count;
  String type;
  Widget child;
  IconData data;

  ShowModel({required this.data, required this.child, required this.count, required this.type});
}