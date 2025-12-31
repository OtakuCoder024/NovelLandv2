import 'package:html/parser.dart' as html;
import 'package:html/dom.dart';
import '../../../domain/entities/novel.dart';
import '../../../domain/entities/chapter.dart';
import '../../../core/utils/string_utils.dart';
import '../../../core/errors/exceptions.dart';
import 'base_scraper.dart';

class NovelBuddyScraper extends BaseScraper {
  NovelBuddyScraper() : super('novelbuddy.com');

  @override
  Future<List<Novel>> getAllNovels({int page = 1}) async {
    try {
      await delay();

      // NovelBuddy uses /home for the main page
      String url = 'https://novelbuddy.com/home';
      if (page > 1) {
        url = 'https://novelbuddy.com/home?page=$page';
      }

      final response = await dio.get(url);

      if (response.statusCode != 200) {
        throw ScrapingException('Failed to fetch page: ${response.statusCode}');
      }

      // Check if response has content
      if (response.data == null || response.data.toString().isEmpty) {
        throw ScrapingException('Empty response from server');
      }

      final document = html.parse(response.data);

      // Debug: Check if document was parsed correctly
      if (document.body == null) {
        throw ScrapingException('Failed to parse HTML document');
      }

      // NovelBuddy uses .book-item for novels on home page
      var novelElements = document.querySelectorAll(
        '.book-item, .book-detailed-item, .list-stories .item-story, .list-story .item, .novel-item, .story-item, article, .col-story, .item-story, .story-list-item, .novel-list .item, .book-list .item, [class*="novel"], [class*="story"], [class*="book"]',
      );

      // If no results, try even more generic selectors
      if (novelElements.isEmpty) {
        novelElements = document.querySelectorAll(
          '.story-item, .item-story, .novel-list-item, .book-list-item, .item, li[class*="novel"], li[class*="story"], div[class*="novel"], div[class*="story"]',
        );
      }

      // If still no results, try finding any links that might be novels
      if (novelElements.isEmpty) {
        // Look for common patterns: links with images or in list items
        final allLinks = document.querySelectorAll(
          'a[href*="/novel"], a[href*="/story"], a[href*="/book"]',
        );
        if (allLinks.isNotEmpty) {
          // Group links by their parent container
          final parentContainers = <Element>{};
          for (var link in allLinks) {
            var parent = link.parent;
            while (parent != null && parent.localName != 'body') {
              if (parent.classes.isNotEmpty ||
                  parent.querySelector('img') != null) {
                parentContainers.add(parent);
                break;
              }
              parent = parent.parent;
            }
          }
          novelElements = parentContainers.toList();
        }
      }

      // Check if we found any elements
      if (novelElements.isEmpty) {
        // Try one more time with very generic selectors
        novelElements = document.querySelectorAll('div, article, li');
        // Filter to only those with links
        novelElements = novelElements.where((el) {
          return el.querySelector(
                'a[href*="/novel"], a[href*="/story"], a[href*="/book"], a[href*="/chapter"]',
              ) !=
              null;
        }).toList();
      }

      // If still no elements found, try a very broad approach
      if (novelElements.isEmpty) {
        // Try finding any div/article/li that contains a link and an image
        final allElements = document.querySelectorAll(
          'div, article, li, section',
        );
        novelElements = allElements.where((el) {
          final hasLink =
              el.querySelector(
                'a[href*="/novel"], a[href*="/story"], a[href*="/book"], a[href*="/chapter"]',
              ) !=
              null;
          final hasImage = el.querySelector('img') != null;
          final hasText = el.text.trim().length > 10;
          return hasLink && (hasImage || hasText);
        }).toList();
      }

      // Last resort: if still empty, try to get any links that might be novels
      if (novelElements.isEmpty) {
        // Try to get at least some links as novels - be very broad
        final allNovelLinks = document.querySelectorAll(
          'a[href*="/novel"], a[href*="/story"], a[href*="/book"], a[href*="/chapter"]',
        );

        if (allNovelLinks.isNotEmpty) {
          // Get unique parent containers
          final containers = <Element>{};
          for (var link in allNovelLinks) {
            var parent = link.parent;
            // Go up to find a container with multiple children or an image
            while (parent != null &&
                parent.localName != 'body' &&
                parent.localName != 'html') {
              if (parent.querySelector('img') != null ||
                  parent.children.length > 1 ||
                  parent.classes.isNotEmpty) {
                containers.add(parent);
                break;
              }
              parent = parent.parent;
            }
            // If no good parent found, use the link itself
            if (parent == null || parent.localName == 'body') {
              containers.add(link);
            }
          }
          novelElements = containers.toList();
        }
      }

      // If STILL empty, try getting any link with text and an image nearby
      if (novelElements.isEmpty) {
        final allLinks = document.querySelectorAll('a');
        novelElements = allLinks.where((link) {
          final href = link.attributes['href'] ?? '';
          final text = link.text.trim();
          // Check if it looks like a novel link
          return href.contains('/novel') ||
              href.contains('/story') ||
              href.contains('/book') ||
              (text.length > 3 && link.querySelector('img') != null) ||
              (text.length > 10 &&
                  !href.startsWith('#') &&
                  !href.startsWith('javascript:'));
        }).toList();
      }

      // If we still have no elements, the page might be JavaScript-rendered
      // Return empty list instead of throwing to allow UI to show helpful message
      if (novelElements.isEmpty) {
        return [];
      }

      return novelElements
          .map((element) {
            // NovelBuddy uses .meta .title h3 a for titles
            var titleElement = element.querySelector(
              '.meta .title h3 a, .title h3 a, h3 a, h2 a, h1 a, .title a, a.title, h3, h2, h1, .story-title a, .novel-title a, [class*="title"] a, a[class*="title"]',
            );

            // If no title element, try to find any link
            var linkElement = titleElement ?? element.querySelector('a');

            // If still no link, the element itself might be a link
            if (linkElement == null && element.localName == 'a') {
              linkElement = element;
            }

            final href = linkElement?.attributes['href'] ?? '';

            // Extract title from various sources
            var title =
                titleElement?.text.trim() ??
                linkElement?.text.trim() ??
                element
                    .querySelector(
                      '.meta .title h3, h3, h2, h1, .title, [class*="title"]',
                    )
                    ?.text
                    .trim() ??
                element.text.trim() ??
                'Unknown';

            // Clean up title (remove extra whitespace, newlines)
            title = title.replaceAll(RegExp(r'\s+'), ' ').trim();

            // Skip if title is still unknown or too short, but be more lenient
            if (title == 'Unknown' || title.length < 1) {
              // Try to extract from URL if title is missing
              if (href.isNotEmpty) {
                final urlParts = href
                    .split('/')
                    .where((p) => p.isNotEmpty)
                    .toList();
                if (urlParts.isNotEmpty) {
                  title = urlParts.last
                      .replaceAll('-', ' ')
                      .replaceAll('_', ' ');
                  // Capitalize first letter of each word
                  title = title
                      .split(' ')
                      .map((word) {
                        if (word.isEmpty) return word;
                        return word[0].toUpperCase() +
                            word.substring(1).toLowerCase();
                      })
                      .join(' ');
                }
              }

              // If still unknown, skip
              if (title == 'Unknown' || title.length < 1) {
                return null;
              }
            }

            // NovelBuddy uses .thumb img with data-src for lazy loading
            var coverImg =
                element.querySelector('.thumb img')?.attributes['data-src'] ??
                element.querySelector('.thumb img')?.attributes['src'] ??
                element.querySelector('img')?.attributes['data-src'] ??
                element.querySelector('img')?.attributes['src'] ??
                element.querySelector('img')?.attributes['data-lazy-src'] ??
                element
                    .querySelector(
                      '.cover img, .thumbnail img, [class*="cover"] img',
                    )
                    ?.attributes['src'] ??
                '';

            // Make sure cover URL is absolute
            if (coverImg.isNotEmpty) {
              if (coverImg.startsWith('//')) {
                coverImg = 'https:$coverImg';
              } else if (!coverImg.startsWith('http')) {
                coverImg = buildFullUrl(coverImg);
              }
            }

            // Try multiple selectors for author
            var authorElement = element.querySelector(
              '.author, [class*="author"], .story-author, .writer, [class*="writer"], [itemprop="author"]',
            );
            var author = authorElement?.text.trim() ?? 'Unknown';

            // If author is still unknown, try to extract from text content
            if (author == 'Unknown') {
              final text = element.text;
              // Look for common author patterns
              final authorMatch = RegExp(
                r'by\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',
                caseSensitive: false,
              ).firstMatch(text);
              if (authorMatch != null) {
                author = authorMatch.group(1) ?? 'Unknown';
              }
            }

            // NovelBuddy uses .meta .summary for description
            var descElement = element.querySelector(
              '.meta .summary, .summary, .description, .desc, [class*="desc"], .story-desc, [itemprop="description"], p',
            );
            var description = descElement?.text.trim() ?? '';

            // Limit description length
            if (description.length > 200) {
              description = '${description.substring(0, 200)}...';
            }

            // Build source URL
            var sourceUrl = href.isNotEmpty
                ? buildFullUrl(href)
                : 'https://novelbuddy.com/';

            // Make sure we have a valid URL
            if (!sourceUrl.startsWith('http')) {
              sourceUrl = 'https://novelbuddy.com$sourceUrl';
            }

            return Novel(
              id: extractIdFromUrl(href.isNotEmpty ? href : title),
              title: title,
              author: author,
              description: description,
              coverUrl: coverImg,
              sourceUrl: sourceUrl,
              sourceName: 'NovelBuddy',
              genres: StringUtils.extractGenres(element),
              status: element
                  .querySelector('.status, [class*="status"], .story-status')
                  ?.text
                  .trim(),
              lastUpdated: StringUtils.parseDate(
                element
                    .querySelector('.date, [class*="date"], .updated, time')
                    ?.text,
              ),
              totalChapters: StringUtils.parseChapterCount(
                element
                    .querySelector(
                      '.chapters, [class*="chapter"], .chapter-count',
                    )
                    ?.text,
              ),
            );
          })
          .where(
            (novel) =>
                novel != null &&
                novel.title.isNotEmpty &&
                novel.title.length >= 1 &&
                novel.sourceUrl.isNotEmpty &&
                novel.sourceUrl.contains('novelbuddy.com'),
          )
          .cast<Novel>()
          .toList();
    } catch (e) {
      if (e is ScrapingException) {
        rethrow;
      }
      throw ScrapingException('Failed to get all novels: ${e.toString()}');
    }
  }

