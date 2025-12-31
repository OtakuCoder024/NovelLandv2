import '../entities/reading_progress.dart';
import '../repositories/novel_repository.dart';

class SaveReadingProgress {
  final NovelRepository repository;

  SaveReadingProgress(this.repository);

  Future<void> call(ReadingProgress progress) async {
    return await repository.saveReadingProgress(progress);
  }
}

