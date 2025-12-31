class Chapter {
  final String id;
  final String novelId;
  final String title;
  final String content;
  final int chapterNumber;
  final String url;
  final DateTime? publishedDate;
  final bool isRead;
  final double readProgress;

  Chapter({
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

  Chapter copyWith({
    String? id,
    String? novelId,
    String? title,
    String? content,
    int? chapterNumber,
    String? url,
    DateTime? publishedDate,
    bool? isRead,
    double? readProgress,
  }) {
    return Chapter(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      title: title ?? this.title,
      content: content ?? this.content,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      url: url ?? this.url,
      publishedDate: publishedDate ?? this.publishedDate,
      isRead: isRead ?? this.isRead,
      readProgress: readProgress ?? this.readProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'title': title,
      'content': content,
      'chapterNumber': chapterNumber,
      'url': url,
      'publishedDate': publishedDate?.toIso8601String(),
      'isRead': isRead,
      'readProgress': readProgress,
    };
  }

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      novelId: json['novelId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      chapterNumber: json['chapterNumber'] as int,
      url: json['url'] as String,
      publishedDate: json['publishedDate'] != null
          ? DateTime.parse(json['publishedDate'] as String)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      readProgress: (json['readProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

