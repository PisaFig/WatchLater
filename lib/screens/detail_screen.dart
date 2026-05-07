import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/content_item.dart';
import '../providers/watchlist_provider.dart';
import '../services/tmdb_service.dart';
import '../theme/app_theme.dart';
import '../widgets/trailer_bottom_sheet.dart';

const _accent = WatchLaterPalette.accent;

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, this.item});

  final ContentItem? item;

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nothing to show.',
                style: GoogleFonts.dmSans(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/discover'),
                child: Text(
                  'Go Discover',
                  style: GoogleFonts.dmSans(
                    color: _accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return _DetailView(item: item!);
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PosterSection(
              item: item,
              posterHeight: mq.size.height * 0.55,
              topPadding: mq.padding.top,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 32,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: 1.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _InlineMetaRow(item: item),
                  const SizedBox(height: 14),
                  _GenreChipsRow(genres: item.genres),
                  const SizedBox(height: 28),
                  const _SectionHeader('Overview'),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.75),
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _SectionHeader('Details'),
                  const SizedBox(height: 12),
                  _DetailsGrid(item: item),
                  if (item.contentType == 'movie' ||
                      item.contentType == 'tvshow')
                    _WhereToWatchSection(contentId: item.id),
                  const SizedBox(height: 36),
                  _WatchlistActions(item: item),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterSection extends StatelessWidget {
  const _PosterSection({
    required this.item,
    required this.posterHeight,
    required this.topPadding,
  });

  final ContentItem item;
  final double posterHeight;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: posterHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: item.posterUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: context.appColors.shimmerBase,
              highlightColor: context.appColors.shimmerHighlight,
              child: const ColoredBox(color: Colors.white),
            ),
            errorWidget: (context, url, error) => ColoredBox(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white24,
                  size: 64,
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.40],
                colors: [
                  Colors.black.withValues(alpha: 0.60),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.40, 1.0],
                colors: [
                  Colors.transparent,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          Positioned(top: topPadding + 8, left: 12, child: _FloatingBack()),
          Positioned(
            top: topPadding + 8,
            right: 12,
            child: _TypeBadge(type: item.contentType),
          ),
        ],
      ),
    );
  }
}

class _FloatingBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/discover');
        }
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  static String _label(String t) => switch (t) {
    'movie' => '🎬 MOVIE',
    'anime' => '🎌 ANIME',
    'tvshow' => '📺 TV SHOW',
    'sports' => '⚽ SPORTS',
    _ => t.toUpperCase(),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Text(
        _label(type),
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InlineMetaRow extends StatelessWidget {
  const _InlineMetaRow({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final style = GoogleFonts.dmSans(
      fontSize: 13,
      color: onSurface.withValues(alpha: 0.54),
    );
    final dot = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '·',
        style: TextStyle(
          color: onSurface.withValues(alpha: 0.38),
          fontSize: 14,
        ),
      ),
    );

    return Row(
      children: [
        const Text('⭐', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          item.rating.toStringAsFixed(1),
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        dot,
        Text(item.year, style: style),
        dot,
        Text(item.duration, style: style),
      ],
    );
  }
}

class _GenreChipsRow extends StatelessWidget {
  const _GenreChipsRow({required this.genres});
  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: genres.map((g) => _GenreChip(genre: g)).toList(),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.genre});
  final String genre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.65)),
        color: _accent.withValues(alpha: 0.10),
      ),
      child: Text(
        genre,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.85),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
        letterSpacing: 1.6,
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.item});
  final ContentItem item;

  static String _typeName(String t) => switch (t) {
    'movie' => 'Movie',
    'anime' => 'Anime',
    'tvshow' => 'TV Show',
    'sports' => 'Sports',
    _ => t,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _DetailRow('Type', _typeName(item.contentType)),
        _DetailRow('Genres', item.genres.join(', ')),
        _DetailRow('Year', item.year),
        _DetailRow('Rating', '⭐  ${item.rating.toStringAsFixed(1)} / 10'),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.38),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.70),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistActions extends StatelessWidget {
  const _WatchlistActions({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final isSaved = provider.isInWatchlist(item.id);

    final isWatched = provider.isItemWatched(item.id);

    return Column(
      children: [
        _FullWidthButton(
          label: item.trailerYoutubeId.isEmpty
              ? '▶   No Trailer Available'
              : '▶   Watch Trailer',
          filled: true,
          danger: false,
          watched: false,
          onTap: item.trailerYoutubeId.isEmpty
              ? null
              : () => TrailerBottomSheet.show(context, item),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _FullWidthButton(
            key: ValueKey(isSaved),
            label: isSaved
                ? '✓   In Watchlist — Tap to Remove'
                : '+   Add to Watchlist',
            filled: false,
            danger: isSaved,
            watched: false,
            onTap: () {
              if (isSaved) {
                provider.removeFromWatchlist(item.id);
              } else {
                provider.addToWatchlist(item);
              }
            },
          ),
        ),
        if (isSaved) ...[
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _FullWidthButton(
              key: ValueKey(isWatched),
              label: isWatched
                  ? '✓   Watched — Tap to Unmark'
                  : '○   Mark as Watched',
              filled: isWatched,
              danger: false,
              watched: true,
              onTap: () => provider.toggleWatched(item.id),
            ),
          ),
        ],
      ],
    );
  }
}

