class ReadingProgress {
  final String id;
  final String novelId;
  final String? currentChapterId;
  final int currentChapterNumber;
  final double lastReadPosition;
  final DateTime lastReadDate;

  ReadingProgress({
    required this.id,
    required this.novelId,
    this.currentChapterId,
    this.currentChapterNumber = 0,
    this.lastReadPosition = 0.0,
    DateTime? lastReadDate,
  }) : lastReadDate = lastReadDate ?? DateTime.now();

  ReadingProgress copyWith({
    String? id,
    String? novelId,
    String? currentChapterId,
    int? currentChapterNumber,
    double? lastReadPosition,
    DateTime? lastReadDate,
  }) {
    return ReadingProgress(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      currentChapterId: currentChapterId ?? this.currentChapterId,
      currentChapterNumber: currentChapterNumber ?? this.currentChapterNumber,
      lastReadPosition: lastReadPosition ?? this.lastReadPosition,
      lastReadDate: lastReadDate ?? this.lastReadDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'currentChapterId': currentChapterId,
      'currentChapterNumber': currentChapterNumber,
      'lastReadPosition': lastReadPosition,
      'lastReadDate': lastReadDate.toIso8601String(),
    };
  }

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      id: json['id'] as String,
      novelId: json['novelId'] as String,
      currentChapterId: json['currentChapterId'] as String?,
      currentChapterNumber: json['currentChapterNumber'] as int? ?? 0,
      lastReadPosition: (json['lastReadPosition'] as num?)?.toDouble() ?? 0.0,
      lastReadDate: DateTime.parse(json['lastReadDate'] as String),
    );
  }
}

