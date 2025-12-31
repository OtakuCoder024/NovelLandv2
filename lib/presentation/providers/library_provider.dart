import 'package:flutter/foundation.dart';
import '../../domain/entities/novel.dart';
import '../../domain/repositories/novel_repository.dart';

class LibraryProvider with ChangeNotifier {
  final NovelRepository repository;

  LibraryProvider(this.repository);

  List<Novel> _savedNovels = [];
  bool _isLoading = false;

  List<Novel> get savedNovels => _savedNovels;
  bool get isLoading => _isLoading;

  Future<void> loadSavedNovels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _savedNovels = await repository.getSavedNovels();
    } catch (e) {
      print('Failed to load saved novels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNovel(String novelId) async {
    try {
      await repository.deleteNovel(novelId);
      _savedNovels.removeWhere((novel) => novel.id == novelId);
      notifyListeners();
    } catch (e) {
      print('Failed to delete novel: $e');
    }
  }

  Future<void> refresh() async {
    await loadSavedNovels();
  }
}

