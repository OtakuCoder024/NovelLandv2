import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/novel.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/entities/reading_progress.dart';
import '../../domain/repositories/novel_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/string_utils.dart';
import '../datasources/local/novel_local_datasource.dart';
import '../datasources/local/chapter_local_datasource.dart';
import '../datasources/remote/scraper_factory.dart';

class NovelRepositoryImpl implements NovelRepository {
  final NovelLocalDataSource localDataSource;
  final ChapterLocalDataSource chapterLocalDataSource;
  final ScraperFactory scraperFactory;

  NovelRepositoryImpl({
    required this.localDataSource,
    required this.chapterLocalDataSource,
    required this.scraperFactory,
  });

  @override
  Future<List<Novel>> getAllNovelsFromSite(String siteUrl, {int page = 1}) async {
    try {
      final scraper = ScraperFactory.getScraper(siteUrl);
      return await scraper.getAllNovels(page: page);
    } catch (e) {
      throw RepositoryException('Failed to get all novels from site: $e');
    }
  }

  @override
  Future<List<Novel>> searchNovels(String query, {String? sourceUrl}) async {
    try {
      if (sourceUrl != null) {
        final scraper = ScraperFactory.getScraper(sourceUrl);
        return await scraper.searchNovels(query);
      }
      
      // Search across all scrapers
      final results = <Novel>[];
      for (final scraper in ScraperFactory.getScrapersForSearch()) {
        try {
          final novels = await scraper.searchNovels(query);
          results.addAll(novels);
        } catch (e) {
          // Continue with other scrapers if one fails
          print('Scraper failed: $e');
        }
      }
      return results;
    } catch (e) {
      throw RepositoryException('Failed to search novels: $e');
    }
  }

  @override
  Future<Novel> getNovelDetails(String url) async {
    try {
      // Check cache first
      final cached = await localDataSource.getNovelByUrl(url);
      if (cached != null) {
        return cached;
      }

      // Fetch from web
      final scraper = ScraperFactory.getScraper(url);
      final novel = await scraper.getNovelDetails(url);
      
      // Cache it
      await localDataSource.saveNovel(novel);
      
      return novel;
    } catch (e) {
      throw RepositoryException('Failed to get novel details: $e');
    }
  }

  @override
  Future<List<Chapter>> getChapters(String novelUrl) async {
    try {
      final novelId = StringUtils.extractIdFromUrl(novelUrl);
      
      // Check cache
      final cached = await chapterLocalDataSource.getChaptersByNovelId(novelId);
      if (cached.isNotEmpty) {
        return cached;
      }

      // Fetch from web
      final scraper = ScraperFactory.getScraper(novelUrl);
      final chapters = await scraper.getChapters(novelUrl);
      
      // Cache chapters
      for (final chapter in chapters) {
        await chapterLocalDataSource.saveChapter(chapter);
      }
      
      return chapters;
    } catch (e) {
      throw RepositoryException('Failed to get chapters: $e');
    }
  }

  @override
  Future<String> getChapterContent(String chapterUrl, String novelUrl) async {
    try {
      final chapterId = StringUtils.extractIdFromUrl(chapterUrl);
      
      // Check if downloaded
      final downloaded = await chapterLocalDataSource.getChapterContent(chapterId);
      if (downloaded != null && downloaded.isNotEmpty) {
        return downloaded;
      }

      // Fetch from web
      final scraper = ScraperFactory.getScraper(novelUrl);
      final content = await scraper.getChapterContent(chapterUrl);
      
      // Cache content
      await chapterLocalDataSource.saveChapterContent(chapterId, content);
      
      return content;
    } catch (e) {
      throw RepositoryException('Failed to get chapter content: $e');
    }
  }

  @override
  Future<void> downloadNovel(String novelId) async {
    try {
      final novel = await localDataSource.getNovel(novelId);
      if (novel == null) throw Exception('Novel not found');

      final chapters = await getChapters(novel.sourceUrl);
      
      // Create directory
      final dir = await getApplicationDocumentsDirectory();
      final novelDir = Directory('${dir.path}/novels/$novelId');
      await novelDir.create(recursive: true);

      // Save metadata
      final metadataFile = File('${novelDir.path}/metadata.json');
      await metadataFile.writeAsString(novel.toJson().toString());

      // Download chapters
      for (final chapter in chapters) {
        final content = await getChapterContent(chapter.url, novel.sourceUrl);
        final chapterFile = File('${novelDir.path}/chapter_${chapter.chapterNumber}.txt');
        await chapterFile.writeAsString(content);
      }

      // Mark as downloaded
      final updatedNovel = novel.copyWith(
        isDownloaded: true,
        downloadPath: novelDir.path,
      );
      await localDataSource.updateNovel(updatedNovel);
    } catch (e) {
      throw RepositoryException('Failed to download novel: $e');
    }
  }

  @override
  Future<List<Novel>> getSavedNovels() async {
    try {
      return await localDataSource.getAllNovels();
    } catch (e) {
      throw RepositoryException('Failed to get saved novels: $e');
    }
  }

  @override
  Future<Novel?> getNovel(String novelId) async {
    try {
      return await localDataSource.getNovel(novelId);
    } catch (e) {
      throw RepositoryException('Failed to get novel: $e');
    }
  }

  @override
  Future<void> saveNovel(Novel novel) async {
    try {
      await localDataSource.saveNovel(novel);
    } catch (e) {
      throw RepositoryException('Failed to save novel: $e');
    }
  }

  @override
  Future<void> deleteNovel(String novelId) async {
    try {
      await localDataSource.deleteNovel(novelId);
      await chapterLocalDataSource.clearChaptersForNovel(novelId);
    } catch (e) {
      throw RepositoryException('Failed to delete novel: $e');
    }
  }

  @override
  Future<ReadingProgress?> getReadingProgress(String novelId) async {
    // This would be implemented with a reading progress datasource
    // For now, return null
    return null;
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    // This would be implemented with a reading progress datasource
    // For now, do nothing
  }
}

