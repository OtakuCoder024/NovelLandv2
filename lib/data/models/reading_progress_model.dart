import 'package:hive/hive.dart';
import '../../domain/entities/reading_progress.dart';

part 'reading_progress_model.g.dart';

@HiveType(typeId: 2)
class ReadingProgressModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String novelId;

  @HiveField(2)
  String? currentChapterId;

  @HiveField(3)
  int currentChapterNumber;

  @HiveField(4)
  double lastReadPosition;

  @HiveField(5)
  DateTime lastReadDate;

  ReadingProgressModel({
    required this.id,
    required this.novelId,
    this.currentChapterId,
    this.currentChapterNumber = 0,
    this.lastReadPosition = 0.0,
    DateTime? lastReadDate,
  }) : lastReadDate = lastReadDate ?? DateTime.now();

  ReadingProgress toEntity() {
    return ReadingProgress(
      id: id,
      novelId: novelId,
      currentChapterId: currentChapterId,
      currentChapterNumber: currentChapterNumber,
      lastReadPosition: lastReadPosition,
      lastReadDate: lastReadDate,
    );
  }

  factory ReadingProgressModel.fromEntity(ReadingProgress progress) {
    return ReadingProgressModel(
      id: progress.id,
      novelId: progress.novelId,
      currentChapterId: progress.currentChapterId,
      currentChapterNumber: progress.currentChapterNumber,
      lastReadPosition: progress.lastReadPosition,
      lastReadDate: progress.lastReadDate,
    );
  }
}

