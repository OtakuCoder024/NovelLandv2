import '../entities/novel.dart';
import '../entities/chapter.dart';
import '../entities/reading_progress.dart';

abstract class NovelRepository {
  Future<List<Novel>> searchNovels(String query, {String? sourceUrl});
  Future<List<Novel>> getAllNovelsFromSite(String siteUrl, {int page = 1});
  Future<Novel> getNovelDetails(String url);
  Future<List<Chapter>> getChapters(String novelUrl);
  Future<String> getChapterContent(String chapterUrl, String novelUrl);
  Future<void> downloadNovel(String novelId);
  Future<List<Novel>> getSavedNovels();
  Future<Novel?> getNovel(String novelId);
  Future<void> saveNovel(Novel novel);
  Future<void> deleteNovel(String novelId);
  Future<ReadingProgress?> getReadingProgress(String novelId);
  Future<void> saveReadingProgress(ReadingProgress progress);
}

