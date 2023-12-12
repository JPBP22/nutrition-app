import 'package:flutter/material.dart';
import 'package:nutri_app/app_theme.dart';

// The ThemeNotifier class is a ChangeNotifier, which is a class that can be extended or mixed in.
class ThemeNotifier extends ChangeNotifier {
  bool _isDarkModeOn = false;

  ThemeData get currentTheme => _isDarkModeOn ? darkTheme : lightTheme;

  bool get isDarkModeOn => _isDarkModeOn;

  // The updateTheme method is used to update the theme of the application.
  void updateTheme(bool isDarkModeOn) {
    this._isDarkModeOn = isDarkModeOn;
    notifyListeners();
  }
}
