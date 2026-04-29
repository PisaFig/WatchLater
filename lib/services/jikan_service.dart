import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../data/mock_data.dart';
import '../models/content_item.dart';

class JikanService {
  JikanService._();

  static Future<List<ContentItem>> fetchAnime() async {
    final uri = Uri.parse('${Constants.jikanBase}/top/anime')
        .replace(queryParameters: {'limit': '25', 'filter': 'bypopularity'});

    debugPrint('[Jikan] GET $uri');

    late http.Response response;
    try {
      response = await http.get(uri);
    } catch (e) {
      debugPrint('[Jikan] network error: $e — using mock anime');
      return MockData.anime;
    }

    debugPrint('[Jikan] status=${response.statusCode}');
    // Print a snippet of the raw body so field names are visible in the log.
    if (response.body.isNotEmpty) {
      debugPrint(
          '[Jikan] body preview: ${response.body.substring(0, math.min(600, response.body.length))}');
    }

    if (response.statusCode != 200) {
      debugPrint('[Jikan] non-200 — using mock anime');
      return MockData.anime;
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items =
        (body['data'] as List? ?? []).cast<Map<String, dynamic>>();

    debugPrint('[Jikan] ${items.length} raw entries received');
    if (items.isNotEmpty) {
      final first = items.first;
      debugPrint('[Jikan] first entry keys: ${first.keys.toList()}');
      debugPrint('[Jikan] first.trailer  = ${first['trailer']}');
      debugPrint('[Jikan] first.aired    = ${first['aired']}');
      debugPrint('[Jikan] first.year     = ${first['year']}');
      debugPrint('[Jikan] first.score    = ${first['score']}');
      debugPrint('[Jikan] first.genres   = ${first['genres']}');
    }

    final results =
        items.map(_buildAnimeItem).whereType<ContentItem>().toList();

    debugPrint(
        '[Jikan] ${results.length} ContentItems built from ${items.length} entries');

    if (results.isEmpty) {
      debugPrint('[Jikan] 0 usable items — using mock anime');
      return MockData.anime;
    }

    return results;
  }

  static ContentItem? _buildAnimeItem(Map<String, dynamic> a) {
    // Use empty string for missing trailers — the detail screen disables
    // the Watch Trailer button when trailerYoutubeId is empty, so no crash.
    final youtubeId =
        (a['trailer'] as Map<String, dynamic>?)?['youtube_id'] as String? ??
        '';

    final posterUrl =
        (a['images'] as Map<String, dynamic>?)?['jpg']?['large_image_url']
            as String? ??
        (a['images'] as Map<String, dynamic>?)?['jpg']?['image_url']
            as String?;
    if (posterUrl == null || posterUrl.isEmpty) return null;

    // Combine genres + demographics so onboarding chips ("Shonen" etc.) match.
    final genreNames = <String>[
      ..._extractNames(a['genres']),
      ..._extractNames(a['demographics']).map(_normalizeDemographic),
    ].where((g) => g.isNotEmpty).toSet().toList();
    if (genreNames.isEmpty) genreNames.add('Anime');

    // Jikan v4: top-level `year` is a shortcut; prefer the more granular
    // `aired.prop.from.year` which is populated even when `year` is null.
    final year = a['year'] as int? ??
        (a['aired'] as Map<String, dynamic>?)?['prop']?['from']?['year']
            as int?;

    final score = (a['score'] as num?)?.toDouble() ?? 0.0;
    final duration = a['duration'] as String? ?? 'N/A';
    final synopsis = _clean(a['synopsis'] as String?);

    // Prefer the English title; fall back to romaji title.
    final rawEnglish = a['title_english'] as String?;
    final rawTitle = a['title'] as String?;
    final title = (rawEnglish != null && rawEnglish.isNotEmpty)
        ? rawEnglish
        : (rawTitle ?? 'Untitled');

    return ContentItem(
      id: 'anime_${a['mal_id']}',
      title: title,
      description: synopsis,
      posterUrl: posterUrl,
      trailerYoutubeId: youtubeId,
      contentType: 'anime',
      genres: genreNames,
      rating: score,
      year: year?.toString() ?? 'N/A',
      duration: duration,
    );
  }

  static List<String> _extractNames(dynamic list) {
    if (list is! List) return [];
    return list
        .cast<Map<String, dynamic>>()
        .map((g) => g['name'] as String? ?? '')
        .toList();
  }

  static String _normalizeDemographic(String name) => switch (name) {
        'Shounen' => 'Shonen',
        'Shoujo' => 'Shojo',
        _ => name,
      };

  static String _clean(String? s) =>
      (s == null || s.trim().isEmpty) ? 'No description available.' : s.trim();
}
