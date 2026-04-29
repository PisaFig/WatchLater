import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../models/content_item.dart';
import '../theme/app_theme.dart';

const _bg = WatchLaterPalette.darkSurface;
const _accent = WatchLaterPalette.accent;

// ---------------------------------------------------------------------------
// Set to true to verify the iframe player works with a known-good video.
// Flip back to false once confirmed working.
// ---------------------------------------------------------------------------
const _useTestId = false;
const _testYoutubeId = 'dQw4w9WgXcQ'; // Rick Astley — reliably works everywhere

class TrailerBottomSheet extends StatefulWidget {
  const TrailerBottomSheet({super.key, required this.item});

  final ContentItem item;

  static void show(BuildContext context, ContentItem item) {
    debugPrint(
      '[Trailer] show() called — title="${item.title}" '
      'id="${item.trailerYoutubeId}"',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (_) => TrailerBottomSheet(item: item),
    );
  }

  @override
  State<TrailerBottomSheet> createState() => _TrailerBottomSheetState();
}

class _TrailerBottomSheetState extends State<TrailerBottomSheet> {
  YoutubePlayerController? _controller;

  // Resolves which YouTube ID to actually load, respecting the test flag.
  String get _resolvedId {
    if (_useTestId) return _testYoutubeId;
    return widget.item.trailerYoutubeId;
  }

  bool get _hasTrailer => _resolvedId.isNotEmpty;

  void _onThumbnailTap() {
    debugPrint(
      '[Trailer] thumbnail tapped — resolved id="$_resolvedId" '
      'hasTrailer=$_hasTrailer',
    );
    if (!_hasTrailer) return;

    setState(() {
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _resolvedId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: false,
          mute: false,
        ),
      );
    });
    debugPrint('[Trailer] YoutubePlayerController created for "$_resolvedId"');
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.87,
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const _DragHandle(),
          _Player(
            item: widget.item,
            controller: _controller,
            hasTrailer: _hasTrailer,
            onThumbnailTap: _onThumbnailTap,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _MetadataSection(item: widget.item),
            ),
          ),
          _CloseButton(onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drag handle
// ---------------------------------------------------------------------------

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Player — three-phase: thumbnail → thumbnail+spinner → player
// Also renders a "no trailer" state when hasTrailer is false.
// ---------------------------------------------------------------------------

class _Player extends StatelessWidget {
  const _Player({
    required this.item,
    required this.controller,
    required this.hasTrailer,
    required this.onThumbnailTap,
  });

  final ContentItem item;
  final YoutubePlayerController? controller;
  final bool hasTrailer;
  final VoidCallback onThumbnailTap;

  String get _previewUrl {
    if (!hasTrailer) return item.posterUrl;
    return 'https://img.youtube.com/vi/${item.trailerYoutubeId}/hqdefault.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Base layer: poster thumbnail — always present so the sheet feels
          // instant to open regardless of network or player state.
          CachedNetworkImage(
            imageUrl: _previewUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: context.appColors.shimmerBase,
              highlightColor: context.appColors.shimmerHighlight,
              child: const ColoredBox(color: Colors.white),
            ),
            errorWidget: (context, url, error) =>
                ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
          ),

          // Phase 2–3: iframe — only mounted after the user taps play.
          if (controller != null) YoutubePlayer(controller: controller!),

          // Phase 2: loading overlay — fades out when the player starts.
          // Uses StreamBuilder to avoid any YoutubeValueBuilder API ambiguity.
          if (controller != null)
            StreamBuilder<YoutubePlayerValue>(
              stream: controller!.stream,
              builder: (context, snapshot) {
                final state = snapshot.data?.playerState;
                debugPrint('[Trailer] playerState=$state');
                final ready =
                    state != null &&
                    state != PlayerState.unknown &&
                    state != PlayerState.unStarted;
                return AnimatedOpacity(
                  opacity: ready ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: _accent,
                            strokeWidth: 2.5,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Loading trailer…',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Phase 1: play-button overlay (shown when no controller yet).
          if (controller == null)
            hasTrailer
                ? GestureDetector(
                    onTap: onThumbnailTap,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                      ),
                      child: Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _accent.withValues(alpha: 0.90),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.55),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  )
                : // No trailer available — show a message over the poster.
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.videocam_off_rounded,
                            color: Colors.white38,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No trailer available\nfor this title.',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white54,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Metadata section (scrollable)
// ---------------------------------------------------------------------------

class _MetadataSection extends StatelessWidget {
  const _MetadataSection({required this.item});
  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          style: GoogleFonts.bebasNeue(
            fontSize: 26,
            color: Colors.white,
            letterSpacing: 1.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              item.rating.toStringAsFixed(1),
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            _dot(),
            Text(
              item.year,
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white54),
            ),
            _dot(),
            Text(
              item.duration,
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: item.genres.map((g) => _GenreChip(genre: g)).toList(),
        ),
        const SizedBox(height: 16),
        Text(
          item.description,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.75),
            height: 1.55,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _dot() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text('·', style: TextStyle(color: Colors.white38, fontSize: 14)),
  );
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.genre});
  final String genre;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withValues(alpha: 0.65)),
        color: _accent.withValues(alpha: 0.12),
      ),
      child: Text(
        genre,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          color: Colors.white.withValues(alpha: 0.85),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Close button
// ---------------------------------------------------------------------------

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Text(
            'Close',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
