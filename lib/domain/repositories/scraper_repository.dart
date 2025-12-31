import '../entities/novel.dart';
import '../entities/chapter.dart';

abstract class ScraperRepository {
  Future<List<Novel>> searchNovels(String query);
  Future<List<Novel>> getAllNovels({int page = 1});
  Future<Novel> getNovelDetails(String url);
  Future<List<Chapter>> getChapters(String novelUrl);
  Future<String> getChapterContent(String chapterUrl);
  bool canHandle(String url);
  String get siteName;
  String get baseUrl;
}

