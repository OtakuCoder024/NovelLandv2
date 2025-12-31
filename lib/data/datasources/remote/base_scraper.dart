import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;
import '../../../domain/entities/novel.dart';
import '../../../domain/entities/chapter.dart';
import '../../../domain/repositories/scraper_repository.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/string_utils.dart';
import '../../../core/errors/exceptions.dart';

abstract class BaseScraper implements ScraperRepository {
  final Dio dio = DioClient.create();
  final String _baseUrl;

  BaseScraper(this._baseUrl);

  @override
  bool canHandle(String url) {
    return url.contains(_baseUrl);
  }

  Future<void> delay() async {
    await Future.delayed(AppConstants.requestDelay);
  }

  String buildFullUrl(String path) {
    return StringUtils.buildFullUrl(path, 'https://$_baseUrl');
  }

  String extractIdFromUrl(String url) {
    return StringUtils.extractIdFromUrl(url);
  }

  @override
  Future<List<Novel>> searchNovels(String query) async {
    throw UnimplementedError('searchNovels must be implemented');
  }

  @override
  Future<List<Novel>> getAllNovels({int page = 1}) async {
    throw UnimplementedError('getAllNovels must be implemented');
  }

  @override
  String get siteName {
    return _baseUrl.split('/').first;
  }

  @override
  String get baseUrl => 'https://$_baseUrl';

  @override
  Future<Novel> getNovelDetails(String url) async {
    throw UnimplementedError('getNovelDetails must be implemented');
  }

  @override
  Future<List<Chapter>> getChapters(String novelUrl) async {
    throw UnimplementedError('getChapters must be implemented');
  }

  @override
  Future<String> getChapterContent(String chapterUrl) async {
    try {
      await delay();
      final response = await dio.get(chapterUrl);
      final document = html.parse(response.data);

      // Common selectors for chapter content
      final contentElement = document.querySelector(
        '.chapter-content, .chapter-text, .content, #chapter-content, [id*="content"], .text, article',
      );

      if (contentElement == null) {
        throw ScrapingException('Could not find chapter content');
      }

      // Clean up the content
      final content = StringUtils.cleanHtml(contentElement.innerHtml);
      return content;
    } catch (e) {
      throw ScrapingException('Failed to get chapter content: $e');
    }
  }
}
