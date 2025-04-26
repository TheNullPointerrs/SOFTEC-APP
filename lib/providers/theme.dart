import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/const/theme.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(_getSystemTheme()) {
    _setSystemUIOverlayStyle(state);
  }

  static ThemeData _getSystemTheme() {
    return WidgetsBinding.instance.window.platformBrightness == Brightness.dark
        ? AppTheme.darkTheme
        : AppTheme.lightTheme;
  }

  void _setSystemUIOverlayStyle(ThemeData theme) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: theme.colorScheme.onPrimary, // Optional: Make status bar transparent
      statusBarIconBrightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarColor: theme.colorScheme.onPrimary,
      systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
    ));
  }

  void setSystemTheme() {
    final newTheme = _getSystemTheme();
    state = newTheme;
    _setSystemUIOverlayStyle(newTheme);
  }

  void toggleTheme() {
    final newTheme = state.brightness == Brightness.dark
        ? AppTheme.lightTheme
        : AppTheme.darkTheme;

    state = newTheme;
    _setSystemUIOverlayStyle(newTheme);
    AppTheme.setTheme(newTheme);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>(
  (ref) => ThemeNotifier(),
);
