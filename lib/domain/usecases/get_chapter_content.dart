import '../repositories/novel_repository.dart';

class GetChapterContent {
  final NovelRepository repository;

  GetChapterContent(this.repository);

  Future<String> call(String chapterUrl, String novelUrl) async {
    return await repository.getChapterContent(chapterUrl, novelUrl);
  }
}

