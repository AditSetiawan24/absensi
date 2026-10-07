import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isNotificationEnabled = true;

  bool get isDarkMode => _isDarkMode;
  bool get isNotificationEnabled => _isNotificationEnabled;
  bool get notificationsEnabled => _isNotificationEnabled;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;
    _isNotificationEnabled = prefs.getBool(AppConstants.keyNotification) ?? true;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    await toggleDarkMode(value);
  }

  Future<void> toggleNotification(bool value) async {
    _isNotificationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotification, value);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    await toggleNotification(value);
  }
}
