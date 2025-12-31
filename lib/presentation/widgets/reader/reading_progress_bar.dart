import 'package:flutter/material.dart';

class ReadingProgressBar extends StatelessWidget {
  final double progress;
  final String? label;

  const ReadingProgressBar({
    super.key,
    required this.progress,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        LinearProgressIndicator(
          value: progress,
          minHeight: 4,
        ),
      ],
    );
  }
}

