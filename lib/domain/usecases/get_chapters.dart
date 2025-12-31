import '../entities/chapter.dart';
import '../repositories/novel_repository.dart';

class GetChapters {
  final NovelRepository repository;

  GetChapters(this.repository);

  Future<List<Chapter>> call(String novelUrl) async {
    return await repository.getChapters(novelUrl);
  }
}

