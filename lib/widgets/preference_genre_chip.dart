import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreferenceGenreChip extends StatelessWidget {
  const PreferenceGenreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      scale: isSelected ? 1.03 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 190),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? accent.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.065),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? accent
                    : Colors.white.withValues(alpha: 0.12),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: isSelected
                      ? const Padding(
                          key: ValueKey('selected-icon'),
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty-icon')),
                ),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.66),
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
