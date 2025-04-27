import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softechapp/const/theme.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);
  
  void setLightMode() {
    AppTheme.setTheme(AppTheme.lightTheme);
    state = ThemeMode.light;
  }
  
  void setDarkMode() {
    AppTheme.setTheme(AppTheme.darkTheme);
    state = ThemeMode.dark;
  }
  
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setDarkMode();
    } else {
      setLightMode();
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) => ThemeNotifier()); 