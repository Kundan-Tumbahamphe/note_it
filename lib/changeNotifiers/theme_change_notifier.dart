import 'package:flutter/foundation.dart';

class ThemeChangeNotifier extends ChangeNotifier {
  bool isDarkTheme;

  ThemeChangeNotifier({this.isDarkTheme = true});

  void switchTheme() {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
  }
}
