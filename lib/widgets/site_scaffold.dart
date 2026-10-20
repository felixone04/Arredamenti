import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/site_theme.dart';
import 'brand_logo.dart';
import 'common.dart';
import 'theme_switcher.dart';

Future<void> openUrl(String url) async {
  final t = url.trim();
  var u = Uri.tryParse(t);
  if (u == null || t.isEmpty) return;
  // Link social inseriti senza "https://" (es. instagram.com/negozio): senza
  // schema il browser li tratterebbe come percorsi interni al sito.
  if (!u.hasScheme) u = Uri.tryParse('https://$t');
  if (u == null) return;
  await launchUrl(u, webOnlyWindowName: '_blank');
}

String digitsOf(String s) => s.replaceAll(RegExp(r'[^0-9+]'), '');

String whatsappUrl(String number) =>
    'https://wa.me/${digitsOf(number).replaceAll('+', '')}';

String mapsUrl(String address) =>
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';

const navItems = <(String, String)>[
  ('Home', '/'),
  ('Ambienti', '/ambienti'),
  ('Marchi', '/marchi'),
  ('Biografia', '/biografia'),
  ('Preventivo', '/preventivo'),
];

/// Struttura comune delle pagine pubbliche: barra in alto, contenuto, footer,
/// e i pulsanti fissi (WhatsApp, "Cambia stile").
class SiteScaffold extends StatefulWidget {
  const SiteScaffold({
    super.key,
    required this.location,
    required this.children,
    this.overHero = false,
  });

  final String location;
  final List<Widget> children;

  /// La pagina inizia con una foto a tutto schermo: la barra resta
  /// trasparente (con testi bianchi) finché la foto è visibile.
  final bool overHero;

  @override
  State<SiteScaffold> createState() => _SiteScaffoldState();
}

class _SiteScaffoldState extends State<SiteScaffold> {
  final _scroll = ScrollController();
  bool _scrolled = false;
  bool _pastHero = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_update);
  }

  void _update() {
    final scrolled = _scroll.offset > 10;
    final pastHero =
        _scroll.offset > context.screenH * 0.85 - context.navH;
    if (scrolled != _scrolled || pastHero != _pastHero) {
      setState(() {
        _scrolled = scrolled;
        _pastHero = pastHero;
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final t = context.st;
    final navH = context.navH;
    final clear = widget.overHero && !_pastHero;
    final wa = state.content.contacts.whatsapp.trim();
    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!widget.overHero) SizedBox(height: navH),
                ...widget.children,
                SiteFooter(content: state.content),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              height: navH,
              padding: EdgeInsets.symmetric(horizontal: context.gutter),
              decoration: BoxDecoration(
                color: clear ? Colors.transparent : t.bg.withValues(alpha: 0.97),
                // Sopra la foto un velo scuro rende leggibili i testi bianchi.
                gradient: clear
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.black.withValues(alpha: 0),
                        ],
                      )
                    : null,
                border: Border(
                  bottom: BorderSide(
                    color: _scrolled && !clear ? t.line : Colors.transparent,
                  ),
                ),
              ),
              child: _NavBar(location: widget.location, light: clear),
            ),
          ),
          if (wa.isNotEmpty)
            Positioned(
              right: context.isPhone ? 14 : 24,
              bottom: context.isPhone ? 14 : 24,
              child: _WhatsAppButton(number: wa),
            ),
          if (state.switcherVisible)
            Positioned(
              left: context.isPhone ? 14 : 24,
              bottom: context.isPhone ? 14 : 24,
              child: const ThemeSwitcher(),
            ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.location, required this.light});
  final String location;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final fg = light ? Colors.white : t.ink;
    final compact = context.w < 980;
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              label: 'Home',
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => context.go('/'),
                  child: BrandLogo(
                    size: context.fluid(15, 19),
                    color: fg,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        if (!compact) ...[
          for (final (label, path) in navItems.take(navItems.length - 1)) ...[
            HoverLink(
              label.toUpperCase(),
              active: location == path ||
                  (path != '/' && location.startsWith(path)),
              style: t.label(11.5, color: fg),
              onTap: () => context.go(path),
            ),
            const SizedBox(width: 34),
          ],
          PillButton(
            'Preventivo',
            light: light,
            onTap: () => context.go('/preventivo'),
          ),
        ] else
          _MenuButton(
            color: fg,
            onTap: () => _openMenu(context, location),
          ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap, required this.color});
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Menu',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('MENU', style: context.st.label(11.5, color: color)),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(width: 26, height: 1.6, color: color),
                  const SizedBox(height: 6),
                  Container(width: 16, height: 1.6, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _openMenu(BuildContext context, String location) {
  showGeneralDialog(
    context: context,
    barrierColor: Colors.transparent,
    barrierLabel: 'Chiudi menu',
    transitionDuration: const Duration(milliseconds: 450),
    transitionBuilder: (_, a, _, child) {
      final curved = CurvedAnimation(parent: a, curve: Curves.easeOutQuart);
      return ClipPath(clipper: _RevealClipper(curved.value), child: child);
    },
    pageBuilder: (ctx, _, _) => _FullMenu(location: location),
  );
}

class _RevealClipper extends CustomClipper<Path> {
  _RevealClipper(this.t);
  final double t;
  @override
  Path getClip(Size size) =>
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height * t));
  @override
  bool shouldReclip(_RevealClipper old) => old.t != t;
}

