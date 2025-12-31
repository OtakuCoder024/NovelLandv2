# Flutter Novel Scraper - Development Guide

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture & Design](#architecture--design)
3. [Project Setup](#project-setup)
4. [Core Components](#core-components)
5. [Web Scraping Strategy](#web-scraping-strategy)
6. [Data Management](#data-management)
7. [UI/UX Design](#uiux-design)
8. [Platform-Specific Considerations](#platform-specific-considerations)
9. [Implementation Phases](#implementation-phases)
10. [Legal & Ethical Considerations](#legal--ethical-considerations)

---

## Project Overview

### Features
- **Multi-source scraping**: Support for 20+ novel websites
- **Cross-platform**: Mobile (Android/iOS) and Desktop (Windows/macOS/Linux)
- **Offline reading**: Download novels for offline access
- **Cloud sync**: Synchronize reading progress and library across devices
- **Reader experience**: Customizable reading interface with themes, fonts, etc.

### Tech Stack
- **Framework**: Flutter 3.x
- **State Management**: Provider or Riverpod
- **Local Database**: Hive or SQLite (via sqflite)
- **HTTP Client**: Dio or http package
- **Web Scraping**: html package + custom parsers
- **Cloud Sync**: Firebase or Supabase (optional)
- **File Storage**: path_provider, shared_preferences

---

## Architecture & Design

### Recommended Architecture: Clean Architecture + Repository Pattern

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── utils/
│   └── theme/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/ (scrapers)
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── pages/
    ├── widgets/
    └── providers/
```

### Key Design Patterns
1. **Repository Pattern**: Abstract data sources
2. **Factory Pattern**: Create scrapers for different sites
3. **Strategy Pattern**: Different scraping strategies per site
4. **Observer Pattern**: State management with Provider/Riverpod

---

## Project Setup

### 1. Initialize Flutter Project

```bash
flutter create --platforms=android,ios,windows,macos,linux novel_scraper
cd novel_scraper
```

### 2. Essential Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1
  # OR
  flutter_riverpod: ^2.4.9
  
  # HTTP & Scraping
  dio: ^5.4.0
  html: ^0.15.4
  http: ^1.1.2
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2
  
  # UI
  cached_network_image: ^3.3.0
  flutter_markdown: ^0.6.18
  webview_flutter: ^4.4.2
  
  # Utilities
  intl: ^0.18.1
  url_launcher: ^6.2.2
  share_plus: ^7.2.1
  connectivity_plus: ^5.0.2
  
  # File Operations
  archive: ^3.4.9
  path: ^1.8.3
  
  # Optional: Cloud Sync
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

### 3. Platform-Specific Setup

#### Android (android/app/build.gradle)
```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### iOS (ios/Podfile)
- Ensure minimum iOS version 12.0+

#### Desktop
- Windows: No additional setup needed
- macOS: May need entitlements for network access
- Linux: Install required libraries

---

## Core Components

### 1. Novel Entity Model

```dart
// domain/entities/novel.dart
class Novel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String sourceUrl;
  final String sourceName;
  final List<String> genres;
  final String? status;
  final DateTime? lastUpdated;
  final int? totalChapters;
}
```

### 2. Chapter Entity Model

```dart
// domain/entities/chapter.dart
class Chapter {
  final String id;
  final String novelId;
  final String title;
  final String content;
  final int chapterNumber;
  final String url;
  final DateTime? publishedDate;
}
```

### 3. Scraper Interface

```dart
// domain/repositories/scraper_repository.dart
abstract class ScraperRepository {
  Future<List<Novel>> searchNovels(String query);
  Future<Novel> getNovelDetails(String url);
  Future<List<Chapter>> getChapters(String novelUrl);
  Future<String> getChapterContent(String chapterUrl);
  bool canHandle(String url);
}
```

### 4. Scraper Factory

```dart
// data/datasources/remote/scraper_factory.dart
class ScraperFactory {
  static ScraperRepository getScraper(String url) {
    if (url.contains('allnovel.org')) return AllNovelScraper();
    if (url.contains('annas-archive.org')) return AnnasArchiveScraper();
    if (url.contains('bestlightnovel.com')) return BestLightNovelScraper();
    // ... add all scrapers
    throw UnsupportedScraperException();
  }
}
```

---

## Web Scraping Strategy

### General Approach

1. **Inspect Each Site**: Use browser DevTools to understand HTML structure
2. **Create Site-Specific Scrapers**: Each site needs custom parsing logic
3. **Handle Rate Limiting**: Implement delays and retry logic
4. **Error Handling**: Graceful degradation when sites change structure

### Scraper Implementation Template

```dart
// data/datasources/remote/allnovel_scraper.dart
class AllNovelScraper implements ScraperRepository {
  final Dio _dio = Dio();
  
  @override
  Future<List<Novel>> searchNovels(String query) async {
    try {
      final response = await _dio.get(
        'https://allnovel.org/search',
        queryParameters: {'q': query},
      );
      
      final document = parse(response.data);
      final novelElements = document.querySelectorAll('.novel-item');
      
      return novelElements.map((element) {
        return Novel(
          id: _extractId(element),
          title: _extractTitle(element),
          // ... extract other fields
        );
      }).toList();
    } catch (e) {
      throw ScrapingException('Failed to search novels: $e');
    }
  }
  
  // Implement other methods...
}
```

### Common Challenges & Solutions

1. **Dynamic Content**: Some sites use JavaScript
   - Solution: Use `webview_flutter` or headless browser (complex)
   - Alternative: Check if site has API endpoints

2. **Anti-Scraping Measures**: CAPTCHA, rate limiting
   - Solution: Respect robots.txt, add delays, use user agents

3. **Site Structure Changes**: Sites update HTML
   - Solution: Version scrapers, add fallback selectors

4. **Different Formats**: Each site has unique structure
   - Solution: Create adapter pattern for common operations

### Scraping Best Practices

- ✅ Respect `robots.txt`
- ✅ Add delays between requests (1-2 seconds)
- ✅ Use proper User-Agent headers
- ✅ Handle errors gracefully
- ✅ Cache responses when possible
- ✅ Don't overload servers

---

## Data Management

### 1. Local Database Schema

**Novels Table**
- id (primary key)
- title, author, description
- coverUrl, sourceUrl, sourceName
- genres (JSON)
- status, lastUpdated
- totalChapters
- isDownloaded, downloadPath
- createdAt, updatedAt

**Chapters Table**
- id (primary key)
- novelId (foreign key)
- title, content
- chapterNumber
- url
- isRead, readProgress
- publishedDate

**Reading Progress Table**
- id (primary key)
- novelId (foreign key)
- currentChapterId
- lastReadPosition
- lastReadDate

### 2. Using Hive for Local Storage

```dart
// Initialize Hive
await Hive.initFlutter();
Hive.registerAdapter(NovelAdapter());
Hive.registerAdapter(ChapterAdapter());

// Open boxes
final novelsBox = await Hive.openBox<Novel>('novels');
final chaptersBox = await Hive.openBox<Chapter>('chapters');
```

### 3. Offline Download Strategy

```dart
// Download novel for offline use
Future<void> downloadNovel(String novelId) async {
  final novel = await getNovel(novelId);
  final chapters = await getChapters(novelId);
  
  // Create directory
  final dir = await getApplicationDocumentsDirectory();
  final novelDir = Directory('${dir.path}/novels/$novelId');
  await novelDir.create(recursive: true);
  
  // Save novel metadata
  await saveNovelMetadata(novel, novelDir);
  
  // Download and save chapters
  for (final chapter in chapters) {
    final content = await getChapterContent(chapter.url);
    await saveChapter(chapter, content, novelDir);
  }
  
  // Mark as downloaded
  novel.isDownloaded = true;
  await updateNovel(novel);
}
```

### 4. Cloud Sync (Optional)

If implementing cloud sync:
- Store user library in Firestore/Supabase
- Sync reading progress
- Sync bookmarks and notes
- Handle conflicts (last-write-wins or merge)

---

## UI/UX Design

### Main Screens

1. **Home Screen**
   - Search bar
   - Recent novels
   - Popular/trending novels
   - Quick access to library

2. **Library Screen**
   - Downloaded novels
   - Reading progress indicators
   - Filter/sort options
   - Grid/List view toggle

3. **Novel Details Screen**
   - Cover image
   - Title, author, description
   - Genre tags
   - Chapter list
   - Download button
   - Start reading button

4. **Reader Screen**
   - Customizable text (font, size, color)
   - Background themes (light, dark, sepia)
   - Reading progress indicator
   - Chapter navigation
   - Bookmark functionality
   - Auto-scroll option

5. **Settings Screen**
   - Reader preferences
   - Download settings
   - Sync settings
   - About/Help

### UI Components to Build

- `NovelCard`: Display novel with cover and title
- `ChapterListTile`: Chapter item in list
- `ReaderView`: Customizable reading interface
- `ProgressIndicator`: Reading progress bar
- `SearchBar`: Search with debouncing
- `DownloadButton`: Show download progress

---

## Platform-Specific Considerations

### Mobile (Android/iOS)

**Permissions Needed:**
- Internet (for scraping)
- Storage (for downloads)
- Network state (for connectivity checks)

**Platform Channels:**
- Use platform channels for native file operations if needed

### Desktop (Windows/macOS/Linux)

**Window Management:**
- Support resizable windows
- Remember window size/position
- Multi-window support (optional)

**Keyboard Shortcuts:**
- Arrow keys for navigation
- Ctrl/Cmd + F for search
- Esc to close dialogs

**File Associations:**
- Open downloaded novel files
- Drag & drop support

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
- [ ] Set up Flutter project structure
- [ ] Configure dependencies
- [ ] Create data models (Novel, Chapter)
- [ ] Set up local database (Hive)
- [ ] Create basic UI structure

### Phase 2: Core Scraping (Week 3-4)
- [ ] Implement scraper interface
- [ ] Create scraper factory
- [ ] Build 2-3 scrapers (start with simpler sites)
- [ ] Test scraping functionality
- [ ] Add error handling

### Phase 3: Basic Features (Week 5-6)
- [ ] Search functionality
- [ ] Novel details page
- [ ] Chapter list view
- [ ] Basic reader view
- [ ] Library management

### Phase 4: Enhanced Features (Week 7-8)
- [ ] Offline download
- [ ] Reading progress tracking
- [ ] Reader customization (themes, fonts)
- [ ] Bookmark system
- [ ] More scrapers (add remaining sites)

### Phase 5: Polish & Optimization (Week 9-10)
- [ ] Performance optimization
- [ ] UI/UX improvements
- [ ] Error handling refinement
- [ ] Testing
- [ ] Documentation

### Phase 6: Advanced Features (Optional)
- [ ] Cloud sync
- [ ] Recommendations
- [ ] Social features (sharing, reviews)
- [ ] Advanced search filters

---

## Legal & Ethical Considerations

### ⚠️ Important Legal Notes

1. **Copyright**: Most novels are copyrighted material
   - Scraping may violate Terms of Service
   - Distribution of scraped content may be illegal
   - Consider this a personal/educational project

2. **Terms of Service**: Review each site's ToS
   - Some explicitly prohibit scraping
   - Respect robots.txt files

3. **Rate Limiting**: Don't overload servers
   - Add delays between requests
   - Implement request queuing
   - Monitor for IP bans

4. **User Responsibility**: 
   - Users should be aware of legal implications
   - Consider adding disclaimer in app

### Ethical Alternatives

- Use official APIs if available
- Partner with sites for official access
- Focus on sites that allow scraping
- Consider creating your own content platform

---

## Testing Strategy

### Unit Tests
- Test scraper parsing logic
- Test data models
- Test repository methods

### Widget Tests
- Test UI components
- Test user interactions

### Integration Tests
- Test full user flows
- Test offline functionality
- Test sync functionality

### Manual Testing Checklist
- [ ] Test on different screen sizes
- [ ] Test on all target platforms
- [ ] Test with poor network conditions
- [ ] Test offline mode
- [ ] Test error scenarios

---

## Useful Resources

### Flutter Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### Web Scraping
- [HTML Parser Package](https://pub.dev/packages/html)
- [Beautiful Soup (Python reference)](https://www.crummy.com/software/BeautifulSoup/) - for understanding scraping concepts

### State Management
- [Provider Package](https://pub.dev/packages/provider)
- [Riverpod](https://riverpod.dev/)

### Design Inspiration
- [Material Design](https://material.io/design)
- [Flutter Gallery](https://gallery.flutter.dev/)

---

## Common Pitfalls to Avoid

1. **Over-scraping**: Don't make too many requests too quickly
2. **No error handling**: Sites change, handle failures gracefully
3. **Poor state management**: Use proper state management from start
4. **Ignoring platform differences**: Test on all platforms early
5. **No offline support**: Users expect offline functionality
6. **Poor UX**: Reading experience is critical
7. **Hardcoded selectors**: Sites change HTML, make selectors configurable

---

## Getting Started Checklist

- [ ] Install Flutter SDK
- [ ] Set up IDE (VS Code or Android Studio)
- [ ] Create new Flutter project
- [ ] Add dependencies to pubspec.yaml
- [ ] Run `flutter pub get`
- [ ] Set up project structure
- [ ] Create first data model
- [ ] Build first scraper for one site
- [ ] Test scraper in isolation
- [ ] Create basic UI
- [ ] Integrate scraper with UI
- [ ] Iterate and improve!

---

## Support & Community

- Flutter Discord
- Stack Overflow (tag: flutter)
- Reddit: r/FlutterDev
- GitHub: Create issues for bugs

---

**Good luck with your project! Remember to start small, test frequently, and iterate based on user feedback.**

