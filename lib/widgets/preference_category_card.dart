import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/preference_options.dart';
import '../theme/app_theme.dart';

class PreferenceCategoryCard extends StatelessWidget {
  const PreferenceCategoryCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final PreferenceOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = colorScheme.primary;
    final borderColor = isSelected
        ? accent
        : Colors.white.withValues(alpha: 0.10);

    return Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        scale: isSelected ? 1.015 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: option.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 1.7 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.scrim.withValues(alpha: 0.26),
                    blurRadius: 18,
                    offset: const Offset(0, 12),
                  ),
                  if (isSelected)
                    BoxShadow(
                      color: accent.withValues(alpha: 0.36),
                      blurRadius: 26,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -12,
                    bottom: -14,
                    child: Icon(
                      option.icon,
                      size: 82,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Icon(
                              option.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const Spacer(),
                          _SelectionMark(isSelected: isSelected),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        option.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.bebasNeue(
                          color: Colors.white,
                          fontSize: 26,
                          letterSpacing: 0.8,
                          height: 0.95,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontSize: 11.5,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  const _SelectionMark({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : context.appColors.scrim.withValues(alpha: 0.18),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.64)
              : Colors.white24,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: isSelected
            ? const Icon(
                Icons.check_rounded,
                key: ValueKey('checked'),
                size: 18,
                color: Colors.white,
              )
            : Icon(
                Icons.add_rounded,
                key: const ValueKey('unchecked'),
                size: 18,
                color: Colors.white.withValues(alpha: 0.68),
              ),
      ),
    );
  }
}
