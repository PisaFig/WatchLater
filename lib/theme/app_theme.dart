import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WatchLaterPalette {
  WatchLaterPalette._();

  static const accent = Color(0xFF7C3AED);
  static const accentSoft = Color(0xFF8B5CF6);
  static const darkBackground = Color(0xFF0D0D1A);
  static const darkBackgroundDeep = Color(0xFF090911);
  static const darkSurface = Color(0xFF1A1A2E);
  static const darkPanel = Color(0xFF121222);
  static const darkPanelAlt = Color(0xFF12122A);
  static const darkOutline = Color(0xFF252540);
  static const snackbar = Color(0xFF1E1E2E);
  static const shimmerHighlight = Color(0xFF2A2A3E);
  static const cardShimmerHighlight = Color(0xFF2D2D4A);
  static const success = Color(0xFF22C55E);
  static const danger = Color(0xFFEF4444);
  static const overlayMid = Color(0x66000000);
  static const overlayStrong = Color(0xD9000000);
  static const overlayExtraStrong = Color(0xE8000000);

  static const lightBackground = Color(0xFFF5F3FF);
  static const lightSurface = Color(0xFFEDE9FE);
  static const lightText = Color(0xFF1A1A2E);
  static const lightOutline = Color(0xFFDDD8F0);

  static const movieGradient = [Color(0xFF22114C), Color(0xFF5B21B6)];
  static const animeGradient = [Color(0xFF3D1027), Color(0xFF9D174D)];
  static const tvGradient = [Color(0xFF0E2148), Color(0xFF155E75)];
  static const sportsGradient = [Color(0xFF0B2F1E), Color(0xFF15803D)];
}

@immutable
class WatchLaterColors extends ThemeExtension<WatchLaterColors> {
  const WatchLaterColors({
    required this.success,
    required this.danger,
    required this.scrim,
    required this.panel,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  final Color success;
  final Color danger;
  final Color scrim;
  final Color panel;
  final Color shimmerBase;
  final Color shimmerHighlight;

  @override
  WatchLaterColors copyWith({
    Color? success,
    Color? danger,
    Color? scrim,
    Color? panel,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return WatchLaterColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      scrim: scrim ?? this.scrim,
      panel: panel ?? this.panel,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  WatchLaterColors lerp(ThemeExtension<WatchLaterColors>? other, double t) {
    if (other is! WatchLaterColors) return this;
    return WatchLaterColors(
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      panel: Color.lerp(panel, other.panel, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
    );
  }
}

extension WatchLaterThemeContext on BuildContext {
  WatchLaterColors get appColors =>
      Theme.of(this).extension<WatchLaterColors>()!;
}

class WatchLaterTheme {
  WatchLaterTheme._();

  static ThemeData build(bool isDark) {
    if (isDark) {
      return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: WatchLaterPalette.darkBackground,
        colorScheme: const ColorScheme.dark(
          surface: WatchLaterPalette.darkBackground,
          surfaceContainerHighest: WatchLaterPalette.darkSurface,
          primary: WatchLaterPalette.accent,
          secondary: WatchLaterPalette.accent,
          onSurface: Colors.white,
          outline: WatchLaterPalette.darkOutline,
        ),
        dividerColor: WatchLaterPalette.darkOutline,
        textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme)
            .copyWith(
              displayLarge: GoogleFonts.bebasNeue(color: Colors.white),
              displayMedium: GoogleFonts.bebasNeue(color: Colors.white),
              displaySmall: GoogleFonts.bebasNeue(color: Colors.white),
            ),
        extensions: const [
          WatchLaterColors(
            success: WatchLaterPalette.success,
            danger: WatchLaterPalette.danger,
            scrim: Colors.black,
            panel: WatchLaterPalette.darkPanel,
            shimmerBase: WatchLaterPalette.darkSurface,
            shimmerHighlight: WatchLaterPalette.shimmerHighlight,
          ),
        ],
        useMaterial3: true,
      );
    }

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: WatchLaterPalette.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: WatchLaterPalette.lightBackground,
        surfaceContainerHighest: WatchLaterPalette.lightSurface,
        primary: WatchLaterPalette.accent,
        secondary: WatchLaterPalette.accent,
        onSurface: WatchLaterPalette.lightText,
        outline: WatchLaterPalette.lightOutline,
      ),
      dividerColor: WatchLaterPalette.lightOutline,
      textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.bebasNeue(
              color: WatchLaterPalette.lightText,
            ),
            displayMedium: GoogleFonts.bebasNeue(
              color: WatchLaterPalette.lightText,
            ),
            displaySmall: GoogleFonts.bebasNeue(
              color: WatchLaterPalette.lightText,
            ),
          ),
      extensions: const [
        WatchLaterColors(
          success: WatchLaterPalette.success,
          danger: WatchLaterPalette.danger,
          scrim: Colors.black,
          panel: WatchLaterPalette.lightSurface,
          shimmerBase: WatchLaterPalette.lightSurface,
          shimmerHighlight: WatchLaterPalette.lightOutline,
        ),
      ],
      useMaterial3: true,
    );
  }
}
