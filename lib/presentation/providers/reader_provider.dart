import 'package:flutter/foundation.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/novel_repository.dart';

class ReaderProvider with ChangeNotifier {
  final NovelRepository repository;
  final List<Chapter> chapters;

  ReaderProvider({
    required this.repository,
    required this.chapters,
  });

  int _currentChapterIndex = 0;
  String _chapterContent = '';
  bool _isLoading = false;
  double _readingProgress = 0.0;

  int get currentChapterIndex => _currentChapterIndex;
  Chapter? get currentChapter => 
      _currentChapterIndex >= 0 && _currentChapterIndex < chapters.length
          ? chapters[_currentChapterIndex]
          : null;
  String get chapterContent => _chapterContent;
  bool get isLoading => _isLoading;
  double get readingProgress => _readingProgress;
  bool get hasPrevious => _currentChapterIndex > 0;
  bool get hasNext => _currentChapterIndex < chapters.length - 1;

  Future<void> loadChapterContent(int index, String novelUrl) async {
    if (index < 0 || index >= chapters.length) return;

    _isLoading = true;
    _currentChapterIndex = index;
    notifyListeners();

    try {
      final chapter = chapters[index];
      _chapterContent = await repository.getChapterContent(chapter.url, novelUrl);
      _readingProgress = (index + 1) / chapters.length;
    } catch (e) {
      _chapterContent = 'Failed to load chapter content: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNextChapter(String novelUrl) async {
    if (hasNext) {
      await loadChapterContent(_currentChapterIndex + 1, novelUrl);
    }
  }

  Future<void> loadPreviousChapter(String novelUrl) async {
    if (hasPrevious) {
      await loadChapterContent(_currentChapterIndex - 1, novelUrl);
    }
  }

  void updateReadingProgress(double progress) {
    _readingProgress = progress;
    notifyListeners();
  }
}