class _WhereToWatchSection extends StatefulWidget {
  const _WhereToWatchSection({required this.contentId});
  final String contentId;

  @override
  State<_WhereToWatchSection> createState() => _WhereToWatchSectionState();
}

class _WhereToWatchSectionState extends State<_WhereToWatchSection> {
  late final Future<WatchProvidersResult> _future;

  @override
  void initState() {
    super.initState();
    _future = TmdbService.fetchWatchProviders(widget.contentId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WatchProvidersResult>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmer(context);
        }
        final providers = snapshot.data?.providers ?? {};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),
            const _SectionHeader('Where to Watch'),
            const SizedBox(height: 14),
            if (providers.isEmpty)
              Text(
                'No streaming info available.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.38),
                ),
              )
            else ...[
              if (providers['flatrate'] != null)
                _ProviderRow(
                  label: 'Stream',
                  providers: providers['flatrate']!,
                ),
              if (providers['rent'] != null) ...[
                const SizedBox(height: 12),
                _ProviderRow(label: 'Rent', providers: providers['rent']!),
              ],
              if (providers['buy'] != null) ...[
                const SizedBox(height: 12),
                _ProviderRow(label: 'Buy', providers: providers['buy']!),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        const _SectionHeader('Where to Watch'),
        const SizedBox(height: 14),
        Row(
          children: List.generate(
            4,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Shimmer.fromColors(
                baseColor: context.appColors.shimmerBase,
                highlightColor: context.appColors.shimmerHighlight,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({required this.label, required this.providers});
  final String label;
  final List<WatchProvider> providers;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: providers.take(8).map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Tooltip(
                    message: p.name,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: p.logoUrl,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: context.appColors.shimmerBase,
                          highlightColor: context.appColors.shimmerHighlight,
                          child: Container(
                            width: 44,
                            height: 44,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: WatchLaterPalette.darkSurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p.name.isNotEmpty ? p.name[0] : '?',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullWidthButton extends StatelessWidget {
  const _FullWidthButton({
    super.key,
    required this.label,
    required this.filled,
    required this.danger,
    required this.watched,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final bool danger;
  final bool watched;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const watchedColor = WatchLaterPalette.success;
    final fillColor = watched ? watchedColor : _accent;
    final borderColor = danger
        ? Colors.redAccent
        : watched
        ? watchedColor
        : _accent;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: filled
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: fillColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 8,
                shadowColor: fillColor.withValues(alpha: 0.45),
              ),
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: borderColor,
                side: BorderSide(color: borderColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: borderColor,
                ),
              ),
            ),
    );
  }
}
