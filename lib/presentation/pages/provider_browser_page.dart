import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/provider_browser_provider.dart';
import '../widgets/novel/novel_card.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_widget.dart';
import 'novel_details_page.dart';

class ProviderBrowserPage extends StatefulWidget {
  const ProviderBrowserPage({super.key});

  @override
  State<ProviderBrowserPage> createState() => _ProviderBrowserPageState();
}

class _ProviderBrowserPageState extends State<ProviderBrowserPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Load more when user scrolls to 80% of the list
      final provider = Provider.of<ProviderBrowserProvider>(context, listen: false);
      if (provider.hasMorePages && !provider.isLoadingMore) {
        provider.loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Providers'),
      ),
      body: Consumer<ProviderBrowserProvider>(
        builder: (context, provider, child) {
          if (provider.selectedProvider == null) {
            return _buildProviderSelection(provider);
          }

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search novels...',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.clearSearch();
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          provider.searchNovels(value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        provider.clearProvider();
                      },
                      tooltip: 'Back to providers',
                    ),
                  ],
                ),
              ),

              // Provider Info
              if (provider.selectedProvider != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    children: [
                      const Icon(Icons.language, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Browsing: ${provider.selectedProvider!.siteName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      if (provider.isLoadingMore)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),

              // Content
              Expanded(
                child: _buildNovelList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProviderSelection(ProviderBrowserProvider provider) {
    final providers = provider.availableProviders;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Select a Provider',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a provider to browse all available novels',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 24),
        ...providers.map((scraper) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(
                  scraper.siteName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                scraper.siteName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(scraper.baseUrl),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                provider.selectProvider(scraper);
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildNovelList(ProviderBrowserProvider provider) {
    if (provider.isLoading && provider.novels.isEmpty) {
      return const LoadingIndicator(message: 'Loading novels...');
    }

    if (provider.error != null && provider.novels.isEmpty) {
      return ErrorDisplay(
        message: '${provider.error!}\n\nTip: The website structure may have changed. Try refreshing or check if the site is accessible.',
        onRetry: () => provider.refresh(),
      );
    }

    if (provider.novels.isEmpty && !provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              provider.searchQuery.isNotEmpty
                  ? 'No novels found matching your search'
                  : provider.error != null
                      ? 'No novels available. ${provider.error}'
                      : 'No novels available. The website structure may have changed.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (provider.searchQuery.isNotEmpty) ...[
              ElevatedButton(
                onPressed: () => provider.clearSearch(),
                child: const Text('Clear Search'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => provider.refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: provider.novels.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.novels.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final novel = provider.novels[index];
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
  }
}

