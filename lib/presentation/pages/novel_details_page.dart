import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/novel_provider.dart';
import '../widgets/chapter/chapter_list_item.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/error_widget.dart';
import 'reader_page.dart';

class NovelDetailsPage extends StatefulWidget {
  final String novelUrl;

  const NovelDetailsPage({super.key, required this.novelUrl});

  @override
  State<NovelDetailsPage> createState() => _NovelDetailsPageState();
}

class _NovelDetailsPageState extends State<NovelDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NovelProvider>(context, listen: false)
          .loadNovelDetails(widget.novelUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NovelProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingChapters) {
            return const LoadingIndicator(message: 'Loading novel details...');
          }

          if (provider.searchError != null && provider.selectedNovel == null) {
            return ErrorDisplay(
              message: provider.searchError!,
              onRetry: () {
                provider.loadNovelDetails(widget.novelUrl);
              },
            );
          }

          final novel = provider.selectedNovel;
          if (novel == null) {
            return const Center(child: Text('Novel not found'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(novel.title),
                  background: novel.coverUrl.isNotEmpty
                      ? Image.network(
                          novel.coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.book),
                        )
                      : const Icon(Icons.book),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'By ${novel.author}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (novel.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(novel.description),
                      ],
                      if (novel.genres.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: novel.genres.map((genre) {
                            return Chip(label: Text(genre));
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              provider.downloadNovel(novel.id);
                            },
                            icon: const Icon(Icons.download),
                            label: Text(novel.isDownloaded ? 'Downloaded' : 'Download'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: provider.chapters.isNotEmpty
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReaderPage(
                                          novelUrl: novel.sourceUrl,
                                          chapters: provider.chapters,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.book),
                            label: const Text('Start Reading'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chapters (${provider.chapters.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.chapters.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No chapters available')),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = provider.chapters[index];
                      return ChapterListItem(
                        chapter: chapter,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReaderPage(
                                novelUrl: novel.sourceUrl,
                                chapters: provider.chapters,
                                initialChapterIndex: index,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: provider.chapters.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

