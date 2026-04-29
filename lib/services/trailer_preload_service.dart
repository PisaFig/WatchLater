import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

import '../models/content_item.dart';
import 'content_service.dart';

class TrailerPreloadService {
  TrailerPreloadService._();

  static final Set<String> _preloadedThumbnailIds = {};
  static int _requestToken = 0;

  static Future<void> preloadForPreferences(
    BuildContext context, {
    required List<String> selectedTypes,
    required List<String> selectedGenres,
    int limit = 8,
  }) async {
    final token = ++_requestToken;
    final items = await ContentService.fetchAll();
    if (!context.mounted || token != _requestToken) return;

    final filtered = _filterItems(
      items,
      selectedTypes: selectedTypes,
      selectedGenres: selectedGenres,
    ).where((item) => item.trailerYoutubeId.isNotEmpty).take(limit);

    await Future.wait(
      filtered.map((item) => _preloadThumbnail(context, item)),
      eagerError: false,
    );
  }

  static List<ContentItem> _filterItems(
    List<ContentItem> items, {
    required List<String> selectedTypes,
    required List<String> selectedGenres,
  }) {
    var filtered = items;
    if (selectedTypes.isNotEmpty) {
      filtered = filtered
          .where((item) => selectedTypes.contains(item.contentType))
          .toList();
    }
    if (selectedGenres.isNotEmpty) {
      filtered = filtered
          .where((item) => item.genres.any(selectedGenres.contains))
          .toList();
    }
    return filtered;
  }

  static Future<void> _preloadThumbnail(
    BuildContext context,
    ContentItem item,
  ) async {
    final id = item.trailerYoutubeId;
    if (!_preloadedThumbnailIds.add(id)) return;

    final imageProvider = CachedNetworkImageProvider(
      'https://img.youtube.com/vi/$id/hqdefault.jpg',
    );

    try {
      await precacheImage(imageProvider, context);
    } catch (_) {
      _preloadedThumbnailIds.remove(id);
    }
  }
}
