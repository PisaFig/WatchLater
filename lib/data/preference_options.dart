import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PreferenceOption {
  const PreferenceOption({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.genres,
  });

  final String type;
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final List<String> genres;
}

const preferenceOptions = [
  PreferenceOption(
    type: 'movie',
    label: 'Movies',
    subtitle: 'Blockbusters, indies, late-night rewatches',
    icon: Icons.local_movies_rounded,
    gradient: WatchLaterPalette.movieGradient,
    genres: [
      'Action',
      'Horror',
      'Romance',
      'Sci-Fi',
      'Comedy',
      'Thriller',
      'Documentary',
    ],
  ),
  PreferenceOption(
    type: 'anime',
    label: 'Anime',
    subtitle: 'Seasonal hits, comfort arcs, cult favorites',
    icon: Icons.auto_awesome_rounded,
    gradient: WatchLaterPalette.animeGradient,
    genres: ['Shonen', 'Isekai', 'Slice of Life', 'Mecha', 'Fantasy', 'Horror'],
  ),
  PreferenceOption(
    type: 'tvshow',
    label: 'TV Shows',
    subtitle: 'Prestige dramas, sitcoms, reality binges',
    icon: Icons.live_tv_rounded,
    gradient: WatchLaterPalette.tvGradient,
    genres: ['Drama', 'Reality', 'Crime', 'Sitcom', 'Fantasy', 'Sci-Fi'],
  ),
  PreferenceOption(
    type: 'sports',
    label: 'Sports',
    subtitle: 'Live events, rivalries, highlight runs',
    icon: Icons.sports_soccer_rounded,
    gradient: WatchLaterPalette.sportsGradient,
    genres: [
      'Football',
      'Basketball',
      'UFC/MMA',
      'Formula 1',
      'Tennis',
      'Baseball',
    ],
  ),
];
