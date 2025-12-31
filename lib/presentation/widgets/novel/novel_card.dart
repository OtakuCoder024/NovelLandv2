import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/novel.dart';

class NovelCard extends StatelessWidget {
  final Novel novel;
  final VoidCallback? onTap;

  const NovelCard({
    super.key,
    required this.novel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: novel.coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: novel.coverUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          width: 80,
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 80,
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.book),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book),
                      ),
              ),
              const SizedBox(width: 12),
              // Novel Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      novel.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      novel.author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (novel.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        novel.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (novel.genres.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: novel.genres.take(3).map((genre) {
                          return Chip(
                            label: Text(
                              genre,
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                      ),
                    ],
                    if (novel.isDownloaded)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.download, size: 16, color: Colors.green),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

