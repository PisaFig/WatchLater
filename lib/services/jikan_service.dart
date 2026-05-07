import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../data/mock_data.dart';
import '../models/content_item.dart';

class JikanService {
  JikanService._();

  static Future<List<ContentItem>> fetchAnime() async {
    final uri = Uri.parse('${Constants.jikanBase}/top/anime')
        .replace(queryParameters: {'limit': '25', 'filter': 'bypopularity'});

    late http.Response response;
    try {
      response = await http.get(uri);
    } catch (_) {
      return MockData.anime;
    }

    if (response.statusCode != 200) return MockData.anime;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (body['data'] as List? ?? []).cast<Map<String, dynamic>>();
    final results = items.map(_buildAnimeItem).whereType<ContentItem>().toList();

    return results.isEmpty ? MockData.anime : results;
  }

  static ContentItem? _buildAnimeItem(Map<String, dynamic> a) {
    final youtubeId =
        (a['trailer'] as Map<String, dynamic>?)?['youtube_id'] as String? ??
        '';

    final posterUrl =
        (a['images'] as Map<String, dynamic>?)?['jpg']?['large_image_url']
            as String? ??
        (a['images'] as Map<String, dynamic>?)?['jpg']?['image_url']
            as String?;
    if (posterUrl == null || posterUrl.isEmpty) return null;

    final genreNames = <String>[
      ..._extractNames(a['genres']),
      ..._extractNames(a['demographics']).map(_normalizeDemographic),
    ].where((g) => g.isNotEmpty).toSet().toList();
    if (genreNames.isEmpty) genreNames.add('Anime');

    final year = a['year'] as int? ??
        (a['aired'] as Map<String, dynamic>?)?['prop']?['from']?['year']
            as int?;

    final score = (a['score'] as num?)?.toDouble() ?? 0.0;
    final duration = a['duration'] as String? ?? 'N/A';
    final synopsis = _clean(a['synopsis'] as String?);

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
