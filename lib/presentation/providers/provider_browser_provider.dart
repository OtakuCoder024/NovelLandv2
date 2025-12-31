import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../../domain/entities/novel.dart';
import '../../domain/repositories/novel_repository.dart';
import '../../data/datasources/remote/scraper_factory.dart';
import '../../domain/repositories/scraper_repository.dart';

class ProviderBrowserProvider with ChangeNotifier {
  final NovelRepository repository;

  ProviderBrowserProvider(this.repository);

  ScraperRepository? _selectedProvider;
  List<Novel> _novels = [];
  List<Novel> _filteredNovels = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  String _searchQuery = '';

  ScraperRepository? get selectedProvider => _selectedProvider;
  List<Novel> get novels => _filteredNovels;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;
  String get searchQuery => _searchQuery;

  List<ScraperRepository> get availableProviders {
    return ScraperFactory.getAllScrapers();
  }

  Future<void> selectProvider(ScraperRepository? provider) async {
    if (provider == null) {
      clearProvider();
      return;
    }

    _selectedProvider = provider;
    _novels = [];
    _filteredNovels = [];
    _currentPage = 1;
    _hasMorePages = true;
    _searchQuery = '';
    _error = null;
    notifyListeners();

    await loadNovels();
  }

  void clearProvider() {
    _selectedProvider = null;
    _novels = [];
    _filteredNovels = [];
    _currentPage = 1;
    _hasMorePages = true;
    _searchQuery = '';
    _error = null;
    notifyListeners();
  }

  Future<void> loadNovels({bool loadMore = false}) async {
    if (_selectedProvider == null) return;

    if (loadMore) {
      if (!_hasMorePages || _isLoadingMore) return;
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _currentPage = 1;
      _novels = [];
      _hasMorePages = true;
    }

    _error = null;
    notifyListeners();

    try {
      final page = loadMore ? _currentPage + 1 : 1;
      final newNovels = await repository.getAllNovelsFromSite(
        _selectedProvider!.baseUrl,
        page: page,
      );

      if (loadMore) {
        _novels.addAll(newNovels);
        _currentPage = page;
      } else {
        _novels = newNovels;
        _currentPage = 1;
      }

      // Check if there are more pages (if we got fewer novels than expected, might be last page)
      _hasMorePages = newNovels.isNotEmpty;

      // Apply search filter if active
      _applySearchFilter();

      _error = null;
    } catch (e) {
      _error = 'Failed to load novels: ${e.toString()}';
      if (!loadMore) {
        _novels = [];
      }
      // Log error for debugging
      debugPrint('Error loading novels: $e');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void searchNovels(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applySearchFilter();
    notifyListeners();
  }

  void _applySearchFilter() {
    if (_searchQuery.isEmpty) {
      _filteredNovels = _novels;
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredNovels = _novels.where((novel) {
        return novel.title.toLowerCase().contains(query) ||
            novel.author.toLowerCase().contains(query) ||
            novel.description.toLowerCase().contains(query) ||
            novel.genres.any((genre) => genre.toLowerCase().contains(query));
      }).toList();
    }
  }

  Future<void> refresh() async {
    await loadNovels();
  }

  Future<void> loadMore() async {
    if (_searchQuery.isEmpty) {
      await loadNovels(loadMore: true);
    }
  }
}

