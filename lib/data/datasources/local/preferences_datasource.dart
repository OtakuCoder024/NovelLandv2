import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

abstract class PreferencesDataSource {
  Future<double> getFontSize();
  Future<void> setFontSize(double size);
  Future<String> getReaderTheme();
  Future<void> setReaderTheme(String theme);
  Future<bool> getAutoScroll();
  Future<void> setAutoScroll(bool enabled);
  Future<String> getThemeMode();
  Future<void> setThemeMode(String mode);
  Future<bool> getSyncEnabled();
  Future<void> setSyncEnabled(bool enabled);
}

class PreferencesDataSourceImpl implements PreferencesDataSource {
  final SharedPreferences _prefs;

  PreferencesDataSourceImpl(this._prefs);

  @override
  Future<double> getFontSize() async {
    return _prefs.getDouble('font_size') ?? AppConstants.defaultFontSize;
  }

  @override
  Future<void> setFontSize(double size) async {
    await _prefs.setDouble('font_size', size);
  }

  @override
  Future<String> getReaderTheme() async {
    return _prefs.getString('reader_theme') ?? 'light';
  }

  @override
  Future<void> setReaderTheme(String theme) async {
    await _prefs.setString('reader_theme', theme);
  }

  @override
  Future<bool> getAutoScroll() async {
    return _prefs.getBool('auto_scroll') ?? false;
  }

  @override
  Future<void> setAutoScroll(bool enabled) async {
    await _prefs.setBool('auto_scroll', enabled);
  }

  @override
  Future<String> getThemeMode() async {
    return _prefs.getString('theme_mode') ?? 'ThemeMode.system';
  }

  @override
  Future<void> setThemeMode(String mode) async {
    await _prefs.setString('theme_mode', mode);
  }

  @override
  Future<bool> getSyncEnabled() async {
    return _prefs.getBool('sync_enabled') ?? false;
  }

  @override
  Future<void> setSyncEnabled(bool enabled) async {
    await _prefs.setBool('sync_enabled', enabled);
  }
}

