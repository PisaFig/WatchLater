import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../models/content_item.dart';
import '../services/content_service.dart';
import '../theme/app_theme.dart';

const _accent = WatchLaterPalette.accent;
const _cardBg = WatchLaterPalette.darkSurface;

const _filters = [
  ('All', 'all'),
  ('Movies', 'movie'),
  ('Anime', 'anime'),
  ('TV Shows', 'tvshow'),
  ('Sports', 'sports'),
];

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  List<ContentItem> _allContent = [];
  List<ContentItem> _results = [];
  String _query = '';
  String _activeFilter = 'all';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      final items = await ContentService.fetchAll();
      if (!mounted) return;
      setState(() {
        _allContent = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _onQueryChanged() {
    final q = _controller.text;
    if (q == _query) return;
    setState(() {
      _query = q;
      _results = _filter(q, _activeFilter);
    });
  }

  void _setFilter(String filter) {
    setState(() {
      _activeFilter = filter;
      _results = _filter(_query, filter);
    });
  }

  List<ContentItem> _filter(String query, String filter) {
    var items = _allContent;
    if (filter != 'all') {
      items = items.where((i) => i.contentType == filter).toList();
    }
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return items.where((i) {
      return i.title.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.genres.any((g) => g.toLowerCase().contains(q));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(
              controller: _controller,
              focus: _focus,
              onBack: () => context.pop(),
            ),
            _FilterRow(activeFilter: _activeFilter, onSelect: _setFilter),
            Divider(
              height: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: _accent, strokeWidth: 2.5),
      );
    }
    if (_query.trim().isEmpty) {
      return const _HintState();
    }
    if (_results.isEmpty) {
      return _NoResultsState(query: _query);
    }
    return _ResultsGrid(items: _results);
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focus,
    required this.onBack,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: onBack,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focus,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: GoogleFonts.dmSans(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search movies, shows, anime…',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.38),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 20,
                  ),
                  suffixIcon: ValueListenableBuilder(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: controller.clear,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      );
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.activeFilter, required this.onSelect});
  final String activeFilter;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, key) = _filters[i];
          final active = activeFilter == key;
          return GestureDetector(
            onTap: () => onSelect(key),
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
        },
      ),
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.items});
  final List<ContentItem> items;

  static String _typeEmoji(String type) => switch (type) {
    'movie' => '🎬',
    'anime' => '🎌',
    'tvshow' => '📺',
    'sports' => '⚽',
    _ => '',
  };

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => context.push('/detail', extra: item),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: _cardBg,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white24,
                      size: 36,
                    ),
                  ),
                ),
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
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
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
                      const SizedBox(height: 2),
                      Text(
                        item.year,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HintState extends StatelessWidget {
  const _HintState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Search for anything',
            style: GoogleFonts.bebasNeue(
              fontSize: 26,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Movies, shows, anime, sports…',
            style: GoogleFonts.dmSans(
              fontSize: 13,
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

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              'No results',
              style: GoogleFonts.bebasNeue(
                fontSize: 28,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nothing matched "$query".\nTry a different search.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.38),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