  @override
  Future<List<Novel>> searchNovels(String query) async {
    try {
      await delay();

      // NovelBuddy uses /search with q parameter
      String searchUrl = 'https://novelbuddy.com/search';
      Map<String, dynamic> queryParams = {'q': query};

      final response = await dio.get(searchUrl, queryParameters: queryParams);

      // Check response
      if (response.statusCode != 200) {
        throw ScrapingException(
          'Search failed with status: ${response.statusCode}. URL: $searchUrl?keyword=$query',
        );
      }

      if (response.data == null || response.data.toString().isEmpty) {
        throw ScrapingException('Empty search response from server');
      }

      final responseText = response.data.toString();

      // Check if response might be JSON (some sites return JSON)
      if (responseText.trim().startsWith('{') ||
          responseText.trim().startsWith('[')) {
        throw ScrapingException(
          'Search returned JSON instead of HTML. The site may use AJAX for search results.',
        );
      }

      final document = html.parse(responseText);

      if (document.body == null) {
        throw ScrapingException('Failed to parse search results HTML');
      }

      // Check if page might be JavaScript-rendered, but don't throw - try to extract what we can
      // Note: AllNovel.org search results are server-rendered, so we should find results

      // NovelBuddy uses .book-item for search results
      var novelElements = document.querySelectorAll(
        '.book-item, .book-detailed-item, .list-stories .item-story, .list-story .item, .novel-item, .search-item, .story-item, article, .col-story, .search-result, .result-item, [class*="search"] [class*="item"], [class*="novel"], [class*="story"], .item-novel, .novel-list-item, .search-list-item, .book-list .item, .novel-list .item, tr[class*="novel"], tr[class*="story"], table tr, .row [class*="novel"], .row [class*="story"]',
      );

      // If no results, try more generic selectors
      if (novelElements.isEmpty) {
        novelElements = document.querySelectorAll(
          '.story-item, .item-story, .novel-list-item, .book-list-item, .item, li[class*="novel"], li[class*="story"], div[class*="novel"], div[class*="story"], [class*="result"], td[class*="novel"], td[class*="story"]',
        );
      }

      // Try table rows if it's a table layout
      if (novelElements.isEmpty) {
        final tableRows = document.querySelectorAll('table tr, tbody tr');
        novelElements = tableRows.where((row) {
          return row.querySelector(
                'a[href*="/novel"], a[href*="/story"], a[href*="/book"]',
              ) !=
              null;
        }).toList();
      }

      // If still no results, try finding links that look like novels
      // AllNovel.org uses .html links for novels (e.g., /novel-name.html)
      if (novelElements.isEmpty) {
        final allLinks = document.querySelectorAll('a');
        final novelLinks = allLinks.where((link) {
          final href = (link.attributes['href'] ?? '').toLowerCase();
          // Check for novel/story/book paths OR .html files that aren't chapters
          return (href.contains('/novel') ||
                  href.contains('/story') ||
                  href.contains('/book') ||
                  (href.endsWith('.html') &&
                      !href.contains('/chapter/') &&
                      !href.contains('/chap-') &&
                      !href.contains('chapter-'))) &&
              !href.startsWith('#') &&
              !href.contains('javascript:') &&
              link.text.trim().length > 1;
        }).toList();

        if (novelLinks.isNotEmpty) {
          // Get parent containers of novel links
          final containers = <Element>{};
          for (var link in novelLinks) {
            var parent = link.parent;
            while (parent != null && parent.localName != 'body') {
              if (parent.classes.isNotEmpty ||
                  parent.querySelector('img') != null ||
                  parent.text.trim().length > 20) {
                containers.add(parent);
                break;
              }
              parent = parent.parent;
            }
            // If no good parent, use the link itself
            if (parent == null || parent.localName == 'body') {
              containers.add(link);
            }
          }
          novelElements = containers.toList();
        }
      }

      // Last resort: try any div/article/li with a novel link and some content
      if (novelElements.isEmpty) {
        final allElements = document.querySelectorAll(
          'div, article, li, section',
        );
        novelElements = allElements.where((el) {
          final links = el.querySelectorAll('a');
          final hasNovelLink = links.any((link) {
            final href = (link.attributes['href'] ?? '').toLowerCase();
            return (href.contains('/novel') ||
                    href.contains('/story') ||
                    href.contains('/book') ||
                    (href.endsWith('.html') &&
                        !href.contains('/chapter/') &&
                        !href.contains('/chap-') &&
                        !href.contains('chapter-'))) &&
                !href.startsWith('#') &&
                !href.contains('javascript:');
          });
          final hasContent = el.text.trim().length > 10;
          return hasNovelLink && hasContent;
        }).toList();
      }

      // If still empty, try to get ANY links that might be novels (very broad)
      if (novelElements.isEmpty) {
        // Try even broader - any link with "novel", "story", or "book" in href
        // Also check for links that go to novel pages (not chapter pages)
        // AllNovel.org uses .html links for novels
        final allLinks = document.querySelectorAll('a');
        final filteredLinks = allLinks.where((link) {
          final href = (link.attributes['href'] ?? '').toLowerCase();
          // Check for novel/story/book paths OR .html files that aren't chapters
          final isNovelLink =
              (href.contains('/novel') ||
              href.contains('/story') ||
              href.contains('/book') ||
              (href.endsWith('.html') &&
                  !href.contains('/chapter/') &&
                  !href.contains('/chap-') &&
                  !href.contains('chapter-')));
          // Exclude chapter links, navigation, and common non-novel links
          return isNovelLink &&
              !href.contains('/chapter/') &&
              !href.contains('/chap-') &&
              !href.contains('#') &&
              !href.contains('javascript:') &&
              !href.contains('mailto:') &&
              link.text.trim().length > 1;
        }).toList();

        if (filteredLinks.isNotEmpty) {
          // Use the links directly or their immediate parents
          novelElements = filteredLinks.map((link) {
            // Try to get parent container that has more content
            var parent = link.parent;
            int depth = 0;
            while (parent != null &&
                parent.localName != 'body' &&
                parent.localName != 'html' &&
                depth < 5) {
              // Check if this parent looks like a novel item container
              if (parent.querySelector('img') != null ||
                  parent.text.trim().length > 30 ||
                  (parent.classes.isNotEmpty &&
                      !parent.classes.any(
                        (c) =>
                            c.toLowerCase().contains('nav') ||
                            c.toLowerCase().contains('menu') ||
                            c.toLowerCase().contains('header') ||
                            c.toLowerCase().contains('footer') ||
                            c.toLowerCase().contains('sidebar'),
                      ))) {
                return parent;
              }
              parent = parent.parent;
              depth++;
            }
            // If no good parent, use the link itself
            return link;
          }).toList();
        }
      }

      // EXTRA FALLBACK: If still empty and we have novel links, just use them directly
      // AllNovel.org uses .html links for novels
      if (novelElements.isEmpty) {
        final allLinks = document.querySelectorAll('a');
        final directNovelLinks = allLinks.where((link) {
          final href = (link.attributes['href'] ?? '').toLowerCase();
          // Check for novel/story/book paths OR .html files that aren't chapters
          final isNovelLink =
              (href.contains('/novel') ||
              href.contains('/story') ||
              href.contains('/book') ||
              (href.endsWith('.html') &&
                  !href.contains('/chapter/') &&
                  !href.contains('/chap-') &&
                  !href.contains('chapter-')));
          return isNovelLink &&
              !href.startsWith('#') &&
              !href.contains('javascript:') &&
              link.text.trim().length > 2;
        }).toList();

        if (directNovelLinks.isNotEmpty) {
          novelElements = directNovelLinks;
        }
      }

      // Debug: Log what we found
      if (novelElements.isEmpty) {
        // Try to see what's actually on the page
        // AllNovel.org uses .html links for novels
        final allLinks = document.querySelectorAll('a');
        final novelLikeLinks = allLinks.where((link) {
          final href = (link.attributes['href'] ?? '').toLowerCase();
          // Check for novel/story/book paths OR .html files that aren't chapters
          return (href.contains('novel') ||
                  href.contains('story') ||
                  href.contains('book') ||
                  (href.endsWith('.html') &&
                      !href.contains('/chapter/') &&
                      !href.contains('/chap-') &&
                      !href.contains('chapter-'))) &&
              !href.startsWith('#') &&
              !href.contains('javascript:') &&
              link.text.trim().length > 1;
        }).toList();

        // If we found novel-like links but no containers, use the links themselves
        if (novelLikeLinks.isNotEmpty) {
          novelElements = novelLikeLinks;
        }
      }

      // If still empty, return empty list (don't throw, let UI show message)
      if (novelElements.isEmpty) {
        return [];
      }

      return novelElements
          .map((element) {
            // NovelBuddy uses .meta .title h3 a for titles
            var titleElement = element.querySelector(
              '.meta .title h3 a, .title h3 a, h3 a, h2 a, h1 a, .title a, a.title, h3, h2, h1, .story-title a, .novel-title a, [class*="title"] a, a[class*="title"]',
            );

            // If no title element, try to find any link
            var linkElement = titleElement ?? element.querySelector('a');

            // If still no link, the element itself might be a link
            if (linkElement == null && element.localName == 'a') {
              linkElement = element;
            }

            final href = linkElement?.attributes['href'] ?? '';

            // Extract title from various sources
            var title =
                titleElement?.text.trim() ??
                linkElement?.text.trim() ??
                element
                    .querySelector(
                      'h3.truyen-title, h3, h2, h1, .title, [class*="title"]',
                    )
                    ?.text
                    .trim() ??
                element.text.trim() ??
                'Unknown';

            // Clean up title (remove extra whitespace, newlines)
            title = title.replaceAll(RegExp(r'\s+'), ' ').trim();

            // Skip if title is still unknown or too short, but be more lenient
            if (title == 'Unknown' || title.length < 1) {
              // Try to extract from URL if title is missing
              if (href.isNotEmpty) {
                final urlParts = href
                    .split('/')
                    .where((p) => p.isNotEmpty)
                    .toList();
                if (urlParts.isNotEmpty) {
                  title = urlParts.last
                      .replaceAll('-', ' ')
                      .replaceAll('_', ' ');
                  // Capitalize first letter of each word
                  title = title
                      .split(' ')
                      .map((word) {
                        if (word.isEmpty) return word;
                        return word[0].toUpperCase() +
                            word.substring(1).toLowerCase();
                      })
                      .join(' ');
                }
              }

              // If still unknown, skip
              if (title == 'Unknown' || title.length < 1) {
                return null;
              }
            }

            // NovelBuddy uses .thumb img with data-src for lazy loading
            var coverImg =
                element.querySelector('.thumb img')?.attributes['data-src'] ??
                element.querySelector('.thumb img')?.attributes['src'] ??
                element.querySelector('img')?.attributes['data-src'] ??
                element.querySelector('img')?.attributes['src'] ??
                element.querySelector('img')?.attributes['data-lazy-src'] ??
                element
                    .querySelector('.thumbnail img, [class*="cover"] img')
                    ?.attributes['src'] ??
                '';

            // Make sure cover URL is absolute
            if (coverImg.isNotEmpty) {
              if (coverImg.startsWith('//')) {
                coverImg = 'https:$coverImg';
              } else if (!coverImg.startsWith('http')) {
                coverImg = buildFullUrl(coverImg);
              }
            }

            // NovelBuddy may not show author in search results, try to find it
            var authorElement = element.querySelector(
              '.author, [class*="author"], .story-author, .writer, [class*="writer"], [itemprop="author"]',
            );
            var author = authorElement?.text.trim() ?? 'Unknown';

            // If author is still unknown, try to extract from text content
            if (author == 'Unknown') {
              final text = element.text;
              // Look for common author patterns
              final authorMatch = RegExp(
                r'by\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*)',
                caseSensitive: false,
              ).firstMatch(text);
              if (authorMatch != null) {
                author = authorMatch.group(1) ?? 'Unknown';
              }
            }

            // Try multiple selectors for description
            var descElement = element.querySelector(
              '.description, .summary, .desc, [class*="desc"], .story-desc, [itemprop="description"], p',
            );
            var description = descElement?.text.trim() ?? '';

            // Limit description length
            if (description.length > 200) {
              description = '${description.substring(0, 200)}...';
            }

            return Novel(
              id: extractIdFromUrl(href.isNotEmpty ? href : title),
              title: title,
              author: author,
              description: description,
              coverUrl: coverImg,
              sourceUrl: href.isNotEmpty
                  ? buildFullUrl(href)
                  : 'https://novelbuddy.com/',
              sourceName: 'NovelBuddy',
              genres: StringUtils.extractGenres(element),
              status: element
                  .querySelector('.status, [class*="status"], .story-status')
                  ?.text
                  .trim(),
              lastUpdated: StringUtils.parseDate(
                element.querySelector('.date, [class*="date"], .updated')?.text,
              ),
              totalChapters: StringUtils.parseChapterCount(
                element
                    .querySelector(
                      '.chapters, [class*="chapter"], .chapter-count',
                    )
                    ?.text,
              ),
            );
          })
          .where(
            (novel) =>
                novel != null &&
                novel.title.isNotEmpty &&
                novel.title.length >= 1 &&
                novel.sourceUrl.isNotEmpty &&
                novel.sourceUrl.contains('novelbuddy.com'),
          )
          .cast<Novel>()
          .toList();
    } catch (e) {
      if (e is ScrapingException) {
        rethrow;
      }
      throw ScrapingException('Failed to search novels: ${e.toString()}');
    }
  }

