import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../data/datasources/local/preferences_datasource.dart';
import '../../core/theme/reader_themes.dart';

class SettingsProvider with ChangeNotifier {
  final PreferencesDataSource preferences;

  SettingsProvider(this.preferences);

  double _fontSize = 18.0;
  String _readerTheme = 'light';
  bool _autoScroll = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _syncEnabled = false;

  double get fontSize => _fontSize;
  String get readerTheme => _readerTheme;
  bool get autoScroll => _autoScroll;
  ThemeMode get themeMode => _themeMode;
  bool get syncEnabled => _syncEnabled;
  ReaderTheme get currentReaderTheme => ReaderThemes.getTheme(_readerTheme);

  Future<void> loadSettings() async {
    _fontSize = await preferences.getFontSize();
    _readerTheme = await preferences.getReaderTheme();
    _autoScroll = await preferences.getAutoScroll();
    
    // Load theme mode
    final themeModeString = await preferences.getThemeMode();
    _themeMode = _parseThemeMode(themeModeString);
    
    // Load sync setting
    _syncEnabled = await preferences.getSyncEnabled();
    
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await preferences.setFontSize(size);
    notifyListeners();
  }

  Future<void> setReaderTheme(String theme) async {
    _readerTheme = theme;
    await preferences.setReaderTheme(theme);
    notifyListeners();
  }

  Future<void> setAutoScroll(bool enabled) async {
    _autoScroll = enabled;
    await preferences.setAutoScroll(enabled);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await preferences.setThemeMode(mode.toString());
    notifyListeners();
  }

  Future<void> setSyncEnabled(bool enabled) async {
    _syncEnabled = enabled;
    await preferences.setSyncEnabled(enabled);
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}

