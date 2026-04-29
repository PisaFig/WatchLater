import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/content_item.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';

const _accent = WatchLaterPalette.accent;
const _cardBg = WatchLaterPalette.darkSurface;

// Filter chip data: (label, type key)
const _filters = [
  ('All', 'all'),
  ('Movies', 'movie'),
  ('Anime', 'anime'),
  ('TV Shows', 'tvshow'),
  ('Sports', 'sports'),
];

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final items = provider.filteredWatchlist;
    final total = provider.watchlist.length;
    final filter = provider.activeFilter;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopBar(total: total),
            _FilterRow(activeFilter: filter, provider: provider),
            items.isEmpty
                ? Expanded(child: _EmptyState(isEmpty: total == 0))
                : Expanded(
                    child: _PosterGrid(items: items, provider: provider),
                  ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'My Watchlist',
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _CountBadge(count: total, key: ValueKey(total)),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: _accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter chips row
// ---------------------------------------------------------------------------

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.activeFilter, required this.provider});
  final String activeFilter;
  final WatchlistProvider provider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (context, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, key) = _filters[i];
          final active = activeFilter == key;
          return _Chip(
            label: label,
            active: active,
            onTap: () => provider.filterByType(key),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? _accent
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.24),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active
                ? Colors.white
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Poster grid
// ---------------------------------------------------------------------------

class _PosterGrid extends StatelessWidget {
  const _PosterGrid({required this.items, required this.provider});
  final List<ContentItem> items;
  final WatchlistProvider provider;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _GridItem(
          key: ValueKey(item.id),
          item: item,
          index: index,
          onTap: () => context.push('/detail', extra: item),
          onLongPress: () => _showRemoveDialog(context, provider, item),
        );
      },
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    WatchlistProvider provider,
    ContentItem item,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove from Watchlist?',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          '"${item.title}" will be removed from your list.',
          style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.removeFromWatchlist(item.id);
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Remove',
              style: GoogleFonts.dmSans(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual grid card
// ---------------------------------------------------------------------------

class _GridItem extends StatelessWidget {
  const _GridItem({
    super.key,
    required this.item,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  final ContentItem item;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  static String _typeEmoji(String type) => switch (type) {
    'movie' => '🎬',
    'anime' => '🎌',
    'tvshow' => '📺',
    'sports' => '⚽',
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    final delay = Duration(milliseconds: math.min(index * 55, 440));

    return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Poster
                CachedNetworkImage(
                  imageUrl: item.posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: context.appColors.shimmerBase,
                    highlightColor: context.appColors.shimmerHighlight,
                    child: ColoredBox(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => ColoredBox(
                    color: _cardBg,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white24,
                      size: 36,
                    ),
                  ),
                ),
                // Bottom gradient
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.45, 1.0],
                      colors: [
                        Colors.transparent,
                        WatchLaterPalette.overlayExtraStrong,
                      ],
                    ),
                  ),
                ),
                // Content type badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _typeEmoji(item.contentType),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                // Watched badge
                if (item.isWatched)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: WatchLaterPalette.success.withValues(
                          alpha: 0.92,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '✓ Watched',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                // Title
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Text(
                    item.title,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 15,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: delay)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.12, duration: 350.ms, curve: Curves.easeOut);
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  /// [isEmpty] true = watchlist is fully empty; false = active filter has no results.
  const _EmptyState({required this.isEmpty});
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isEmpty ? '🔖' : '🔍', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 18),
            Text(
              isEmpty
                  ? 'Nothing here yet.\nStart swiping!'
                  : 'No results for this filter.',
              style: GoogleFonts.bebasNeue(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 1,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isEmpty
                  ? 'Swipe right on something you love\nin the Discover tab.'
                  : 'Try selecting a different category.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.38),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (isEmpty) ...[
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => context.go('/discover'),
                icon: const Icon(Icons.explore_rounded),
                label: Text(
                  'Go Discover',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 8,
                  shadowColor: _accent.withValues(alpha: 0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
