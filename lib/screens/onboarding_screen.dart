import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/preferences_provider.dart';
import '../theme/app_theme.dart';

const _accent = WatchLaterPalette.accent;

class _TypeMeta {
  final String type;
  final String label;
  final String emoji;
  final List<Color> gradient;
  final List<String> genres;

  const _TypeMeta({
    required this.type,
    required this.label,
    required this.emoji,
    required this.gradient,
    required this.genres,
  });
}

const _allTypes = [
  _TypeMeta(
    type: 'movie',
    label: 'Movies',
    emoji: '🎬',
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
  _TypeMeta(
    type: 'anime',
    label: 'Anime',
    emoji: '🎌',
    gradient: WatchLaterPalette.animeGradient,
    genres: ['Shonen', 'Isekai', 'Slice of Life', 'Mecha', 'Fantasy', 'Horror'],
  ),
  _TypeMeta(
    type: 'tvshow',
    label: 'TV Shows',
    emoji: '📺',
    gradient: WatchLaterPalette.tvGradient,
    genres: ['Drama', 'Reality', 'Crime', 'Sitcom', 'Fantasy', 'Sci-Fi'],
  ),
  _TypeMeta(
    type: 'sports',
    label: 'Sports',
    emoji: '⚽',
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

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, this.isEditMode = false});

  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: _OnboardingBody(isEditMode: isEditMode)),
    );
  }
}

class _OnboardingBody extends StatelessWidget {
  const _OnboardingBody({required this.isEditMode});

  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    final hasSelection = prefs.selectedContentTypes.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditMode)
                  _EditModeHeader()
                else ...[
                  _Logo(),
                  const SizedBox(height: 8),
                  _Subtitle(),
                ],
                const SizedBox(height: 32),
                _SectionHeading('What do you love?'),
                const SizedBox(height: 16),
                _TwoColumnGrid(prefs: prefs),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _StartButton(enabled: hasSelection, isEditMode: isEditMode),
      ],
    );
  }
}

class _EditModeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final canPop = context.canPop();
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        if (canPop) ...[
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: onSurface.withValues(alpha: 0.24)),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_rounded,
                color: onSurface.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Text(
          canPop ? 'Edit Preferences' : 'Preferences',
          style: GoogleFonts.bebasNeue(
            fontSize: 28,
            color: onSurface,
            letterSpacing: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'WatchLater',
      style: GoogleFonts.bebasNeue(
        fontSize: 56,
        letterSpacing: 3,
        color: Colors.white,
        shadows: const [
          Shadow(color: _accent, blurRadius: 18),
          Shadow(color: _accent, blurRadius: 40),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, duration: 600.ms);
  }
}

class _Subtitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Pick what you love. Swipe what\'s next.',
      style: GoogleFonts.dmSans(
        fontSize: 15,
        color: Colors.white54,
        letterSpacing: 0.3,
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
        letterSpacing: 1.4,
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
  }
}

class _TwoColumnGrid extends StatelessWidget {
  const _TwoColumnGrid({required this.prefs});
  final PreferencesProvider prefs;

  @override
  Widget build(BuildContext context) {
    final leftTypes = [_allTypes[0], _allTypes[2]];
    final rightTypes = [_allTypes[1], _allTypes[3]];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _TypeColumn(types: leftTypes, prefs: prefs, animOffset: 0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeColumn(types: rightTypes, prefs: prefs, animOffset: 1),
        ),
      ],
    );
  }
}

class _TypeColumn extends StatelessWidget {
  const _TypeColumn({
    required this.types,
    required this.prefs,
    required this.animOffset,
  });

  final List<_TypeMeta> types;
  final PreferencesProvider prefs;
  final int animOffset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final meta in types) ...[
          _ContentTypeCard(
            meta: meta,
            isSelected: prefs.selectedContentTypes.contains(meta.type),
            onTap: () => _handleTypeToggle(context, meta, prefs),
            animDelay: (animOffset + types.indexOf(meta) * 2) * 100,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: prefs.selectedContentTypes.contains(meta.type)
                ? _GenreSection(meta: meta, prefs: prefs)
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  void _handleTypeToggle(
    BuildContext context,
    _TypeMeta meta,
    PreferencesProvider prefs,
  ) {
    final wasSelected = prefs.selectedContentTypes.contains(meta.type);
    prefs.toggleContentType(meta.type);
    if (wasSelected) {
      for (final genre in meta.genres) {
        if (prefs.selectedGenres.contains(genre)) {
          prefs.toggleGenre(genre);
        }
      }
    }
  }
}

class _ContentTypeCard extends StatelessWidget {
  const _ContentTypeCard({
    required this.meta,
    required this.isSelected,
    required this.onTap,
    required this.animDelay,
  });

  final _TypeMeta meta;
  final bool isSelected;
  final VoidCallback onTap;
  final int animDelay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: meta.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _accent : Colors.white12,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(meta.emoji, style: const TextStyle(fontSize: 28)),
                      Text(
                        meta.label,
                        style: GoogleFonts.bebasNeue(
                          fontSize: 20,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 10,
                    right: 10,
                    child:
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: _accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ).animate().scale(
                          duration: 200.ms,
                          curve: Curves.elasticOut,
                        ),
                  ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: animDelay),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.15,
          delay: Duration(milliseconds: animDelay),
          duration: 400.ms,
        );
  }
}

class _GenreSection extends StatelessWidget {
  const _GenreSection({required this.meta, required this.prefs});
  final _TypeMeta meta;
  final PreferencesProvider prefs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: meta.genres.asMap().entries.map((entry) {
          final index = entry.key;
          final genre = entry.value;
          final active = prefs.selectedGenres.contains(genre);

          return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  prefs.toggleGenre(genre);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? _accent.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? _accent : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    genre,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? Colors.white : Colors.white60,
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 60 * index),
                duration: 300.ms,
              )
              .slideY(
                begin: 0.4,
                delay: Duration(milliseconds: 60 * index),
                duration: 300.ms,
                curve: Curves.easeOut,
              );
        }).toList(),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.enabled, this.isEditMode = false});
  final bool enabled;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final label = isEditMode ? 'Save Preferences' : 'Start Discovering  →';

    return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: enabled ? 1.0 : 0.35,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: enabled ? () => _handlePress(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  disabledBackgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: enabled ? 8 : 0,
                  shadowColor: _accent.withValues(alpha: 0.5),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 600.ms, duration: 500.ms)
        .slideY(begin: 0.3, delay: 600.ms, duration: 500.ms);
  }

  void _handlePress(BuildContext context) {
    if (isEditMode) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/discover');
      }
    } else {
      context.read<PreferencesProvider>().completeOnboarding();
      context.go('/discover');
    }
  }
}
