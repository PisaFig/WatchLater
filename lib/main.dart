import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/content_item.dart';
import 'providers/preferences_provider.dart';
import 'providers/watchlist_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/watchlist_screen.dart';
import 'theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ContentItemAdapter());

  final watchlistProvider = WatchlistProvider();
  final preferencesProvider = PreferencesProvider();

  await Future.wait([
    watchlistProvider.loadWatchlist(),
    preferencesProvider.loadPreferences(),
  ]);

  runApp(
    WatchLaterApp(
      watchlistProvider: watchlistProvider,
      preferencesProvider: preferencesProvider,
    ),
  );
}

// ---------------------------------------------------------------------------
// Root app — StatefulWidget so the GoRouter can be created once and hold a
// reference to the preferencesProvider for its redirect callback.
// ---------------------------------------------------------------------------

class WatchLaterApp extends StatefulWidget {
  const WatchLaterApp({
    super.key,
    required this.watchlistProvider,
    required this.preferencesProvider,
  });

  final WatchlistProvider watchlistProvider;
  final PreferencesProvider preferencesProvider;

  @override
  State<WatchLaterApp> createState() => _WatchLaterAppState();
}

class _WatchLaterAppState extends State<WatchLaterApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      // Start at /discover; the redirect below immediately bounces to
      // /onboarding if the user hasn't completed it yet.
      initialLocation: '/discover',

      // Re-evaluate the redirect whenever PreferencesProvider notifies
      // (e.g. after completeOnboarding() or resetPreferences()).
      refreshListenable: widget.preferencesProvider,

      redirect: (context, state) {
        final done = widget.preferencesProvider.hasCompletedOnboarding;
        final loc = state.matchedLocation;
        final isEditMode = state.extra == true;

        // Not onboarded → force to /onboarding (unless already there).
        if (!done && loc != '/onboarding') return '/onboarding';

        // Onboarded + at /onboarding in normal flow → send to /discover.
        // Edit-mode visits (extra == true) are allowed through.
        if (done && loc == '/onboarding' && !isEditMode) return '/discover';

        return null; // no redirect needed
      },

      routes: [
        // ── Outside the shell ─────────────────────────────────────────────
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => _fadePage(
            state,
            OnboardingScreen(isEditMode: state.extra as bool? ?? false),
          ),
        ),
        GoRoute(
          path: '/detail',
          pageBuilder: (context, state) => _slidePage(
            state,
            DetailScreen(item: state.extra as ContentItem?),
          ),
        ),

        // ── Shell (bottom nav) ────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) =>
              _AppShell(location: state.matchedLocation, child: child),
          routes: [
            GoRoute(
              path: '/discover',
              pageBuilder: (context, state) =>
                  _fadePage(state, const DiscoverScreen()),
            ),
            GoRoute(
              path: '/watchlist',
              pageBuilder: (context, state) =>
                  _fadePage(state, const WatchlistScreen()),
            ),
            GoRoute(
              path: '/preferences',
              pageBuilder: (context, state) =>
                  _fadePage(state, const PreferencesScreen()),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) =>
                  _fadePage(state, const SettingsScreen()),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.watchlistProvider),
        ChangeNotifierProvider.value(value: widget.preferencesProvider),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, prefs, child) => MaterialApp.router(
          title: 'WatchLater',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          theme: WatchLaterTheme.build(prefs.isDarkMode),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page transition helpers
// ---------------------------------------------------------------------------

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, _, child) {
      final slide = Tween(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

// ---------------------------------------------------------------------------
// Shell — wraps the active tab screen with the persistent bottom nav bar.
// ---------------------------------------------------------------------------

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child, required this.location});

  final Widget child;
  final String location;

  static const _tabs = [
    (path: '/discover', emoji: '🔍', label: 'Discover'),
    (path: '/watchlist', emoji: '🔖', label: 'Watchlist'),
    (path: '/preferences', emoji: '🎯', label: 'Preferences'),
    (path: '/settings', emoji: '⚙️', label: 'Settings'),
  ];

  int get _currentIndex {
    final idx = _tabs.indexWhere((t) => location.startsWith(t.path));
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: child,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => context.go(_tabs[i].path),
        tabs: _tabs,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom bottom navigation bar
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });

  final int currentIndex;
  final void Function(int) onTap;
  final List<({String path, String emoji, String label})> tabs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: tabs.asMap().entries.map((entry) {
              final i = entry.key;
              final tab = entry.value;
              final selected = i == currentIndex;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tab.emoji,
                        style: TextStyle(fontSize: selected ? 22 : 20),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: selected ? 16 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
