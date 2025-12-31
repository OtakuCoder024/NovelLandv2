import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/library_provider.dart';
import '../widgets/novel/novel_card.dart';
import '../widgets/common/loading_indicator.dart';
import 'novel_details_page.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LibraryProvider>(context, listen: false).loadSavedNovels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<LibraryProvider>(context, listen: false).refresh();
            },
          ),
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Loading library...');
          }

          if (provider.savedNovels.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('Your library is empty'),
                  SizedBox(height: 8),
                  Text('Search for novels to add them to your library'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              itemCount: provider.savedNovels.length,
              itemBuilder: (context, index) {
                final novel = provider.savedNovels[index];
                return NovelCard(
                  novel: novel,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NovelDetailsPage(novelUrl: novel.sourceUrl),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

