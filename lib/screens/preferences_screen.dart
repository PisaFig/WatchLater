import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/preference_options.dart';
import '../providers/preferences_provider.dart';
import '../services/trailer_preload_service.dart';
import '../theme/app_theme.dart';
import '../widgets/preference_category_card.dart';
import '../widgets/preference_genre_chip.dart';

void _preloadTrailersForCurrentPreferences(
  BuildContext context,
  PreferencesProvider prefs,
) {
  unawaited(
    TrailerPreloadService.preloadForPreferences(
      context,
      selectedTypes: List<String>.from(prefs.selectedContentTypes),
      selectedGenres: List<String>.from(prefs.selectedGenres),
    ),
  );
}

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SafeArea(bottom: false, child: _PreferencesView()),
    );
  }
}

class _PreferencesView extends StatelessWidget {
  const _PreferencesView();

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();
    final selectedTypes = prefs.selectedContentTypes.length;
    final selectedGenres = prefs.selectedGenres.length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          sliver: SliverToBoxAdapter(
            child: _Header(
              selectedTypes: selectedTypes,
              selectedGenres: selectedGenres,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          sliver: SliverToBoxAdapter(child: _CategoryGrid(prefs: prefs)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(child: _GenrePanel(prefs: prefs)),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 28),
          sliver: SliverToBoxAdapter(child: _AutosaveRow()),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.selectedTypes, required this.selectedGenres});

  final int selectedTypes;
  final int selectedGenres;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 42,
                      letterSpacing: 1,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tune your discovery feed with the categories and genres you actually watch.',
                    style: GoogleFonts.dmSans(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 14,
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            _PreferenceCounter(
              selectedTypes: selectedTypes,
              selectedGenres: selectedGenres,
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _SectionTitle(
          label: 'Choose your lanes',
          icon: Icons.grid_view_rounded,
        ),
      ],
    ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.08, duration: 260.ms);
  }
}

class _PreferenceCounter extends StatelessWidget {
  const _PreferenceCounter({
    required this.selectedTypes,
    required this.selectedGenres,
  });

  final int selectedTypes;
  final int selectedGenres;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 74,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: context.appColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            '$selectedTypes',
            style: GoogleFonts.bebasNeue(
              color: colorScheme.primary,
              fontSize: 28,
              height: 0.9,
              letterSpacing: 0.7,
            ),
          ),
          Text(
            'types',
            style: GoogleFonts.dmSans(
              color: Colors.white.withValues(alpha: 0.46),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            width: 24,
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white.withValues(alpha: 0.08),
          ),
          Text(
            '$selectedGenres',
            style: GoogleFonts.bebasNeue(
              color: Colors.white,
              fontSize: 24,
              height: 0.9,
              letterSpacing: 0.7,
            ),
          ),
          Text(
            'genres',
            style: GoogleFonts.dmSans(
              color: Colors.white.withValues(alpha: 0.46),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 17),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            color: Colors.white.withValues(alpha: 0.46),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.prefs});

  final PreferencesProvider prefs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;
        final crossAxisCount = isCompact ? 1 : 2;
        final tileHeight = isCompact ? 136.0 : 164.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: preferenceOptions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: tileHeight,
          ),
          itemBuilder: (context, index) {
            final option = preferenceOptions[index];
            final selected = prefs.selectedContentTypes.contains(option.type);

            return PreferenceCategoryCard(
                  option: option,
                  isSelected: selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    prefs.setContentTypeSelected(
                      option.type,
                      !selected,
                      removedGenres: option.genres,
                    );
                    _preloadTrailersForCurrentPreferences(context, prefs);
                  },
                )
                .animate()
                .fadeIn(delay: (45 * index).ms, duration: 280.ms)
                .slideY(begin: 0.08, delay: (45 * index).ms, duration: 280.ms);
          },
        );
      },
    );
  }
}

class _GenrePanel extends StatelessWidget {
  const _GenrePanel({required this.prefs});

  final PreferencesProvider prefs;

  @override
  Widget build(BuildContext context) {
    final selectedOptions = preferenceOptions
        .where((option) => prefs.selectedContentTypes.contains(option.type))
        .toList();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: selectedOptions.isEmpty
          ? const _EmptyGenreState(key: ValueKey('empty-genres'))
          : _SelectedGenreSections(
              key: const ValueKey('selected-genres'),
              prefs: prefs,
              selectedOptions: selectedOptions,
            ),
    );
  }
}

class _SelectedGenreSections extends StatelessWidget {
  const _SelectedGenreSections({
    super.key,
    required this.prefs,
    required this.selectedOptions,
  });

  final PreferencesProvider prefs;
  final List<PreferenceOption> selectedOptions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: context.appColors.scrim.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            label: 'Refine by genre',
            icon: Icons.tune_rounded,
          ),
          const SizedBox(height: 16),
          for (final option in selectedOptions) ...[
            _GenreGroup(option: option, prefs: prefs),
            if (option != selectedOptions.last)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.04, duration: 260.ms);
  }
}

class _GenreGroup extends StatelessWidget {
  const _GenreGroup({required this.option, required this.prefs});

  final PreferenceOption option;
  final PreferencesProvider prefs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              option.icon,
              color: Colors.white.withValues(alpha: 0.78),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              option.label,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: option.genres.map((genre) {
            final selected = prefs.selectedGenres.contains(genre);
            return PreferenceGenreChip(
              label: genre,
              isSelected: selected,
              onTap: () {
                HapticFeedback.selectionClick();
                prefs.toggleGenre(genre);
                _preloadTrailersForCurrentPreferences(context, prefs);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _EmptyGenreState extends StatelessWidget {
  const _EmptyGenreState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appColors.panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.touch_app_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Select at least one category to reveal genre filters.',
              style: GoogleFonts.dmSans(
                color: Colors.white.withValues(alpha: 0.64),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutosaveRow extends StatelessWidget {
  const _AutosaveRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_done_rounded,
            color: WatchLaterPalette.success,
            size: 17,
          ),
          const SizedBox(width: 7),
          Text(
            'Preferences save automatically on this device',
            style: GoogleFonts.dmSans(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
