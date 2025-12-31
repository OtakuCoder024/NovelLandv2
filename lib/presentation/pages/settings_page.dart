import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../../data/datasources/remote/scraper_factory.dart';
import '../../core/theme/reader_themes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme Settings
          _buildSectionHeader('Appearance'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeText(settings.themeMode)),
                trailing: PopupMenuButton<ThemeMode>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (ThemeMode mode) {
                    settings.setThemeMode(mode);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ThemeMode.system,
                      child: Text('System Default'),
                    ),
                    const PopupMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    const PopupMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Sync Settings
          _buildSectionHeader('Sync & Data'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return SwitchListTile(
                secondary: const Icon(Icons.sync),
                title: const Text('Enable Sync'),
                subtitle: const Text('Synchronize your library across devices'),
                value: settings.syncEnabled,
                onChanged: (value) {
                  settings.setSyncEnabled(value);
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sync enabled. Your data will be synchronized.'),
                      ),
                    );
                  }
                },
              );
            },
          ),
          
          // Scraped Sites List
          _buildSectionHeader('Supported Sites'),
          FutureBuilder<List<String>>(
            future: _getSupportedSites(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (snapshot.hasError || !snapshot.hasData) {
                return const ListTile(
                  title: Text('No sites available'),
                );
              }
              
              final sites = snapshot.data!;
              return Column(
                children: sites.map((site) {
                  return ListTile(
                    leading: const Icon(Icons.language, size: 20),
                    title: Text(
                      site,
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  );
                }).toList(),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Reader Settings
          _buildSectionHeader('Reader Settings'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Font Size'),
                subtitle: Slider(
                  value: settings.fontSize,
                  min: 12,
                  max: 30,
                  divisions: 18,
                  label: '${settings.fontSize.toInt()}',
                  onChanged: (value) {
                    settings.setFontSize(value);
                  },
                ),
                trailing: Text('${settings.fontSize.toInt()}'),
              );
            },
          ),
          
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Reader Theme'),
                subtitle: Text(settings.currentReaderTheme.name),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String theme) {
                    settings.setReaderTheme(theme);
                  },
                  itemBuilder: (context) {
                    return ReaderThemes.themeKeys.map((key) {
                      final theme = ReaderThemes.getTheme(key);
                      return PopupMenuItem(
                        value: key,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: theme.backgroundColor,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(theme.name),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              );
            },
          ),
          
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return SwitchListTile(
                secondary: const Icon(Icons.autorenew),
                title: const Text('Auto Scroll'),
                subtitle: const Text('Automatically scroll while reading'),
                value: settings.autoScroll,
                onChanged: (value) {
                  settings.setAutoScroll(value);
                },
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // App Info
          _buildSectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version'),
            subtitle: Text('1.0.0'),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Future<List<String>> _getSupportedSites() async {
    try {
      final scrapers = ScraperFactory.getAllScrapers();
      return scrapers.map((scraper) {
        // Extract site name from scraper
        final className = scraper.runtimeType.toString();
        if (className.contains('AllNovel')) return 'allnovel.org';
        if (className.contains('AnnasArchive')) return 'annas-archive.org';
        if (className.contains('BestLightNovel')) return 'bestlightnovel.com';
        if (className.contains('FreeWebNovel')) return 'freewebnovel.com';
        if (className.contains('GrayCity')) return 'graycity.net';
        if (className.contains('HiraethTranslation')) return 'hiraethtranslation.com';
        if (className.contains('IndoWebNovel')) return 'indowebnovel.id';
        if (className.contains('KolNovel')) return 'kolnovel.com';
        if (className.contains('LibRead')) return 'libread.com';
        if (className.contains('MeioNovels')) return 'meionovels.com';
        if (className.contains('RiseNovel')) return 'risenovel.com';
        if (className.contains('MtlNovels')) return 'www.mtlnovels.com';
        if (className.contains('NovelBin')) return 'novelbin.com';
        if (className.contains('NovelFull')) return 'novelfull.com';
        if (className.contains('NovelOnline')) return 'novelsonline.org';
        if (className.contains('PawRead')) return 'pawread.com';
        if (className.contains('ReadFrom')) return 'readfrom.net';
        if (className.contains('ReadNovelFull')) return 'readnovelfull.com';
        if (className.contains('RoyalRoad')) return 'www.royalroad.com';
        if (className.contains('SakuraNovel')) return 'sakuranovel.id';
        if (className.contains('ScribbleHub')) return 'www.scribblehub.com';
        if (className.contains('WtrLab')) return 'wtr-lab.com';
        return 'Unknown';
      }).where((site) => site != 'Unknown').toList();
    } catch (e) {
      return ['allnovel.org']; // Fallback to at least show one site
    }
  }
}

