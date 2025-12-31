# Recommended Project Structure

```
novel_scraper/
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_endpoints.dart
│   │   │   └── scraper_configs.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   ├── dio_client.dart
│   │   │   └── network_info.dart
│   │   ├── utils/
│   │   │   ├── string_utils.dart
│   │   │   ├── date_utils.dart
│   │   │   └── file_utils.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       └── reader_themes.dart
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   ├── novel_local_datasource.dart
│   │   │   │   ├── chapter_local_datasource.dart
│   │   │   │   └── preferences_datasource.dart
│   │   │   └── remote/
│   │   │       ├── scraper_factory.dart
│   │   │       ├── base_scraper.dart
│   │   │       ├── allnovel_scraper.dart
│   │   │       ├── annas_archive_scraper.dart
│   │   │       ├── bestlightnovel_scraper.dart
│   │   │       ├── freewebnovel_scraper.dart
│   │   │       ├── graycity_scraper.dart
│   │   │       ├── hiraethtranslation_scraper.dart
│   │   │       ├── indowebnovel_scraper.dart
│   │   │       ├── kolnovel_scraper.dart
│   │   │       ├── libread_scraper.dart
│   │   │       ├── meionovels_scraper.dart
│   │   │       ├── risenovel_scraper.dart
│   │   │       ├── mtlnovels_scraper.dart
│   │   │       ├── novelbin_scraper.dart
│   │   │       ├── novelfull_scraper.dart
│   │   │       ├── novelonline_scraper.dart
│   │   │       ├── pawread_scraper.dart
│   │   │       ├── readfrom_scraper.dart
│   │   │       ├── readnovelfull_scraper.dart
│   │   │       ├── royalroad_scraper.dart
│   │   │       ├── sakuranovel_scraper.dart
│   │   │       ├── scribblehub_scraper.dart
│   │   │       └── wtrlab_scraper.dart
│   │   ├── models/
│   │   │   ├── novel_model.dart
│   │   │   ├── chapter_model.dart
│   │   │   └── reading_progress_model.dart
│   │   └── repositories/
│   │       ├── novel_repository_impl.dart
│   │       └── chapter_repository_impl.dart
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── novel.dart
│   │   │   ├── chapter.dart
│   │   │   └── reading_progress.dart
│   │   ├── repositories/
│   │   │   ├── novel_repository.dart
│   │   │   └── chapter_repository.dart
│   │   └── usecases/
│   │       ├── search_novels.dart
│   │       ├── get_novel_details.dart
│   │       ├── get_chapters.dart
│   │       ├── get_chapter_content.dart
│   │       ├── download_novel.dart
│   │       └── save_reading_progress.dart
│   │
│   └── presentation/
│       ├── pages/
│       │   ├── home_page.dart
│       │   ├── search_page.dart
│       │   ├── library_page.dart
│       │   ├── novel_details_page.dart
│       │   ├── reader_page.dart
│       │   ├── settings_page.dart
│       │   └── downloads_page.dart
│       ├── widgets/
│       │   ├── common/
│       │   │   ├── loading_indicator.dart
│       │   │   ├── error_widget.dart
│       │   │   └── empty_state.dart
│       │   ├── novel/
│       │   │   ├── novel_card.dart
│       │   │   ├── novel_list_item.dart
│       │   │   └── novel_grid_item.dart
│       │   ├── chapter/
│       │   │   ├── chapter_list_item.dart
│       │   │   └── chapter_progress_indicator.dart
│       │   └── reader/
│       │       ├── reader_view.dart
│       │       ├── reader_settings_bottom_sheet.dart
│       │       └── reading_progress_bar.dart
│       └── providers/
│           ├── novel_provider.dart
│           ├── chapter_provider.dart
│           ├── reader_provider.dart
│           ├── library_provider.dart
│           └── settings_provider.dart
│
├── test/
│   ├── unit/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── widget/
│   └── integration/
│
├── assets/
│   ├── images/
│   └── fonts/
│
├── android/
├── ios/
├── windows/
├── macos/
├── linux/
│
├── pubspec.yaml
├── README.md
└── DEVELOPMENT_GUIDE.md
```

## Key Files Explained

### main.dart
Entry point of the application. Sets up providers, theme, and initial route.

### core/
Contains shared utilities, constants, and base classes used throughout the app.

### data/
Handles all data operations:
- **datasources/local**: Hive/SQLite operations
- **datasources/remote**: Web scraping implementations
- **models**: Data models with Hive adapters
- **repositories**: Implementation of domain repositories

### domain/
Business logic layer:
- **entities**: Pure Dart classes representing business objects
- **repositories**: Abstract interfaces
- **usecases**: Single-purpose business logic operations

### presentation/
UI layer:
- **pages**: Full screen widgets
- **widgets**: Reusable UI components
- **providers**: State management (Provider/Riverpod)

## File Naming Conventions

- **Files**: snake_case (e.g., `novel_details_page.dart`)
- **Classes**: PascalCase (e.g., `NovelDetailsPage`)
- **Variables/Functions**: camelCase (e.g., `getNovelDetails`)
- **Constants**: lowerCamelCase with `k` prefix (e.g., `kDefaultFontSize`)

## Dependency Injection Setup

Create a `di.dart` or `injection_container.dart` file:

```dart
// core/injection/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/datasources/local/novel_local_datasource.dart';
import '../data/datasources/remote/scraper_factory.dart';
import '../data/repositories/novel_repository_impl.dart';
import '../domain/repositories/novel_repository.dart';
import '../presentation/providers/novel_provider.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Data sources
  getIt.registerLazySingleton<NovelLocalDataSource>(
    () => NovelLocalDataSourceImpl(),
  );
  
  getIt.registerLazySingleton<ScraperFactory>(
    () => ScraperFactory(),
  );
  
  // Repositories
  getIt.registerLazySingleton<NovelRepository>(
    () => NovelRepositoryImpl(
      localDataSource: getIt(),
      scraperFactory: getIt(),
    ),
  );
  
  // Providers
  getIt.registerFactory<NovelProvider>(
    () => NovelProvider(getIt()),
  );
}
```

Then in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init(); // Initialize dependencies
  runApp(MyApp());
}
```

