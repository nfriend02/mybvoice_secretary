import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Switches the whole app between the night and day palettes.
class ThemeController extends ChangeNotifier {
  bool get dark => AppTheme.dark;

  void toggle() {
    AppTheme.dark = !AppTheme.dark;
    notifyListeners();
  }
}
