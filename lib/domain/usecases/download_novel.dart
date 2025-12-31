import '../repositories/novel_repository.dart';

class DownloadNovel {
  final NovelRepository repository;

  DownloadNovel(this.repository);

  Future<void> call(String novelId) async {
    return await repository.downloadNovel(novelId);
  }
}

