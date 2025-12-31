import 'package:flutter/material.dart';
import 'search_page.dart';
import 'library_page.dart';
import 'settings_page.dart';
import 'provider_browser_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novel Scraper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LibraryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.explore),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProviderBrowserPage()),
              );
            },
            tooltip: 'Browse Providers',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64),
            SizedBox(height: 16),
            Text(
              'Welcome to Novel Scraper',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Search for novels or browse your library'),
          ],
        ),
      ),
    );
  }
}

