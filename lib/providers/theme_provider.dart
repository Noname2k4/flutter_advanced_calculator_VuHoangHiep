import 'package:flutter/material.dart';

class ThemeProviderApp extends ChangeNotifier {
  bool isDark = false;

  void doiTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}