  @override
  Future<Novel> getNovelDetails(String url) async {
    try {
      await delay();

      final response = await dio.get(url);
      final document = html.parse(response.data);

      // NovelBuddy uses h1 for novel title on detail page
      var titleElement = document.querySelector(
        'h1, .novel-title, .story-title, [class*="title"], header h1, .book-title',
      );
      var title = titleElement?.text.trim() ?? 'Unknown';

      // If title is still unknown, try to extract from meta tags
      if (title == 'Unknown' || title.isEmpty) {
        final metaTitle = document.querySelector('meta[name="title"]');
        if (metaTitle != null) {
          final metaContent = metaTitle.attributes['content'] ?? '';
          // Extract title from meta (format: "Read {Title} online free - All Novel")
          if (metaContent.isNotEmpty) {
            final match = RegExp(
              r'Read\s+(.+?)\s+online',
            ).firstMatch(metaContent);
            if (match != null) {
              title = match.group(1) ?? title;
            }
          }
        }
      }

      // NovelBuddy author selector - check common patterns
      var author = 'Unknown';
      final authorElement = document.querySelector(
        '.author, [itemprop="author"], [class*="author"], .story-author, .writer, [class*="writer"], .book-author, a[href*="/author/"]',
      );
      author = authorElement?.text.trim() ?? 'Unknown';

      // NovelBuddy description selector - uses .summary .content p
      var description = '';
      final descElement = document.querySelector('.summary .content');
      if (descElement != null) {
        // Get all paragraph text if available
        final paragraphs = descElement.querySelectorAll('p');
        if (paragraphs.isNotEmpty) {
          description = paragraphs
              .map((p) => p.text.trim())
              .where((t) => t.isNotEmpty)
              .join('\n\n');
        } else {
          description = descElement.text.trim();
        }
      }

      // Fallback to other selectors if not found
      if (description.isEmpty) {
        final fallbackDesc = document.querySelector(
          '.description, .summary, [itemprop="description"], [class*="desc"], .story-desc, .book-desc, .synopsis, .meta .summary',
        );
        if (fallbackDesc != null) {
          final paragraphs = fallbackDesc.querySelectorAll('p');
          if (paragraphs.isNotEmpty) {
            description = paragraphs
                .map((p) => p.text.trim())
                .where((t) => t.isNotEmpty)
                .join('\n\n');
          } else {
            description = fallbackDesc.text.trim();
          }
        }
      }

      // NovelBuddy cover image - prioritize JSON-LD schema first (most reliable)
      var coverImg = '';

      // First try to extract from JSON-LD schema (most reliable source)
      final scripts = document.querySelectorAll(
        'script[type="application/ld+json"]',
      );
      for (final script in scripts) {
        try {
          final jsonText = script.text;
          if (jsonText.contains('image')) {
            final imageMatch = RegExp(
              r'"image"\s*:\s*"([^"]+)"',
            ).firstMatch(jsonText);
            if (imageMatch != null) {
              coverImg = imageMatch.group(1) ?? '';
              if (coverImg.isNotEmpty) break;
            }
          }
        } catch (e) {
          // Ignore JSON parsing errors
        }
      }

      // Try meta image as fallback (og:image)
      if (coverImg.isEmpty) {
        final metaImage = document.querySelector('meta[property="og:image"]');
        if (metaImage != null) {
          coverImg = metaImage.attributes['content'] ?? '';
        }
      }

      // Last resort: find cover image in the page structure, but exclude logos/banners
      if (coverImg.isEmpty) {
        final allImages = document.querySelectorAll(
          '.cover img, .novel-cover img, .book-cover img, [class*="cover"] img, img[class*="cover"], .thumb img',
        );
        for (final imgElement in allImages) {
          final imgSrc =
              imgElement.attributes['data-src'] ??
              imgElement.attributes['src'] ??
              '';

          // Exclude logos, banners, and small icons
          if (imgSrc.isNotEmpty &&
              !imgSrc.toLowerCase().contains('logo') &&
              !imgSrc.toLowerCase().contains('banner') &&
              !imgSrc.toLowerCase().contains('icon') &&
              !imgSrc.toLowerCase().contains('mangabuddy-icon') &&
              !imgSrc.toLowerCase().contains('/static/common/')) {
            coverImg = imgSrc;
            break;
          }
        }
      }

      // Fix protocol-relative URLs
      if (coverImg.isNotEmpty && coverImg.startsWith('//')) {
        coverImg = 'https:${coverImg}';
      }

      if (coverImg.isNotEmpty && !coverImg.startsWith('http')) {
        coverImg = buildFullUrl(coverImg);
      }

      // NovelBuddy status selector
      var status =
          document
              .querySelector('.status, [class*="status"], .story-status')
              ?.text
              .trim() ??
          '';

      return Novel(
        id: extractIdFromUrl(url),
        title: title,
        author: author,
        description: description,
        coverUrl: coverImg,
        sourceUrl: url,
        sourceName: 'NovelBuddy',
        genres: StringUtils.extractGenres(document),
        status: status,
        lastUpdated: StringUtils.parseDate(
          document
              .querySelector('.last-updated, [class*="updated"], .updated')
              ?.text,
        ),
        totalChapters: StringUtils.parseChapterCount(
          document
              .querySelector(
                '.total-chapters, [class*="chapter"], .chapter-count',
              )
              ?.text,
        ),
      );
    } catch (e) {
      throw ScrapingException('Failed to get novel details: $e');
    }
  }

