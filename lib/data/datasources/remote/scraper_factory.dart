import '../../../domain/repositories/scraper_repository.dart';
import '../../../core/errors/exceptions.dart';
import 'allnovel_scraper.dart';

class ScraperFactory {
  static final List<ScraperRepository> _scrapers = [
    NovelBuddyScraper(),
    // Add more scrapers here as they are implemented
  ];

  static ScraperRepository getScraper(String url) {
    for (var scraper in _scrapers) {
      if (scraper.canHandle(url)) {
        return scraper;
      }
    }
    throw UnsupportedScraperException('No scraper found for URL: $url');
  }

  static List<ScraperRepository> getAllScrapers() {
    return _scrapers;
  }

  static List<ScraperRepository> getScrapersForSearch() {
    return _scrapers;
  }
}

