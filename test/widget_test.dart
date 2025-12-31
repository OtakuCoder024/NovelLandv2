// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novel_scraper/main.dart';
import 'package:novel_scraper/presentation/providers/settings_provider.dart';
import 'package:novel_scraper/data/datasources/local/preferences_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize test dependencies
    final prefs = await SharedPreferences.getInstance();
    final preferences = PreferencesDataSourceImpl(prefs);
    final settingsProvider = SettingsProvider(preferences);
    await settingsProvider.loadSettings();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(settingsProvider: settingsProvider));

    // Verify that the app loads
    expect(find.text('Novel Scraper'), findsOneWidget);
  });
}
