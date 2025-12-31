class Novel {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String sourceUrl;
  final String sourceName;
  final List<String> genres;
  final String? status;
  final DateTime? lastUpdated;
  final int? totalChapters;
  final bool isDownloaded;
  final String? downloadPath;

  Novel({
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

  Novel copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    String? sourceUrl,
    String? sourceName,
    List<String>? genres,
    String? status,
    DateTime? lastUpdated,
    int? totalChapters,
    bool? isDownloaded,
    String? downloadPath,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceName: sourceName ?? this.sourceName,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      totalChapters: totalChapters ?? this.totalChapters,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      downloadPath: downloadPath ?? this.downloadPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'sourceUrl': sourceUrl,
      'sourceName': sourceName,
      'genres': genres,
      'status': status,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'totalChapters': totalChapters,
      'isDownloaded': isDownloaded,
      'downloadPath': downloadPath,
    };
  }

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String,
      coverUrl: json['coverUrl'] as String,
      sourceUrl: json['sourceUrl'] as String,
      sourceName: json['sourceName'] as String,
      genres: List<String>.from(json['genres'] as List),
      status: json['status'] as String?,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      totalChapters: json['totalChapters'] as int?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      downloadPath: json['downloadPath'] as String?,
    );
  }
}

