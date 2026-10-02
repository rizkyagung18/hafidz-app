import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hafidz_app/features/learning/presentation/learning_screen.dart';
import 'package:hafidz_app/features/more/presentation/content_screens.dart';
import 'package:hafidz_app/features/more/presentation/more_screen.dart';
import 'package:hafidz_app/features/prayer/presentation/prayer_screens.dart';
import 'package:hafidz_app/features/qibla/presentation/qibla_screen.dart';
import 'package:hafidz_app/features/quran/presentation/quran_screens.dart';
import 'package:hafidz_app/features/settings/presentation/settings_screen.dart';
import 'package:hafidz_app/features/voice/presentation/voice_screens.dart';
import 'package:hafidz_app/shared/widgets/app_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// go_router configuration per docs/07 §1–§2.
GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    redirect: (context, state) {
      final uri = state.uri;
      if (uri.scheme == 'hafidz' && uri.host.isNotEmpty) {
        final path = '/${uri.host}${uri.path == '/' ? '' : uri.path}';
        return Uri(
          path: path,
          query: uri.hasQuery ? uri.query : null,
          fragment: uri.hasFragment ? uri.fragment : null,
        ).toString();
      }
      if (uri.path == '/') return '/quran';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/quran',
                name: 'quran',
                builder: (context, state) => const QuranScreen(),
                routes: [
                  GoRoute(
                    path: 'surah/:n',
                    name: 'quran-surah',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final surah = int.parse(state.pathParameters['n']!);
                      final ayah = int.tryParse(
                        state.uri.queryParameters['ayah'] ?? '',
                      );
                      return QuranSurahScreen(surah: surah, ayah: ayah);
                    },
                  ),
                  GoRoute(
                    path: 'page/:p',
                    name: 'quran-page',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final page =
                          int.tryParse(state.pathParameters['p']!) ?? 0;
                      return QuranPageScreen(
                        page: page,
                        ayah: state.uri.queryParameters['ayah'],
                        highlight: state.uri.queryParameters['hl'] == '1',
                      );
                    },
                  ),
                  GoRoute(
                    path: 'ayah/:key',
                    name: 'quran-ayah',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final key = state.pathParameters['key']!;
                      return QuranAyahScreen(keyRef: key);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prayer',
                name: 'prayer',
                builder: (context, state) => const PrayerScreen(),
                routes: [
                  GoRoute(
                    path: 'month',
                    name: 'prayer-month',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const PrayerMonthScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'prayer-settings',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const PrayerSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'location',
                    name: 'prayer-location',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const PrayerLocationScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learning',
                name: 'learning',
                builder: (context, state) => const LearningScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                name: 'more',
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/qibla',
        name: 'qibla',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QiblaScreen(),
      ),
      GoRoute(
        path: '/voice',
        name: 'voice',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final shared = state.uri.queryParameters['shared'] == '1';
          return VoiceScreen(shared: shared);
        },
        routes: [
          GoRoute(
            path: 'result',
            name: 'voice-result',
            builder: (context, state) => const VoiceResultScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/doa',
        name: 'doa',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DoaListScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: 'doa-detail',
            builder: (context, state) {
              return DoaDetailScreen(id: state.pathParameters['id']!);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/hadith',
        name: 'hadith',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HadithListScreen(),
        routes: [
          GoRoute(
            path: ':book',
            name: 'hadith-book',
            builder: (context, state) {
              return HadithBookScreen(book: state.pathParameters['book']!);
            },
            routes: [
              GoRoute(
                path: ':n',
                name: 'hadith-number',
                builder: (context, state) {
                  return HadithNumberScreen(
                    book: state.pathParameters['book']!,
                    number: state.pathParameters['n']!,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/asmaul-husna',
        name: 'asmaul-husna',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AsmaulHusnaScreen(),
      ),
      GoRoute(
        path: '/tasbih',
        name: 'tasbih',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TasbihScreen(),
      ),
      GoRoute(
        path: '/hijri',
        name: 'hijri',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HijriScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
}
