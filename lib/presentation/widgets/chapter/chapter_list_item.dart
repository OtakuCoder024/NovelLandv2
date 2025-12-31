import 'package:flutter/material.dart';
import '../../../domain/entities/chapter.dart';

class ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback? onTap;
  final bool isRead;

  const ChapterListItem({
    super.key,
    required this.chapter,
    this.onTap,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text('${chapter.chapterNumber}'),
      ),
      title: Text(
        chapter.title,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          color: isRead ? Colors.grey : null,
        ),
      ),
      subtitle: chapter.publishedDate != null
          ? Text(
              '${chapter.publishedDate!.day}/${chapter.publishedDate!.month}/${chapter.publishedDate!.year}',
            )
          : null,
      trailing: isRead ? const Icon(Icons.check_circle, color: Colors.green) : null,
      onTap: onTap,
    );
  }
}

