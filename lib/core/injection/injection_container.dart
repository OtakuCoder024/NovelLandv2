import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local/novel_local_datasource.dart';
import '../../data/datasources/local/chapter_local_datasource.dart';
import '../../data/datasources/local/preferences_datasource.dart';
import '../../data/datasources/remote/scraper_factory.dart';
import '../../data/repositories/novel_repository_impl.dart';
import '../../domain/repositories/novel_repository.dart';

class InjectionContainer {
  static NovelLocalDataSource? _novelLocalDataSource;
  static ChapterLocalDataSource? _chapterLocalDataSource;
  static PreferencesDataSource? _preferencesDataSource;
  static NovelRepository? _novelRepository;
  static ScraperFactory? _scraperFactory;

  static Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Initialize data sources
    _novelLocalDataSource = NovelLocalDataSourceImpl();
    await (_novelLocalDataSource as NovelLocalDataSourceImpl).init();

    _chapterLocalDataSource = ChapterLocalDataSourceImpl();
    await (_chapterLocalDataSource as ChapterLocalDataSourceImpl).init();

    _preferencesDataSource = PreferencesDataSourceImpl(prefs);

    // Initialize scraper factory
    _scraperFactory = ScraperFactory();

    // Initialize repository
    _novelRepository = NovelRepositoryImpl(
      localDataSource: _novelLocalDataSource!,
      chapterLocalDataSource: _chapterLocalDataSource!,
      scraperFactory: _scraperFactory!,
    );

    // Initialize default novel if library is empty
    await _initializeDefaultNovel();
  }

  static Future<void> _initializeDefaultNovel() async {
    try {
      // Check if library is empty
      final savedNovels = await _novelRepository!.getSavedNovels();
      if (savedNovels.isNotEmpty) {
        // Library already has novels, skip default initialization
        return;
      }

      // Default novel URL for testing
      const defaultNovelUrl = 'https://novelbuddy.com/novel/infinite-mana-in-the-apocalypse';
      
      print('📚 [Default Library] Initializing default novel...');
      print('📚 [Default Library] URL: $defaultNovelUrl');
      
      // Fetch and save the default novel
      final defaultNovel = await _novelRepository!.getNovelDetails(defaultNovelUrl);
      print('📚 [Default Library] Novel details fetched: ${defaultNovel.title}');
      
      // Also fetch chapters to ensure they're available
      print('📚 [Default Library] Fetching chapters...');
      final chapters = await _novelRepository!.getChapters(defaultNovelUrl);
      print('📚 [Default Library] Chapters fetched: ${chapters.length}');
      
      await _novelRepository!.saveNovel(defaultNovel);
      
      print('📚 [Default Library] Default novel initialized: ${defaultNovel.title}');
      print('📚 [Default Library] Total chapters: ${chapters.length}');
    } catch (e) {
      // If initialization fails, just log it - don't crash the app
      print('Failed to initialize default novel: $e');
    }
  }

  static NovelRepository get novelRepository => _novelRepository!;
  static NovelLocalDataSource get novelLocalDataSource => _novelLocalDataSource!;
  static ChapterLocalDataSource get chapterLocalDataSource => _chapterLocalDataSource!;
  static PreferencesDataSource get preferencesDataSource => _preferencesDataSource!;
  static ScraperFactory get scraperFactory => _scraperFactory!;
}

