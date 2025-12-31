import 'package:hive_flutter/hive_flutter.dart';
import '../../models/chapter_model.dart';
import '../../../domain/entities/chapter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';

abstract class ChapterLocalDataSource {
  Future<void> saveChapter(Chapter chapter);
  Future<Chapter?> getChapter(String chapterId);
  Future<List<Chapter>> getChaptersByNovelId(String novelId);
  Future<String?> getChapterContent(String chapterId);
  Future<void> saveChapterContent(String chapterId, String content);
  Future<void> deleteChapter(String chapterId);
  Future<void> clearChaptersForNovel(String novelId);
}

class ChapterLocalDataSourceImpl implements ChapterLocalDataSource {
  late Box<ChapterModel> _chaptersBox;
  final Map<String, String> _contentCache = {};

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChapterModelAdapter());
    }
    _chaptersBox = await Hive.openBox<ChapterModel>(AppConstants.chaptersBoxName);
  }

  @override
  Future<void> saveChapter(Chapter chapter) async {
    try {
      final model = ChapterModel.fromEntity(chapter);
      await _chaptersBox.put(chapter.id, model);
      if (chapter.content.isNotEmpty) {
        _contentCache[chapter.id] = chapter.content;
      }
    } catch (e) {
      throw CacheException('Failed to save chapter: $e');
    }
  }

  @override
  Future<Chapter?> getChapter(String chapterId) async {
    try {
      final model = _chaptersBox.get(chapterId);
      if (model != null) {
        final content = _contentCache[chapterId] ?? model.content;
        return model.toEntity().copyWith(content: content);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get chapter: $e');
    }
  }

  @override
  Future<List<Chapter>> getChaptersByNovelId(String novelId) async {
    try {
      return _chaptersBox.values
          .where((model) => model.novelId == novelId)
          .map((model) {
            final content = _contentCache[model.id] ?? model.content;
            return model.toEntity().copyWith(content: content);
          })
          .toList()
        ..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
    } catch (e) {
      throw CacheException('Failed to get chapters: $e');
    }
  }

  @override
  Future<String?> getChapterContent(String chapterId) async {
    try {
      if (_contentCache.containsKey(chapterId)) {
        return _contentCache[chapterId];
      }
      final model = _chaptersBox.get(chapterId);
      return model?.content;
    } catch (e) {
      throw CacheException('Failed to get chapter content: $e');
    }
  }

  @override
  Future<void> saveChapterContent(String chapterId, String content) async {
    try {
      _contentCache[chapterId] = content;
      final model = _chaptersBox.get(chapterId);
      if (model != null) {
        await _chaptersBox.put(chapterId, model..content = content);
      }
    } catch (e) {
      throw CacheException('Failed to save chapter content: $e');
    }
  }

  @override
  Future<void> deleteChapter(String chapterId) async {
    try {
      await _chaptersBox.delete(chapterId);
      _contentCache.remove(chapterId);
    } catch (e) {
      throw CacheException('Failed to delete chapter: $e');
    }
  }

  @override
  Future<void> clearChaptersForNovel(String novelId) async {
    try {
      final keysToDelete = _chaptersBox.values
          .where((model) => model.novelId == novelId)
          .map((model) => model.id)
          .toList();
      
      for (var key in keysToDelete) {
        await _chaptersBox.delete(key);
        _contentCache.remove(key);
      }
    } catch (e) {
      throw CacheException('Failed to clear chapters: $e');
    }
  }
}

