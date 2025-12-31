class AppConstants {
  // App Info
  static const String appName = 'Novel Scraper';
  static const String appVersion = '1.0.0';
  
  // Rate Limiting
  static const Duration requestDelay = Duration(seconds: 1);
  static const int maxRetries = 3;
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // User Agent
  static const String userAgent = 
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
  
  // Storage
  static const String novelsBoxName = 'novels';
  static const String chaptersBoxName = 'chapters';
  static const String progressBoxName = 'reading_progress';
  
  // Reader Settings
  static const double minFontSize = 12.0;
  static const double maxFontSize = 30.0;
  static const double defaultFontSize = 18.0;
}

