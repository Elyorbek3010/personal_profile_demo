import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_strings.dart';

class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  static const String _prefKey = 'selected_language';
  String _currentLang = 'uz';

  String get currentLang => _currentLang;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString(_prefKey) ?? 'uz';
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    if (_currentLang == langCode) return;
    _currentLang = langCode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, langCode);
  }

  String t(String key) {
    return AppStrings.get(key, _currentLang);
  }
}