  @override
  Future<List<Chapter>> getChapters(String novelUrl) async {
    try {
      await delay();

      final response = await dio.get(novelUrl);
      final document = html.parse(response.data);

      // Debug: Check if document was parsed correctly
      if (document.body == null) {
        throw ScrapingException('Failed to parse HTML document');
      }

      // Debug: Check for chapter-list element
      final chapterListElement = document.querySelector('#chapter-list');
      if (chapterListElement == null) {
        print('⚠️  [NovelBuddy] WARNING: #chapter-list element not found!');
        // Try to find any chapter list
        final anyChapterList = document.querySelectorAll(
          '.chapter-list, ul[class*="chapter"]',
        );
        print(
          '📚 [NovelBuddy] Found ${anyChapterList.length} elements with "chapter-list" in class',
        );
      } else {
        print('✓ [NovelBuddy] Found #chapter-list element');
        // Count li elements inside
        final liCount = chapterListElement.querySelectorAll('li').length;
        print(
          '📚 [NovelBuddy] Found $liCount <li> elements inside #chapter-list',
        );
        // Count anchor elements
        final aCount = chapterListElement.querySelectorAll('a').length;
        print(
          '📚 [NovelBuddy] Found $aCount <a> elements inside #chapter-list',
        );
      }

      // NovelBuddy chapter list selector - MUST use #chapter-list to avoid "LATEST CHAPTERS" section
      // The structure is: <ul id="chapter-list"><li id="c-100"><a href="..."><div><strong>...</strong></div></a></li></ul>
      // Try multiple selectors to ensure we find the chapters
      var chapterElements = document.querySelectorAll('#chapter-list li a');

      print(
        '📚 [NovelBuddy] Primary selector (#chapter-list li a): ${chapterElements.length} elements',
      );

      // If no results, try without the id selector (in case id is added dynamically)
      if (chapterElements.isEmpty) {
        chapterElements = document.querySelectorAll('ul.chapter-list li a');
        print(
          '📚 [NovelBuddy] Fallback selector (ul.chapter-list li a): ${chapterElements.length} elements',
        );
      }

      // Another fallback: look for li elements with id starting with "c-"
      if (chapterElements.isEmpty) {
        final allLi = document.querySelectorAll('li[id^="c-"]');
        chapterElements = allLi
            .map((li) => li.querySelector('a'))
            .whereType<Element>()
            .toList();
        print(
          '📚 [NovelBuddy] Fallback selector (li[id^="c-"] a): ${chapterElements.length} elements',
        );
      }

      // If no results, try alternative selectors (but still exclude latest-chapters)
      if (chapterElements.isEmpty) {
        final allChapterLinks = document.querySelectorAll(
          '.chapter-list li a, ul.chapter-list li a',
        );
        // Filter out any from .latest-chapters
        chapterElements = allChapterLinks.where((element) {
          final parent = element.parent;
          if (parent == null) return false;
          // Check if this link is inside .latest-chapters
          Element? current = parent;
          while (current != null) {
            if (current.classes.contains('latest-chapters')) {
              return false; // Exclude this element
            }
            current = current.parent;
          }
          return true;
        }).toList();
      }

      // Last resort: find any links with "chapter" in href, but exclude latest-chapters
      if (chapterElements.isEmpty) {
        final allLinks = document.querySelectorAll('a[href*="/chapter"]');
        chapterElements = allLinks.where((element) {
          Element? current = element.parent;
          while (current != null) {
            if (current.classes.contains('latest-chapters')) {
              return false;
            }
            current = current.parent;
          }
          return true;
        }).toList();
      }

      // Try to get all chapters via API if available (may return more chapters)
      try {
        // Try to find book ID from the page (it's in a script tag)
        final scriptTags = document.querySelectorAll('script');
        String? bookId;
        for (final script in scriptTags) {
          final scriptContent = script.text;
          final bookIdMatch = RegExp(
            r'var\s+bookId\s*=\s*(\d+)',
          ).firstMatch(scriptContent);
          if (bookIdMatch != null) {
            bookId = bookIdMatch.group(1);
            break;
          }
        }

        if (bookId != null) {
          try {
            final apiUrl = 'https://novelbuddy.com/api/manga/$bookId/chapters';
            final apiResponse = await dio.get(apiUrl);
            if (apiResponse.statusCode == 200 && apiResponse.data != null) {
              // Parse API response (it returns HTML)
              if (apiResponse.data is String) {
                final apiDoc = html.parse(apiResponse.data);
                final apiChapterElements = apiDoc.querySelectorAll(
                  'a[href*="/chapter"]',
                );
                // Use API results if we got more chapters
                if (apiChapterElements.length > chapterElements.length) {
                  chapterElements = apiChapterElements;
                }
              }
            }
          } catch (e) {
            // API not available, continue with HTML parsing
          }
        }
      } catch (e) {
        // Continue with HTML parsing
      }

      // Extract chapters from elements and build a map of chapter numbers to chapter data
      final chapterMap = <int, Map<String, dynamic>>{};

      print(
        '📚 [NovelBuddy] Found ${chapterElements.length} chapter elements in HTML',
      );

      for (final element in chapterElements) {
        var chapterUrl = element.attributes['href'] ?? '';

        // Make sure URL is absolute
        if (chapterUrl.isNotEmpty && !chapterUrl.startsWith('http')) {
          chapterUrl = buildFullUrl(chapterUrl);
        }

        // NovelBuddy chapter title extraction - from .chapter-title strong tag
        var title = '';
        final titleElement = element.querySelector(
          '.chapter-title strong, .chapter-title, strong.chapter-title',
        );
        if (titleElement != null) {
          title = titleElement.text.trim();
        }

        // Fallback to element text or title attribute
        if (title.isEmpty) {
          title = element.text.trim();
        }
        if (title.isEmpty) {
          title = element.attributes['title'] ?? '';
        }

        // Clean up title - remove novel name prefix if present
        title = title.trim();
        if (title.contains(' - ')) {
          final parts = title.split(' - ');
          if (parts.length > 1) {
            title = parts.sublist(1).join(' - ').trim();
          }
        }

        // Extract chapter number from title (e.g., "C.3925: Title" -> 3925)
        // or from URL (e.g., "/chapter-3925-..." -> 3925)
        int chapterNumber = 0;

        // Try to extract from title (format: "C.3925: Title" or "C.1 - Title")
        final titleMatch = RegExp(r'C\.(-?\d+)').firstMatch(title);
        if (titleMatch != null) {
          chapterNumber = int.tryParse(titleMatch.group(1) ?? '') ?? 0;
        }

        // If not found in title, try URL (format: "/chapter-3925-...")
        if (chapterNumber == 0 && chapterUrl.isNotEmpty) {
          final urlMatch = RegExp(r'/chapter-(-?\d+)').firstMatch(chapterUrl);
          if (urlMatch != null) {
            chapterNumber = int.tryParse(urlMatch.group(1) ?? '') ?? 0;
          }
        }

        if (chapterNumber > 0) {
          chapterMap[chapterNumber] = {
            'url': chapterUrl.isNotEmpty ? chapterUrl : novelUrl,
            'title': title.isNotEmpty ? title : 'Chapter $chapterNumber',
          };
        }
      }

      print(
        '📚 [NovelBuddy] Successfully extracted ${chapterMap.length} chapters from HTML',
      );

      // Find the range of chapters we have
      if (chapterMap.isEmpty) {
        throw ScrapingException('No chapters found');
      }

      final minChapter = chapterMap.keys.reduce((a, b) => a < b ? a : b);
      final maxChapter = chapterMap.keys.reduce((a, b) => a > b ? a : b);

      print(
        '📚 [NovelBuddy] Extracted chapter numbers: min=$minChapter, max=$maxChapter',
      );
      print(
        '📚 [NovelBuddy] Chapters found in HTML: ${chapterMap.keys.toList()..sort()}',
      );

      // Try to get total chapter count from the page
      int? totalChapters;
      final totalChaptersText = document
          .querySelector('.section-header .title')
          ?.text;
      if (totalChaptersText != null) {
        final totalMatch = RegExp(r'\((\d+)\)').firstMatch(totalChaptersText);
        if (totalMatch != null) {
          totalChapters = int.tryParse(totalMatch.group(1) ?? '');
        }
      }

      print('📚 [NovelBuddy] Total chapters from page: $totalChapters');

      // Extract novel slug from URL for constructing chapter URLs
      final novelSlug = novelUrl.split('/novel/').last.split('?').first;

      // Generate all chapters in the range
      // If we have chapters from both ends (e.g., 1-50 and 3900-3937),
      // generate all chapters in between
      final allChapters = <Chapter>[];

      // Determine the actual range to generate
      // Always start from 1 and go to totalChapters (or maxChapter if total not found)
      final startChapter = 1; // Always start from chapter 1
      final endChapter = totalChapters ?? maxChapter;

      if (totalChapters == null) {
        print(
          '⚠️  [NovelBuddy] WARNING: Could not find total chapter count, using maxChapter=$maxChapter',
        );
      }

      print(
        '📚 [NovelBuddy] Generating chapters from $startChapter to $endChapter',
      );
      print(
        '📚 [NovelBuddy] Chapters with data from HTML: ${chapterMap.length}',
      );
      print(
        '📚 [NovelBuddy] Total chapters to generate: ${endChapter - startChapter + 1}',
      );
      print(
        '📚 [NovelBuddy] Missing chapters to generate: ${endChapter - startChapter + 1 - chapterMap.length}',
      );

      for (int i = startChapter; i <= endChapter; i++) {
        if (chapterMap.containsKey(i)) {
          // Use the scraped data
          final data = chapterMap[i]!;
          allChapters.add(
            Chapter(
              id: extractIdFromUrl(data['url'] as String),
              novelId: extractIdFromUrl(novelUrl),
              title: data['title'] as String,
              content: '',
              chapterNumber: i,
              url: data['url'] as String,
              publishedDate: null,
            ),
          );
        } else {
          // Generate URL for missing chapters using just the chapter number
          // NovelBuddy accepts URLs in the format: /novel/{slug}/chapter-{number}
          // The chapter name slug is optional - the number alone works!
          final generatedUrl = buildFullUrl('/novel/$novelSlug/chapter-$i');
          allChapters.add(
            Chapter(
              id: extractIdFromUrl(generatedUrl),
              novelId: extractIdFromUrl(novelUrl),
              title: 'Chapter $i',
              content: '',
              chapterNumber: i,
              url: generatedUrl,
              publishedDate: null,
            ),
          );
        }
      }

      // Sort chapters by chapter number ascending (lowest to highest)
      allChapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

      // Print summary of all chapters
      print('📚 [NovelBuddy] ========================================');
      print('📚 [NovelBuddy] TOTAL CHAPTERS GENERATED: ${allChapters.length}');
      if (allChapters.isNotEmpty) {
        print(
          '📚 [NovelBuddy] Range: Chapter ${allChapters.first.chapterNumber} to Chapter ${allChapters.last.chapterNumber}',
        );

        // Count how many chapters have titles vs generated
        final withTitles = allChapters
            .where(
              (ch) =>
                  !ch.title.startsWith('Chapter ') || ch.title.contains(':'),
            )
            .length;
        final generated = allChapters.length - withTitles;
        print('📚 [NovelBuddy] Chapters with titles: $withTitles');
        print('📚 [NovelBuddy] Generated chapters: $generated');
      }
      print('📚 [NovelBuddy] ========================================');

      // Print first 10 chapters
      print('📚 [NovelBuddy] First 10 chapters:');
      for (
        int i = 0;
        i < (allChapters.length < 10 ? allChapters.length : 10);
        i++
      ) {
        final ch = allChapters[i];
        print('   ${i + 1}. Chapter ${ch.chapterNumber}: ${ch.title}');
      }

      // Print last 10 chapters
      if (allChapters.length > 10) {
        print(
          '📚 [NovelBuddy] ... (${allChapters.length - 20} chapters in between) ...',
        );
        print('📚 [NovelBuddy] Last 10 chapters:');
        final startIdx = allChapters.length - 10;
        for (int i = startIdx; i < allChapters.length; i++) {
          final ch = allChapters[i];
          print('   ${i + 1}. Chapter ${ch.chapterNumber}: ${ch.title}');
        }
      }

      print('📚 [NovelBuddy] ========================================');

      return allChapters;
    } catch (e) {
      throw ScrapingException('Failed to get chapters: $e');
    }
  }

