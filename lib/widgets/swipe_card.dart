import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../models/content_item.dart';
import '../theme/app_theme.dart';

const _accent = WatchLaterPalette.accent;

class SwipeCard extends StatelessWidget {
  const SwipeCard({
    super.key,
    required this.item,
    required this.onSave,
    required this.onSkip,
    required this.onTrailerTap,
    this.horizontalOffsetPercentage = 0,
  });

  final ContentItem item;
  final VoidCallback onSave;
  final VoidCallback onSkip;
  final VoidCallback onTrailerTap;

  final int horizontalOffsetPercentage;

  double get _stampOpacity =>
      ((horizontalOffsetPercentage.abs() - 8) / 55).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _PosterImage(url: item.posterUrl),
          const _GradientOverlay(),
          _TopBadges(item: item),
          _BottomContent(item: item, onTrailerTap: onTrailerTap),
          if (horizontalOffsetPercentage > 0)
            _SwipeStamp.save(opacity: _stampOpacity),
          if (horizontalOffsetPercentage < 0)
            _SwipeStamp.skip(opacity: _stampOpacity),
        ],
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: context.appColors.shimmerBase,
        highlightColor: WatchLaterPalette.cardShimmerHighlight,
        child: Container(color: Colors.white),
      ),
      errorWidget: (context, url, error) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          color: Colors.white24,
          size: 56,
        ),
      ),
    );
  }
}

class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.30, 0.65, 1.0],
          colors: [
            Colors.transparent,
            WatchLaterPalette.overlayMid,
            WatchLaterPalette.overlayStrong,
          ],
        ),
      ),
    );
  }
}

class _TopBadges extends StatelessWidget {
  const _TopBadges({required this.item});
  final ContentItem item;

  static String _typeLabel(String type) => switch (type) {
    'movie' => '🎬 MOVIE',
    'anime' => '🎌 ANIME',
    'tvshow' => '📺 TV SHOW',
    'sports' => '⚽ SPORTS',
    _ => type.toUpperCase(),
  };

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Badge(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  item.rating.toStringAsFixed(1),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _Badge(
            child: Text(
              _typeLabel(item.contentType),
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}

class _BottomContent extends StatelessWidget {
  const _BottomContent({required this.item, required this.onTrailerTap});
  final ContentItem item;
  final VoidCallback onTrailerTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 1.5,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            _GenreChipsRow(genres: item.genres),
            const SizedBox(height: 10),
            Text(
              item.description,
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.80),
                height: 1.45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _MetaInfo(item: item)),
                _TrailerButton(onTap: onTrailerTap),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreChipsRow extends StatelessWidget {
  const _GenreChipsRow({required this.genres});
  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: genres.take(4).map((g) {
          return Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accent.withValues(alpha: 0.70)),
              color: _accent.withValues(alpha: 0.12),
            ),
            child: Text(
              g,
              style: GoogleFonts.dmSans(
                fontSize: 10.5,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  const _MetaInfo({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.year,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.duration,
          style: GoogleFonts.dmSans(fontSize: 12, color: Colors.white38),
        ),
      ],
    );
  }
}

class _TrailerButton extends StatelessWidget {
  const _TrailerButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('[SwipeCard] Play Trailer tapped');
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _accent.withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 5),
            Text(
              'Play Trailer',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({
    required this.label,
    required this.color,
    required this.angleDeg,
    required this.alignment,
    required this.opacity,
  });

  final String label;
  final Color color;
  final double angleDeg;
  final Alignment alignment;
  final double opacity;

  factory _SwipeStamp.save({required double opacity}) => _SwipeStamp(
    label: 'SAVE ✓',
    color: WatchLaterPalette.success,
    angleDeg: -15,
    alignment: Alignment.topLeft,
    opacity: opacity,
  );

  factory _SwipeStamp.skip({required double opacity}) => _SwipeStamp(
    label: 'SKIP ✗',
    color: WatchLaterPalette.danger,
    angleDeg: 15,
    alignment: Alignment.topRight,
    opacity: opacity,
  );

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Transform.rotate(
            angle: angleDeg * math.pi / 180,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 3),
                borderRadius: BorderRadius.circular(8),
                color: color.withValues(alpha: 0.08),
              ),
              child: Text(
                label,
                style: GoogleFonts.bebasNeue(
                  fontSize: 34,
                  color: color,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
