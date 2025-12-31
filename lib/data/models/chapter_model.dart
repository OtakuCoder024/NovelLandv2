import 'package:hive/hive.dart';
import '../../domain/entities/chapter.dart';

part 'chapter_model.g.dart';

@HiveType(typeId: 1)
class ChapterModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String novelId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String content;

  @HiveField(4)
  int chapterNumber;

  @HiveField(5)
  String url;

  @HiveField(6)
  DateTime? publishedDate;

  @HiveField(7)
  bool isRead;

  @HiveField(8)
  double readProgress;

  ChapterModel({
    required this.id,
    required this.novelId,
    required this.title,
    required this.content,
    required this.chapterNumber,
    required this.url,
    this.publishedDate,
    this.isRead = false,
    this.readProgress = 0.0,
  });

  Chapter toEntity() {
    return Chapter(
      id: id,
      novelId: novelId,
      title: title,
      content: content,
      chapterNumber: chapterNumber,
      url: url,
      publishedDate: publishedDate,
      isRead: isRead,
      readProgress: readProgress,
    );
  }

  factory ChapterModel.fromEntity(Chapter chapter) {
    return ChapterModel(
      id: chapter.id,
      novelId: chapter.novelId,
      title: chapter.title,
      content: chapter.content,
      chapterNumber: chapter.chapterNumber,
      url: chapter.url,
      publishedDate: chapter.publishedDate,
      isRead: chapter.isRead,
      readProgress: chapter.readProgress,
    );
  }
}