class _FullMenu extends StatelessWidget {
  const _FullMenu({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final c = context.watch<AppState>().content.contacts;
    void go(String path) {
      Navigator.pop(context);
      context.go(path);
    }

    return Material(
      color: t.bg,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: context.navH,
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => go('/'),
                          child: BrandLogo(size: context.fluid(15, 19)),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Chiudi',
                      icon: Icon(Icons.close_rounded, color: t.ink, size: 30),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              for (var i = 0; i < navItems.length; i++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => go(navItems[i].$2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 6, right: 14),
                          child: Text(
                            '0${i + 1}',
                            style: t.label(9, color: t.accentText),
                          ),
                        ),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              navItems[i].$1,
                              style: t.display(
                                38,
                                italic: location == navItems[i].$2,
                                color: location == navItems[i].$2
                                    ? t.ink
                                    : t.muted,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              if (c.phone.isNotEmpty)
                GestureDetector(
                  onTap: () => openUrl('tel:${digitsOf(c.phone)}'),
                  child: Text(c.phone, style: t.body(14.5, color: t.muted)),
                ),
              if (c.email.isNotEmpty) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => openUrl('mailto:${c.email}'),
                  child: Text(c.email, style: t.body(14.5, color: t.muted)),
                ),
              ],
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhatsAppButton extends StatefulWidget {
  const _WhatsAppButton({required this.number});
  final String number;

  @override
  State<_WhatsAppButton> createState() => _WhatsAppButtonState();
}

class _WhatsAppButtonState extends State<_WhatsAppButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final size = context.isPhone ? 52.0 : 58.0;
    return Tooltip(
      message: 'Scrivici su WhatsApp',
      child: Semantics(
        button: true,
        label: 'Scrivici su WhatsApp',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: () => openUrl(whatsappUrl(widget.number)),
            child: AnimatedScale(
              scale: _hover ? 1.08 : 1,
              duration: const Duration(milliseconds: 220),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: size * 0.46,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------- footer

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key, required this.content});
  final SiteContent content;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final c = content.contacts;
    final cols = context.isPhone ? 1 : (context.isTablet ? 2 : 4);

    Widget link(String text, String? url) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: url == null
          ? Text(text, style: t.body(15))
          : HoverLink(text, style: t.body(15), onTap: () => openUrl(url)),
    );

    Widget col(String title, List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: t.label(10.5, color: t.muted)),
        const SizedBox(height: 16),
        ...children,
      ],
    );

    final columns = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BrandLogo(size: 17),
          const SizedBox(height: 18),
          Text(content.footerNote, style: t.body(14, color: t.muted)),
        ],
      ),
      col('Contatti', [
        if (c.phone.isNotEmpty) link(c.phone, 'tel:${digitsOf(c.phone)}'),
        if (c.email.isNotEmpty) link(c.email, 'mailto:${c.email}'),
        if (c.whatsapp.isNotEmpty) link('WhatsApp', whatsappUrl(c.whatsapp)),
      ]),
      col('Showroom', [
        if (c.address.isNotEmpty) link(c.address, mapsUrl(c.address)),
        if (c.hours.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(c.hours, style: t.body(14, color: t.muted)),
        ],
      ]),
      col('Esplora', [
        for (final (label, path) in navItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: HoverLink(
              label,
              style: t.body(15),
              onTap: () => context.go(path),
            ),
          ),
      ]),
    ];

    final social = [
      if (c.instagram.isNotEmpty) ('Instagram', c.instagram),
      if (c.facebook.isNotEmpty) ('Facebook', c.facebook),
      if (c.pinterest.isNotEmpty) ('Pinterest', c.pinterest),
    ];

    return Container(
      color: t.alt,
      padding: EdgeInsets.fromLTRB(
        context.gutter,
        context.fluid(64, 110),
        context.gutter,
        28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, box) {
                  const gap = 32.0;
                  final wdt = (box.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap,
                    runSpacing: 40,
                    children: [
                      for (final w in columns) SizedBox(width: wdt, child: w),
                    ],
                  );
                },
              ),
              SizedBox(height: context.fluid(48, 80)),
              Container(height: 1, color: t.line),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 10,
                spacing: 20,
                children: [
                  Text(
                    '© ${DateTime.now().year} ${content.shopName}'
                    '${c.vat.isEmpty ? '' : '  ·  ${c.vat}'}',
                    style: t.body(12.5, color: t.muted),
                  ),
                  Wrap(
                    spacing: 22,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final (name, url) in social)
                        HoverLink(
                          name,
                          style: t.body(12.5, color: t.muted),
                          onTap: () => openUrl(url),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: t.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          HoverLink(
                            'Area riservata',
                            style: t.body(12.5, color: t.muted),
                            onTap: () => context.go('/admin'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
