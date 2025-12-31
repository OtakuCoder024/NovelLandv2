import '../entities/novel.dart';
import '../repositories/novel_repository.dart';

class SearchNovels {
  final NovelRepository repository;

  SearchNovels(this.repository);

  Future<List<Novel>> call(String query, {String? sourceUrl}) async {
    return await repository.searchNovels(query, sourceUrl: sourceUrl);
  }
}

