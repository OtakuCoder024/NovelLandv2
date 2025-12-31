import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reader_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/reader/reading_progress_bar.dart';
import '../widgets/common/loading_indicator.dart';
import '../../../core/injection/injection_container.dart';
import '../../../domain/entities/chapter.dart';

class ReaderPage extends StatefulWidget {
  final String novelUrl;
  final List<Chapter> chapters;
  final int initialChapterIndex;

  const ReaderPage({
    super.key,
    required this.novelUrl,
    required this.chapters,
    this.initialChapterIndex = 0,
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  late ReaderProvider _readerProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _readerProvider = ReaderProvider(
      repository: InjectionContainer.novelRepository,
      chapters: widget.chapters,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readerProvider.loadChapterContent(
        widget.initialChapterIndex,
        widget.novelUrl,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showReaderSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<SettingsProvider>(
        builder: (context, settings, child) => Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Font Size: ${settings.fontSize.toInt()}'),
              Slider(
                value: settings.fontSize,
                min: 12,
                max: 30,
                onChanged: (value) {
                  settings.setFontSize(value);
                },
              ),
              // Add more settings...
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _readerProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_readerProvider.currentChapter?.title ?? 'Reading'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => _showReaderSettings(context),
            ),
          ],
        ),
        body: Consumer2<ReaderProvider, SettingsProvider>(
          builder: (context, reader, settings, child) {
            if (reader.isLoading) {
              return const LoadingIndicator(message: 'Loading chapter...');
            }

            return Column(
              children: [
                ReadingProgressBar(
                  progress: reader.readingProgress,
                  label: 'Chapter ${reader.currentChapterIndex + 1} of ${reader.chapters.length}',
                ),
                Expanded(
                  child: Container(
                    color: settings.currentReaderTheme.backgroundColor,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        reader.chapterContent,
                        style: TextStyle(
                          fontSize: settings.fontSize,
                          color: settings.currentReaderTheme.textColor,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: reader.hasPrevious
                            ? () => reader.loadPreviousChapter(widget.novelUrl)
                            : null,
                        child: const Text('Previous'),
                      ),
                      ElevatedButton(
                        onPressed: reader.hasNext
                            ? () => reader.loadNextChapter(widget.novelUrl)
                            : null,
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

