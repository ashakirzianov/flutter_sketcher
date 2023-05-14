import 'package:flutter/material.dart';

List<Color> hslaRange(
    {required HSLColor start, required HSLColor end, required int count}) {
  List<Color> colors = [];

  for (int i = 0; i < count; i++) {
    double t = i / (count - 1);
    var color = HSLColor.lerp(start, end, t);

    colors.add(color!.toColor());
  }

  return colors;
}
