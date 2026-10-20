import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'pages/admin/admin_page.dart';
import 'pages/bio_page.dart';
import 'pages/brands_page.dart';
import 'pages/home_page.dart';
import 'pages/quote_page.dart';
import 'pages/rooms_page.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/site_theme.dart';

/// Permette il trascinamento con il mouse nei caroselli (di default solo touch).
class _AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

CustomTransitionPage<void> _fade(GoRouterState s, Widget child) =>
    CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, a, _, c) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: c,
      ),
    );

GoRouter buildRouter(AppState state) => GoRouter(
  redirect: (context, s) {
    final q = s.uri.queryParameters;
    if (q.isNotEmpty) {
      // Fuori dalla costruzione della pagina: lo stato avvisa chi ascolta.
      scheduleMicrotask(() => state.applyLinkParams(q));
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', pageBuilder: (c, s) => _fade(s, const HomePage())),
    GoRoute(
      path: '/ambienti',
      pageBuilder: (c, s) => _fade(s, const RoomsPage()),
      routes: [
        GoRoute(
          path: ':id',
          pageBuilder: (c, s) => _fade(
            s,
            RoomPage(
              key: ValueKey(s.pathParameters['id']),
              id: s.pathParameters['id']!,
            ),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/marchi',
      pageBuilder: (c, s) => _fade(s, const BrandsPage()),
    ),
    GoRoute(
      path: '/biografia',
      pageBuilder: (c, s) => _fade(s, const BioPage()),
    ),
    GoRoute(
      path: '/preventivo',
      pageBuilder: (c, s) => _fade(
        s,
        QuotePage(
          key: ValueKey(s.uri.toString()),
          preService: s.uri.queryParameters['s'],
          prePackage: s.uri.queryParameters['p'],
          preRoom: s.uri.queryParameters['a'],
        ),
      ),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (c, s) =>
          NoTransitionPage(key: s.pageKey, child: const AdminPage(section: null)),
      routes: [
        GoRoute(
          path: ':section',
          pageBuilder: (c, s) => NoTransitionPage(
            key: s.pageKey,
            child: AdminPage(section: s.pathParameters['section']),
          ),
        ),
      ],
    ),
  ],
  errorPageBuilder: (c, s) => _fade(s, const HomePage()),
);

class ShopApp extends StatefulWidget {
  const ShopApp({super.key});

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  late final GoRouter _router = buildRouter(context.read<AppState>());

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp.router(
      onGenerateTitle: (_) =>
          '${state.content.shopName} · ${state.content.tagline}',
      debugShowCheckedModeBanner: false,
      // Cambiando tema i colori sfumano dall'uno all'altro.
      theme: siteThemeData(state.currentTheme),
      themeAnimationDuration: const Duration(milliseconds: 700),
      themeAnimationCurve: Curves.easeInOutCubic,
      builder: (context, child) => ScreenScale(child: child!),
      scrollBehavior: _AppScrollBehavior(),
      locale: const Locale('it', 'IT'),
      supportedLocales: const [Locale('it', 'IT')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
