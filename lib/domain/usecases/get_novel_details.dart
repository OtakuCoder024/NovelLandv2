import '../entities/novel.dart';
import '../repositories/novel_repository.dart';

class GetNovelDetails {
  final NovelRepository repository;

  GetNovelDetails(this.repository);

  Future<Novel> call(String url) async {
    return await repository.getNovelDetails(url);
  }
}