  @override
  Future<String> getChapterContent(String chapterUrl) async {
    try {
      await delay();
      final response = await dio.get(chapterUrl);
      final document = html.parse(response.data);

      // NovelBuddy chapter content is in .content-inner inside #chapter__content
      var contentElement = document.querySelector(
        '#chapter__content .content-inner, .content-inner, .chapter-content, .chapter-text, #chapter-content',
      );

      // If not found, try finding the content area by looking for the h1 and its container
      if (contentElement == null) {
        final h1 = document.querySelector(
          '#chapter__content h1, .chapter__content h1, h1',
        );
        if (h1 != null) {
          // Look for .content-inner or the container with paragraphs
          var current = h1.parent;
          while (current != null && current.localName != 'body') {
            if (current.classes.contains('content-inner') ||
                current.id == 'chapter__content' ||
                current.querySelector('.content-inner') != null) {
              contentElement =
                  current.querySelector('.content-inner') ?? current;
              break;
            }
            final paragraphs = current.querySelectorAll('p');
            if (paragraphs.length > 10) {
              // Likely found the content area
              contentElement = current;
              break;
            }
            current = current.parent;
          }
        }
      }

      if (contentElement == null) {
        throw ScrapingException('Could not find chapter content');
      }

      // Extract text from paragraphs, preserving structure
      // NovelBuddy uses <p> tags separated by <br> tags
      final paragraphs = contentElement.querySelectorAll('p');
      if (paragraphs.isNotEmpty) {
        final content = paragraphs
            .map((p) {
              var text = p.text.trim();
              // Clean up any extra whitespace
              text = text.replaceAll(RegExp(r'\s+'), ' ');
              return text;
            })
            .where((text) => text.isNotEmpty && text.length > 10)
            .join('\n\n');

        if (content.isNotEmpty) {
          return content;
        }
      }

      // Fallback: clean HTML content and extract text
      var content = contentElement.innerHtml;
      // Remove script tags
      content = content.replaceAll(
        RegExp(r'<script[^>]*>.*?</script>', dotAll: true),
        '',
      );
      // Remove style tags
      content = content.replaceAll(
        RegExp(r'<style[^>]*>.*?</style>', dotAll: true),
        '',
      );
      // Remove div tags used for ads
      content = content.replaceAll(
        RegExp(r'<div[^>]*id="pf-[^"]*"[^>]*>.*?</div>', dotAll: true),
        '',
      );
      // Convert <br> to newlines
      content = content.replaceAll(
        RegExp(r'<br\s*/?>', caseSensitive: false),
        '\n',
      );
      // Remove all remaining HTML tags
      content = content.replaceAll(RegExp(r'<[^>]+>'), '');
      // Clean up whitespace
      content = content.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
      content = content.replaceAll(RegExp(r'[ \t]+'), ' ');
      content = content.trim();

      return content;
    } catch (e) {
      throw ScrapingException('Failed to get chapter content: $e');
    }
  }
}
