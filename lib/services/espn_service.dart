import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/content_item.dart';

const _nflIds = ['VKIVBHKnhyo', 'OJ0ZH13J7aQ', 'CbulKW7YiSY', 'GNPX_jGBBok'];
const _nbaIds = ['tIFGgkEtUuE', 'RKMGHWjHvFY', 'vZl7BDVbQ1A', 'AKowbHguSAI'];
const _mlbIds = ['OxbHJn5CUI0', 'GCujKGdm3oE', 'UOgyPOlKEqY', 'dKb4q_Cjnbc'];
const _mlsIds = ['g9RFyJ8hLdA', 'V0IFyW9XHVY', 'R4Lpjhb6GhE', 'y5y6nfFIjhA'];

class _LeagueMeta {
  const _LeagueMeta({
    required this.sport,
    required this.league,
    required this.genre,
    required this.duration,
    required this.youtubePool,
  });

  final String sport;
  final String league;
  final String genre;
  final String duration;
  final List<String> youtubePool;
}

const _leagues = [
  _LeagueMeta(
    sport: 'football',
    league: 'nfl',
    genre: 'Football',
    duration: '~3h 30min',
    youtubePool: _nflIds,
  ),
  _LeagueMeta(
    sport: 'basketball',
    league: 'nba',
    genre: 'Basketball',
    duration: '~2h 30min',
    youtubePool: _nbaIds,
  ),
  _LeagueMeta(
    sport: 'baseball',
    league: 'mlb',
    genre: 'Baseball',
    duration: '~3h',
    youtubePool: _mlbIds,
  ),
  _LeagueMeta(
    sport: 'soccer',
    league: 'usa.1',
    genre: 'Soccer',
    duration: '~2h',
    youtubePool: _mlsIds,
  ),
];

class EspnService {
  EspnService._();

  static Future<List<ContentItem>> fetchSports() async {
    final results = await Future.wait(
      _leagues.map((meta) => _fetchLeague(meta)),
    );
    return results.expand((list) => list).toList();
  }

  static Future<List<ContentItem>> _fetchLeague(_LeagueMeta meta) async {
    try {
      final uri = Uri.parse(
          '${Constants.espnBase}/${meta.sport}/${meta.league}/scoreboard');
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final events = (data['events'] as List? ?? [])
          .cast<Map<String, dynamic>>()
          .take(6)
          .toList();

      return [
        for (var i = 0; i < events.length; i++)
          _buildSportsItem(events[i], meta, i),
      ].whereType<ContentItem>().toList();
    } catch (_) {
      return [];
    }
  }

  static ContentItem? _buildSportsItem(
    Map<String, dynamic> event,
    _LeagueMeta meta,
    int index,
  ) {
    final competitions = (event['competitions'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    if (competitions.isEmpty) return null;

    final competition = competitions.first;
    final competitors = (competition['competitors'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    if (competitors.isEmpty) return null;

    final home = competitors.firstWhere(
      (c) => c['homeAway'] == 'home',
      orElse: () => competitors.first,
    );
    final posterUrl =
        (home['team'] as Map<String, dynamic>?)?['logo'] as String?;
    if (posterUrl == null || posterUrl.isEmpty) return null;

    final eventId = event['id'] as String? ?? '${meta.league}_$index';
    final name = event['name'] as String? ??
        event['shortName'] as String? ??
        '${meta.genre} Match';

    final description = _buildDescription(competition, event['date'] as String?);

    final dateStr = event['date'] as String? ?? '';
    final year = dateStr.length >= 4 ? dateStr.substring(0, 4) : 'N/A';

    final trailerId =
        meta.youtubePool[index % meta.youtubePool.length];

    return ContentItem(
      id: 'sports_$eventId',
      title: name,
      description: description,
      posterUrl: posterUrl,
      trailerYoutubeId: trailerId,
      contentType: 'sports',
      genres: [meta.genre],
      rating: 8.0,
      year: year,
      duration: meta.duration,
    );
  }

  static String _buildDescription(
    Map<String, dynamic> competition,
    String? dateStr,
  ) {
    final parts = <String>[];

    final notes = (competition['notes'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    if (notes.isNotEmpty) {
      final note = notes.first['text'] as String? ?? '';
      if (note.isNotEmpty) parts.add(note);
    }

    final venue = competition['venue'] as Map<String, dynamic>?;
    final venueName = venue?['fullName'] as String? ?? '';
    final city =
        (venue?['address'] as Map<String, dynamic>?)?['city'] as String? ?? '';
    if (venueName.isNotEmpty) {
      parts.add(city.isNotEmpty ? '$venueName, $city' : venueName);
    }

    final status =
        ((competition['status'] as Map?)?['type'])?['description'] as String?;
    if (status != null && status != 'Scheduled') parts.add(status);

    if (dateStr != null) {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        const months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        parts.add('${months[dt.month]} ${dt.day}, ${dt.year}');
      }
    }

    return parts.isNotEmpty ? parts.join(' · ') : 'Live sports event.';
  }
}
