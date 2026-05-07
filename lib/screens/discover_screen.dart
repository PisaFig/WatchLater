import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/content_item.dart';
import '../providers/preferences_provider.dart';
import '../providers/watchlist_provider.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';
import '../widgets/swipe_card.dart';
import '../widgets/trailer_bottom_sheet.dart';

const _accent = WatchLaterPalette.accent;

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _controller = CardSwiperController();

  List<ContentItem> _allContent = [];
  List<ContentItem> _cards = [];

  bool _loading = true;
  String? _error;
  bool _exhausted = false;
  bool _lastWasSkip = false;
  bool _noResults = false;
  bool _contentLoaded = false;

  int _deckKey = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_contentLoaded) {
      _contentLoaded = true;
      _loadContent();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await ContentService.fetchAll();
      if (!mounted) return;
      final deck = _buildDeckFrom(items);
      setState(() {
        _allContent = items;
        _cards = deck;
        _noResults = deck.isEmpty;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load content.\nPlease check your connection.';
      });
    }
  }

  void _retryLoad() {
    ContentService.invalidate();
    _loadContent();
  }

  List<ContentItem> _buildDeck() => _buildDeckFrom(_allContent);

  List<ContentItem> _buildDeckFrom(List<ContentItem> source) {
    final prefs = context.read<PreferencesProvider>();
    final types = prefs.selectedContentTypes;
    final genres = prefs.selectedGenres;

    var items = source;
    if (types.isNotEmpty) {
      items = items.where((i) => types.contains(i.contentType)).toList();
    }
    if (genres.isNotEmpty) {
      items = items.where((i) => i.genres.any(genres.contains)).toList();
    }
    return [...items]..shuffle();
  }

  bool _onSwipe(int prevIdx, int? currIdx, CardSwiperDirection dir) {
    if (!mounted) return false;
    final item = _cards[prevIdx];

    if (dir.isCloseTo(CardSwiperDirection.right)) {
      HapticFeedback.mediumImpact();
      context.read<WatchlistProvider>().addToWatchlist(item);
      _lastWasSkip = false;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(_savedSnackBar(item.title));
    } else if (dir.isCloseTo(CardSwiperDirection.left)) {
      HapticFeedback.lightImpact();
      _lastWasSkip = true;
    }

    setState(() {});
    return true;
  }

  void _onEnd() => setState(() => _exhausted = true);

  bool _onUndo(int? prevIdx, int currIdx, CardSwiperDirection dir) {
    setState(() => _lastWasSkip = false);
    return true;
  }

  void _save() => _controller.swipe(CardSwiperDirection.right);
  void _skip() => _controller.swipe(CardSwiperDirection.left);

  void _undo() {
    if (!_lastWasSkip) return;
    _controller.undo();
  }

  void _shuffleAgain() {
    final deck = _buildDeck();
    setState(() {
      _noResults = deck.isEmpty;
      _cards = deck;
      _exhausted = false;
      _lastWasSkip = false;
      _deckKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showEmpty = _exhausted || _noResults;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            if (_loading)
              const Expanded(child: _LoadingState())
            else if (_error != null)
              Expanded(
                child: _ErrorState(message: _error!, onRetry: _retryLoad),
              )
            else if (showEmpty)
              Expanded(
                child: _EmptyState(
                  onShuffle: _shuffleAgain,
                  noResults: _noResults,
                ),
              )
            else
              Expanded(
                child: CardSwiper(
                  key: ValueKey(_deckKey),
                  controller: _controller,
                  cardsCount: _cards.length,
                  numberOfCardsDisplayed: math.min(2, _cards.length),
                  isLoop: false,
                  scale: 0.95,
                  backCardOffset: const Offset(0, 28),
                  maxAngle: 30,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  onSwipe: _onSwipe,
                  onEnd: _onEnd,
                  onUndo: _onUndo,
                  cardBuilder: (context, index, hOffset, vOffset) {
                    final item = _cards[index];
                    return SwipeCard(
                      item: item,
                      onSave: _save,
                      onSkip: _skip,
                      onTrailerTap: () =>
                          TrailerBottomSheet.show(context, item),
                      horizontalOffsetPercentage: hOffset,
                    );
                  },
                ),
              ),
            if (!_loading && _error == null)
              _ActionBar(
                onSkip: _skip,
                onSave: _save,
                onUndo: _lastWasSkip ? _undo : null,
              ),
          ],
        ),
      ),
    );
  }

  SnackBar _savedSnackBar(String title) => SnackBar(
    content: Text(
      '$title added to Watchlist!',
      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
    ),
    backgroundColor: WatchLaterPalette.snackbar,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(seconds: 2),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 4),
      child: Row(
        children: [
          Text(
            'WatchLater',
            style: GoogleFonts.bebasNeue(
              fontSize: 32,
              letterSpacing: 2,
              color: Theme.of(context).colorScheme.onSurface,
              shadows: const [Shadow(color: _accent, blurRadius: 14)],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.onSkip,
    required this.onSave,
    required this.onUndo,
  });

  final VoidCallback onSkip;
  final VoidCallback onSave;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionButton(
            icon: Icons.close_rounded,
            diameter: 56,
            color: Colors.white,
            filled: false,
            onTap: onSkip,
          ),
          const SizedBox(width: 22),
          _ActionButton(
            icon: Icons.replay_rounded,
            diameter: 42,
            color: onUndo != null
                ? Colors.white60
                : Colors.white.withValues(alpha: 0.18),
            filled: false,
            onTap: onUndo,
          ),
          const SizedBox(width: 22),
          _ActionButton(
            icon: Icons.favorite_rounded,
            diameter: 56,
            color: _accent,
            filled: true,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.diameter,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final double diameter;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? color : Colors.transparent,
          border: filled ? null : Border.all(color: color, width: 2),
          boxShadow: filled && onTap != null
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.40),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: filled ? Colors.white : color,
          size: diameter * 0.44,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(color: _accent, strokeWidth: 2.5),
          ),
          const SizedBox(height: 20),
          Text(
            'Fetching content…',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.bebasNeue(
                fontSize: 26,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.38),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 8,
                shadowColor: _accent.withValues(alpha: 0.4),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onShuffle, this.noResults = false});
  final VoidCallback onShuffle;
  final bool noResults;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(noResults ? '🎯' : '🎬', style: const TextStyle(fontSize: 72)),
            const SizedBox(height: 20),
            Text(
              noResults ? 'No matches found' : "You've seen it all!",
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              noResults
                  ? 'No content matches your preferences.\nUpdate them in Settings.'
                  : 'No more cards to swipe.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.38),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: noResults
                  ? ElevatedButton.icon(
                      onPressed: () => context.go('/settings'),
                      icon: const Icon(Icons.tune_rounded),
                      label: Text(
                        'Update Preferences',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        shadowColor: _accent.withValues(alpha: 0.4),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: onShuffle,
                      icon: const Icon(Icons.shuffle_rounded),
                      label: Text(
                        'Shuffle Again',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        shadowColor: _accent.withValues(alpha: 0.4),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
