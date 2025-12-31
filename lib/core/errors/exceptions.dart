class ScrapingException implements Exception {
  final String message;
  ScrapingException(this.message);
  
  @override
  String toString() => 'ScrapingException: $message';
}

class RepositoryException implements Exception {
  final String message;
  RepositoryException(this.message);
  
  @override
  String toString() => 'RepositoryException: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class UnsupportedScraperException implements Exception {
  final String message;
  UnsupportedScraperException([this.message = 'Unsupported scraper for this URL']);
  
  @override
  String toString() => 'UnsupportedScraperException: $message';
}

