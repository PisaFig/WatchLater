import '../models/content_item.dart';
import 'espn_service.dart';
import 'jikan_service.dart';
import 'tmdb_service.dart';

class ContentService {
  ContentService._();

  static List<ContentItem>? _cache;
  static DateTime? _cacheTime;
  static const _cacheTtl = Duration(hours: 1);

  static bool get _cacheValid =>
      _cache != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _cacheTtl;

  static Future<List<ContentItem>> fetchAll() async {
    if (_cacheValid) return List.from(_cache!);

    final results = await Future.wait([
      _safe(TmdbService.fetchMovies()),
      _safe(TmdbService.fetchTvShows()),
      _safe(JikanService.fetchAnime()),
      _safe(EspnService.fetchSports()),
    ]);

    final all = results.expand((list) => list).toList();

    _cache = all;
    _cacheTime = DateTime.now();
    return List.from(all);
  }

  static void invalidate() {
    _cache = null;
    _cacheTime = null;
  }

  static Future<List<ContentItem>> _safe(
      Future<List<ContentItem>> future) async {
    try {
      return await future;
    } catch (_) {
      return [];
    }
  }
}
