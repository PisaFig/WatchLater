import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/content_item.dart';

class TmdbService {
  TmdbService._();

  // ─── HTTP helper ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? extra,
  ]) async {
    final params = {
      'api_key': Constants.tmdbApiKey,
      'language': 'en-US',
      ...?extra,
    };
    final uri = Uri.parse('${Constants.tmdbBase}$path')
        .replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('TMDB $path → ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ─── Genre helpers ───────────────────────────────────────────────────────

  static Map<int, String> _parseGenreMap(Map<String, dynamic> resp) {
    final raw = resp['genres'] as List? ?? [];
    return {
      for (final g in raw)
        (g['id'] as int): _normalizeGenre(g['name'] as String? ?? ''),
    };
  }

  static String _normalizeGenre(String name) => switch (name) {
        'Science Fiction' => 'Sci-Fi',
        'Sci-Fi & Fantasy' => 'Sci-Fi',
        'Action & Adventure' => 'Action',
        'War & Politics' => 'War',
        _ => name,
      };

  // ─── Trailer picker ──────────────────────────────────────────────────────

  /// Returns the best YouTube trailer key from a /videos response object,
  /// or an empty string when nothing suitable is found.
  static String _pickTrailerId(Map<String, dynamic>? videoResp) {
    final results = (videoResp?['results'] as List? ?? [])
        .cast<Map<String, dynamic>>();

    bool isYt(Map m) => m['site'] == 'YouTube';
    bool isTrailer(Map m) => m['type'] == 'Trailer';
    bool isOfficial(Map m) => m['official'] == true;

    String keyOf(Map m) => m['key'] as String? ?? '';

    // Prefer official YouTube trailers.
    final official =
        results.where((v) => isYt(v) && isTrailer(v) && isOfficial(v));
    if (official.isNotEmpty) return keyOf(official.first);

    final anyTrailer = results.where((v) => isYt(v) && isTrailer(v));
    if (anyTrailer.isNotEmpty) return keyOf(anyTrailer.first);

    final anyYt = results.where(isYt);
    if (anyYt.isNotEmpty) return keyOf(anyYt.first);

    return '';
  }

  // ─── Movies ──────────────────────────────────────────────────────────────

  static Future<List<ContentItem>> fetchMovies() async {
    // Genre map + popular list — run in parallel.
    final responses = await Future.wait([
      _get('/genre/movie/list'),
      _get('/movie/popular'),
    ]);
    final genreMap = _parseGenreMap(responses[0]);
    final rawMovies = (responses[1]['results'] as List)
        .cast<Map<String, dynamic>>()
        .take(20)
        .toList();

    // Fetch full detail (includes runtime) + videos for each movie in parallel.
    final details = await Future.wait<Map<String, dynamic>>(
      rawMovies.map((m) async {
        try {
          return await _get('/movie/${m['id']}',
              {'append_to_response': 'videos'});
        } catch (_) {
          return m; // fall back to list-level data; trailer will be empty
        }
      }),
    );

    return [
      for (var i = 0; i < rawMovies.length; i++)
        _buildMovieItem(rawMovies[i], details[i], genreMap),
    ].whereType<ContentItem>().toList();
  }

  static ContentItem? _buildMovieItem(
    Map<String, dynamic> basic,
    Map<String, dynamic> detail,
    Map<int, String> genreMap,
  ) {
    final posterPath =
        basic['poster_path'] as String? ?? detail['poster_path'] as String?;
    if (posterPath == null || posterPath.isEmpty) return null;

    final genreIds = (basic['genre_ids'] as List? ?? []).cast<int>();
    final genres = genreIds
        .map((id) => genreMap[id] ?? '')
        .where((g) => g.isNotEmpty)
        .toList();
    if (genres.isEmpty) genres.add('Film');

    final runtimeMin = detail['runtime'] as int? ?? 120;
    final h = runtimeMin ~/ 60;
    final m = runtimeMin % 60;
    final duration = h > 0 ? '${h}h ${m}min' : '${m}min';

    final releaseDate = basic['release_date'] as String? ?? '';
    final year =
        releaseDate.length >= 4 ? releaseDate.substring(0, 4) : 'N/A';

    final videoResp = detail['videos'] as Map<String, dynamic>?;
    final trailerId = _pickTrailerId(videoResp);

    return ContentItem(
      id: 'movie_${basic['id']}',
      title: basic['title'] as String? ?? 'Untitled',
      description: _clean(basic['overview'] as String?),
      posterUrl: '${Constants.tmdbImageBase}$posterPath',
      trailerYoutubeId: trailerId,
      contentType: 'movie',
      genres: genres,
      rating: ((basic['vote_average'] as num?) ?? 0.0).toDouble(),
      year: year,
      duration: duration,
    );
  }

  // ─── TV Shows ────────────────────────────────────────────────────────────

  static Future<List<ContentItem>> fetchTvShows() async {
    final responses = await Future.wait([
      _get('/genre/tv/list'),
      _get('/tv/popular'),
    ]);
    final genreMap = _parseGenreMap(responses[0]);
    final rawShows = (responses[1]['results'] as List)
        .cast<Map<String, dynamic>>()
        .take(20)
        .toList();

    final details = await Future.wait<Map<String, dynamic>>(
      rawShows.map((s) async {
        try {
          return await _get('/tv/${s['id']}',
              {'append_to_response': 'videos'});
        } catch (_) {
          return s;
        }
      }),
    );

    return [
      for (var i = 0; i < rawShows.length; i++)
        _buildTvItem(rawShows[i], details[i], genreMap),
    ].whereType<ContentItem>().toList();
  }

  static ContentItem? _buildTvItem(
    Map<String, dynamic> basic,
    Map<String, dynamic> detail,
    Map<int, String> genreMap,
  ) {
    final posterPath =
        basic['poster_path'] as String? ?? detail['poster_path'] as String?;
    if (posterPath == null || posterPath.isEmpty) return null;

    final genreIds = (basic['genre_ids'] as List? ?? []).cast<int>();
    final genres = genreIds
        .map((id) => genreMap[id] ?? '')
        .where((g) => g.isNotEmpty)
        .toList();
    if (genres.isEmpty) genres.add('TV');

    final runtimes =
        (detail['episode_run_time'] as List? ?? []).cast<int>();
    final runtime = runtimes.isNotEmpty ? runtimes.first : 45;
    final duration = '~${runtime}min / ep';

    final firstAirDate = basic['first_air_date'] as String? ?? '';
    final year =
        firstAirDate.length >= 4 ? firstAirDate.substring(0, 4) : 'N/A';

    final videoResp = detail['videos'] as Map<String, dynamic>?;
    final trailerId = _pickTrailerId(videoResp);

    return ContentItem(
      id: 'tv_${basic['id']}',
      title: basic['name'] as String? ?? 'Untitled',
      description: _clean(basic['overview'] as String?),
      posterUrl: '${Constants.tmdbImageBase}$posterPath',
      trailerYoutubeId: trailerId,
      contentType: 'tvshow',
      genres: genres,
      rating: ((basic['vote_average'] as num?) ?? 0.0).toDouble(),
      year: year,
      duration: duration,
    );
  }

  // ─── Shared ──────────────────────────────────────────────────────────────

  static String _clean(String? s) =>
      (s == null || s.trim().isEmpty) ? 'No description available.' : s.trim();
}
