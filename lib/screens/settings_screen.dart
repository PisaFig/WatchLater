import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/preferences_provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';

const _surface = WatchLaterPalette.darkPanelAlt;
const _accent = WatchLaterPalette.accent;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  SizedBox(height: 8),
                  _DarkModeTile(),
                  _RowDivider(),
                  _ClearWatchlistTile(),
                  _RowDivider(),
                  _AboutTile(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 6),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/discover');
              }
            },
          ),
          const SizedBox(width: 4),
          Text(
            'Settings',
            style: GoogleFonts.bebasNeue(
              fontSize: 30,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor,
      indent: 56,
    );
  }
}

class _TileBase extends StatelessWidget {
  const _TileBase({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: _accent.withValues(alpha: 0.08),
      highlightColor: _accent.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 17)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _DarkModeTile extends StatelessWidget {
  const _DarkModeTile();

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesProvider>();

    return _TileBase(
      emoji: '🌙',
      title: 'Dark Mode',
      subtitle: 'Toggle light / dark appearance',
      onTap: () => prefs.setDarkMode(!prefs.isDarkMode),
      trailing: Switch(
        value: prefs.isDarkMode,
        onChanged: prefs.setDarkMode,
        activeThumbColor: Colors.white,
        activeTrackColor: _accent,
        inactiveThumbColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.38),
        inactiveTrackColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.12),
      ),
    );
  }
}

class _ClearWatchlistTile extends StatelessWidget {
  const _ClearWatchlistTile();

  @override
  Widget build(BuildContext context) {
    return _TileBase(
      emoji: '🗑',
      title: 'Clear Watchlist',
      subtitle: 'Remove all saved items permanently',
      onTap: () => _confirm(context),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white38,
        size: 20,
      ),
    );
  }

  void _confirm(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear Watchlist?',
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          'All saved items will be permanently removed. This cannot be undone.',
          style: GoogleFonts.dmSans(color: Colors.white60, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<WatchlistProvider>().clearAll();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'Watchlist cleared',
                      style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: WatchLaterPalette.snackbar,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
            },
            child: Text(
              'Clear All',
              style: GoogleFonts.dmSans(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile();

  @override
  Widget build(BuildContext context) {
    return _TileBase(
      emoji: 'ℹ️',
      title: 'About WatchLater',
      subtitle: 'Version 1.0.0',
      onTap: () => _showAbout(context),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white38,
        size: 20,
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              'WatchLater',
              style: GoogleFonts.bebasNeue(
                fontSize: 36,
                color: Colors.white,
                letterSpacing: 2,
                shadows: const [
                  Shadow(color: WatchLaterPalette.accent, blurRadius: 20),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.dmSans(fontSize: 13, color: Colors.white38),
            ),
            const SizedBox(height: 16),
            Text(
              'Swipe. Save. Watch.',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.dmSans(
                color: _accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
