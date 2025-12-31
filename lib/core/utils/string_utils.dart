import 'package:html/parser.dart' as html;

class StringUtils {
  static String cleanHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '')
        .replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), '')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String extractTextFromHtml(String htmlString) {
    final document = html.parse(htmlString);
    return document.body?.text ?? '';
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String extractIdFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    final segments = uri.pathSegments;
    return segments.isNotEmpty ? segments.last : '';
  }

  static String buildFullUrl(String path, String baseUrl) {
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }

  static List<String> extractGenres(dynamic element) {
    if (element == null) return [];
    try {
      final genreElements = element.querySelectorAll('.genre, .tag, [class*="genre"]');
      return genreElements.map((e) => e.text.trim()).where((g) => g.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }

  static int? parseChapterCount(String? text) {
    if (text == null || text.isEmpty) return null;
    final match = RegExp(r'(\d+)').firstMatch(text);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      // Try standard format first
      return DateTime.parse(dateString);
    } catch (e) {
      // Try other common formats
      try {
        // Handle formats like "Dec 30, 2024"
        final months = {
          'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
          'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
        };
        final parts = dateString.toLowerCase().split(' ');
        if (parts.length >= 3) {
          final month = months[parts[0].substring(0, 3)];
          final day = int.tryParse(parts[1].replaceAll(',', ''));
          final year = int.tryParse(parts[2]);
          if (month != null && day != null && year != null) {
            return DateTime(year, month, day);
          }
        }
      } catch (e2) {
        return null;
      }
      return null;
    }
  }
}

