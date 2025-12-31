import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/novel_provider.dart';
import '../widgets/novel/novel_card.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_widget.dart';
import 'novel_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;
    
    final provider = Provider.of<NovelProvider>(context, listen: false);
    provider.searchNovels(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Novels'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search novels...',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<NovelProvider>(context, listen: false).clearSearch();
                  },
                ),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: Consumer<NovelProvider>(
              builder: (context, provider, child) {
                if (provider.isSearching) {
                  return const LoadingIndicator(message: 'Searching...');
                }

                if (provider.searchError != null) {
                  return ErrorDisplay(
                    message: provider.searchError!,
                    onRetry: () => _performSearch(_searchController.text),
                  );
                }

                if (provider.searchResults.isEmpty) {
                  return const Center(
                    child: Text('No results found. Try searching for a novel.'),
                  );
                }

                return ListView.builder(
                  itemCount: provider.searchResults.length,
                  itemBuilder: (context, index) {
                    final novel = provider.searchResults[index];
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

