import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/content_item.dart';
import '../theme/app_theme.dart';

class WatchlistShareCard extends StatelessWidget {
  const WatchlistShareCard({
    super.key,
    required this.previewItems,
    required this.posters,
    required this.totalCount,
  });

  final List<ContentItem> previewItems;
  final Map<String, Uint8List> posters;
  final int totalCount;

  static const _posterWidth = 101.0;
  static const _posterHeight = _posterWidth * 1.5;
  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WatchLaterPalette.darkBackground,
            WatchLaterPalette.darkPanelAlt,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: WatchLaterPalette.accent.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildGrid(),
          const SizedBox(height: 14),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'WATCH',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: WatchLaterPalette.accent,
                  letterSpacing: 2,
                ),
              ),
              TextSpan(
                text: 'LATER',
                style: GoogleFonts.bebasNeue(
                  fontSize: 32,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Text(
          'My Watchlist',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            color: Colors.white38,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final items = previewItems.take(6).toList();
    final rows = (items.length / 3).ceil().clamp(1, 2);

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row < rows - 1 ? _gap : 0),
          child: Row(
            children: List.generate(3, (col) {
              final idx = row * 3 + col;
              return Padding(
                padding: EdgeInsets.only(right: col < 2 ? _gap : 0),
                child: _PosterCell(
                  item: idx < items.length ? items[idx] : null,
                  bytes: idx < items.length ? posters[items[idx].id] : null,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    final typeEmojis = {
      'movie': '🎬',
      'anime': '🎌',
      'tvshow': '📺',
      'sports': '⚽',
    };

    final presentTypes = typeEmojis.entries
        .where((e) => previewItems.any((i) => i.contentType == e.key))
        .map((e) => e.value)
        .join('  ');

    return Row(
      children: [
        Expanded(
          child: Text(
            '$totalCount ${totalCount == 1 ? 'title' : 'titles'} saved',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(presentTypes, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _PosterCell extends StatelessWidget {
  const _PosterCell({this.item, this.bytes});

  final ContentItem? item;
  final Uint8List? bytes;

  static const _width = WatchlistShareCard._posterWidth;
  static const _height = WatchlistShareCard._posterHeight;

  static String _emoji(String type) => switch (type) {
    'movie' => '🎬',
    'anime' => '🎌',
    'tvshow' => '📺',
    'sports' => '⚽',
    _ => '🎬',
  };

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: _width,
        height: _height,
        child: _content(),
      ),
    );
  }

  Widget _content() {
    if (item == null) {
      return const ColoredBox(color: WatchLaterPalette.darkPanel);
    }
    if (bytes != null) {
      return Image.memory(bytes!, fit: BoxFit.cover);
    }
    return ColoredBox(
      color: WatchLaterPalette.darkPanel,
      child: Center(
        child: Text(_emoji(item!.contentType), style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}
