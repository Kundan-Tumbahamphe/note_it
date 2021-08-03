import 'package:flutter/material.dart';

class Themes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFFF5F5F5),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    cursorColor: Colors.black,
    fontFamily: 'Roboto',
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Color(0xFFDCDCDC),
    ),
    buttonColor: Color(0xFF292929),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF292929),
    scaffoldBackgroundColor: Color(0xFF292929),
    cursorColor: Colors.white,
    fontFamily: 'Roboto',
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Color(0xFF454545),
    ),
    buttonColor: Color(0xFFF5F5F5),
  );
}
