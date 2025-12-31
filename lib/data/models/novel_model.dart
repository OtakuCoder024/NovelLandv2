import 'package:hive/hive.dart';
import '../../domain/entities/novel.dart';

part 'novel_model.g.dart';

@HiveType(typeId: 0)
class NovelModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String author;

  @HiveField(3)
  String description;

  @HiveField(4)
  String coverUrl;

  @HiveField(5)
  String sourceUrl;

  @HiveField(6)
  String sourceName;

  @HiveField(7)
  List<String> genres;

  @HiveField(8)
  String? status;

  @HiveField(9)
  DateTime? lastUpdated;

  @HiveField(10)
  int? totalChapters;

  @HiveField(11)
  bool isDownloaded;

  @HiveField(12)
  String? downloadPath;

  NovelModel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.sourceUrl,
    required this.sourceName,
    required this.genres,
    this.status,
    this.lastUpdated,
    this.totalChapters,
    this.isDownloaded = false,
    this.downloadPath,
  });

  Novel toEntity() {
    return Novel(
      id: id,
      title: title,
      author: author,
      description: description,
      coverUrl: coverUrl,
      sourceUrl: sourceUrl,
      sourceName: sourceName,
      genres: genres,
      status: status,
      lastUpdated: lastUpdated,
      totalChapters: totalChapters,
      isDownloaded: isDownloaded,
      downloadPath: downloadPath,
    );
  }

  factory NovelModel.fromEntity(Novel novel) {
    return NovelModel(
      id: novel.id,
      title: novel.title,
      author: novel.author,
      description: novel.description,
      coverUrl: novel.coverUrl,
      sourceUrl: novel.sourceUrl,
      sourceName: novel.sourceName,
      genres: novel.genres,
      status: novel.status,
      lastUpdated: novel.lastUpdated,
      totalChapters: novel.totalChapters,
      isDownloaded: novel.isDownloaded,
      downloadPath: novel.downloadPath,
    );
  }
}

