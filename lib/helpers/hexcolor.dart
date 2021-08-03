import 'package:flutter/material.dart';

//Changing Hex color to Color
class HexColor extends Color {
  static int _getColor(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColor(hexColor));
}
