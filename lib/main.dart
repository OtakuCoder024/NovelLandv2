import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/injection/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/providers/novel_provider.dart';
import 'presentation/providers/library_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/provider_browser_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependencies
  await InjectionContainer.init();
  
  // Load settings
  final settingsProvider = SettingsProvider(
    InjectionContainer.preferencesDataSource,
  );
  await settingsProvider.loadSettings();
  
  runApp(MyApp(settingsProvider: settingsProvider));
}

class MyApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const MyApp({super.key, required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NovelProvider(InjectionContainer.novelRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(InjectionContainer.novelRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProviderBrowserProvider(InjectionContainer.novelRepository),
        ),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Novel Scraper',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            home: const HomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
