import 'package:hive_flutter/hive_flutter.dart';
import '../../models/novel_model.dart';
import '../../../domain/entities/novel.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';

abstract class NovelLocalDataSource {
  Future<void> saveNovel(Novel novel);
  Future<Novel?> getNovel(String novelId);
  Future<Novel?> getNovelByUrl(String url);
  Future<List<Novel>> getAllNovels();
  Future<void> updateNovel(Novel novel);
  Future<void> deleteNovel(String novelId);
  Future<void> clearAll();
}

class NovelLocalDataSourceImpl implements NovelLocalDataSource {
  late Box<NovelModel> _novelsBox;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NovelModelAdapter());
    }
    _novelsBox = await Hive.openBox<NovelModel>(AppConstants.novelsBoxName);
  }

  @override
  Future<void> saveNovel(Novel novel) async {
    try {
      final model = NovelModel.fromEntity(novel);
      await _novelsBox.put(novel.id, model);
    } catch (e) {
      throw CacheException('Failed to save novel: $e');
    }
  }

  @override
  Future<Novel?> getNovel(String novelId) async {
    try {
      final model = _novelsBox.get(novelId);
      return model?.toEntity();
    } catch (e) {
      throw CacheException('Failed to get novel: $e');
    }
  }

  @override
  Future<Novel?> getNovelByUrl(String url) async {
    try {
      for (var model in _novelsBox.values) {
        if (model.sourceUrl == url) {
          return model.toEntity();
        }
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get novel by URL: $e');
    }
  }

  @override
  Future<List<Novel>> getAllNovels() async {
    try {
      return _novelsBox.values.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw CacheException('Failed to get all novels: $e');
    }
  }

  @override
  Future<void> updateNovel(Novel novel) async {
    try {
      await saveNovel(novel);
    } catch (e) {
      throw CacheException('Failed to update novel: $e');
    }
  }

  @override
  Future<void> deleteNovel(String novelId) async {
    try {
      await _novelsBox.delete(novelId);
    } catch (e) {
      throw CacheException('Failed to delete novel: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _novelsBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear all novels: $e');
    }
  }
}

