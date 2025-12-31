import 'package:flutter/foundation.dart';
import '../../domain/entities/novel.dart';
import '../../domain/entities/chapter.dart';
import '../../domain/repositories/novel_repository.dart';

class NovelProvider with ChangeNotifier {
  final NovelRepository repository;

  NovelProvider(this.repository);

  List<Novel> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  List<Novel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;

  Future<void> searchNovels(String query, {String? sourceUrl}) async {
    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await repository.searchNovels(query, sourceUrl: sourceUrl);
      _searchError = null;
    } catch (e) {
      _searchError = 'Failed to search: ${e.toString()}';
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Novel? _selectedNovel;
  List<Chapter> _chapters = [];
  bool _isLoadingChapters = false;

  Novel? get selectedNovel => _selectedNovel;
  List<Chapter> get chapters => _chapters;
  bool get isLoadingChapters => _isLoadingChapters;

  Future<void> loadNovelDetails(String url) async {
    _isLoadingChapters = true;
    notifyListeners();

    try {
      _selectedNovel = await repository.getNovelDetails(url);
      _chapters = await repository.getChapters(url);
    } catch (e) {
      _searchError = 'Failed to load novel: ${e.toString()}';
    } finally {
      _isLoadingChapters = false;
      notifyListeners();
    }
  }

  Future<void> downloadNovel(String novelId) async {
    try {
      await repository.downloadNovel(novelId);
      // Refresh novel details
      if (_selectedNovel?.id == novelId) {
        final updated = await repository.getNovel(novelId);
        if (updated != null) {
          _selectedNovel = updated;
          notifyListeners();
        }
      }
    } catch (e) {
      _searchError = 'Failed to download: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchError = null;
    notifyListeners();
  }
}

