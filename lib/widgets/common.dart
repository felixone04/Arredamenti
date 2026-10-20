import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../theme/app_theme.dart';
import '../theme/site_theme.dart';

// ------------------------------------------------------------------ immagini

final _dataCache = <String, Uint8List>{};

/// Decodifica una foto caricata; null se il dato è danneggiato.
Uint8List? _decode(String url) {
  final hit = _dataCache[url];
  if (hit != null) return hit;
  try {
    return _dataCache[url] = base64Decode(url.substring(url.indexOf(',') + 1));
  } on FormatException {
    return null;
  }
}

/// Le foto di Unsplash si possono chiedere alla larghezza esatta che serve.
String _withWidth(String url, int w) {
  if (!url.contains('images.unsplash.com')) return url;
  return url.contains(RegExp(r'[?&]w=\d+'))
      ? url.replaceFirstMapped(RegExp(r'([?&])w=\d+'), (m) => '${m[1]}w=$w')
      : '$url${url.contains('?') ? '&' : '?'}w=$w';
}

/// Mostra un'immagine da URL web oppure da un caricamento locale (data URL).
class PhotoImage extends StatelessWidget {
  const PhotoImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String url;
  final BoxFit fit;
  final Alignment alignment;

  /// Fondo mentre la foto arriva: il colore "alternato" del tema del sito
  /// (o quello del gestionale).
  static Color _bg(BuildContext context) =>
      Theme.of(context).extension<SiteTheme>()?.alt ?? Palette.linen;

  Widget _placeholder(BuildContext context) => ColoredBox(
    color: _bg(context),
    child: Center(
      child: Icon(
        Icons.chair_outlined,
        color: Theme.of(context).extension<SiteTheme>()?.muted ?? Palette.ash,
        size: 28,
      ),
    ),
  );

  /// Larghezze a "gradini": evitano di riscaricare la foto a ogni piccolo
  /// ridimensionamento della finestra.
  static const _steps = [480, 800, 1200, 1600, 2000, 2600];

  Widget _network(BuildContext context, String src) => Image.network(
    src,
    fit: fit,
    alignment: alignment,
    gaplessPlayback: true,
    filterQuality: FilterQuality.medium,
    webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
    frameBuilder: (context, child, frame, sync) {
      if (sync) return child;
      // Durante il caricamento: solo il colore di fondo, poi dissolvenza.
      return ColoredBox(
        color: fit == BoxFit.contain ? Colors.transparent : _bg(context),
        child: AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOut,
          child: child,
        ),
      );
    },
    errorBuilder: (context, _, _) => _placeholder(context),
  );

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return _placeholder(context);
    if (url.startsWith('data:')) {
      final bytes = _decode(url);
      if (bytes == null) return _placeholder(context);
      return Image.memory(
        bytes,
        fit: fit,
        alignment: alignment,
        gaplessPlayback: true,
        errorBuilder: (context, _, _) => _placeholder(context),
      );
    }
    if (!url.contains('images.unsplash.com')) return _network(context, url);
    return LayoutBuilder(
      builder: (context, box) {
        if (!box.maxWidth.isFinite) return _network(context, url);
        final px = box.maxWidth * MediaQuery.devicePixelRatioOf(context);
        final w = _steps.firstWhere((s) => s >= px, orElse: () => _steps.last);
        return _network(context, _withWidth(url, w));
      },
    );
  }
}

// -------------------------------------------------------------------- reveal

/// Fa comparire il contenuto (dissolvenza + scorrimento) quando entra nella
/// finestra visibile.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 40,
  });
  final Widget child;
  final Duration delay;
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  final _key = UniqueKey();
  bool _triggered = false;
  bool _shown = false;

  void _onVisible(VisibilityInfo info) {
    if (_triggered || info.visibleFraction < 0.05) return;
    _triggered = true;
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: _onVisible,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _shown ? 1 : 0),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutQuart,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offset),
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

// ----------------------------------------------------------------- layout

/// Sezione a tutta larghezza con margini laterali fluidi e contenuto
/// centrato fino a [maxWidth].
class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.child,
    this.color,
    this.top,
    this.bottom,
    this.maxWidth = 1440,
  });
  final Widget child;
  final Color? color;
  final double? top;
  final double? bottom;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final v = context.fluid(72, 140);
    return Container(
      color: color,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.gutter,
        top ?? v,
        context.gutter,
        bottom ?? v,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Piccola etichetta: "(01) ——— GLI AMBIENTI".
class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.number, this.color});
  final String text;
  final String? number;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final c = color ?? t.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (number != null) ...[
          Text('($number)', style: t.label(11, color: color ?? t.accentText)),
          const SizedBox(width: 12),
        ],
        Container(width: 28, height: 1, color: c.withValues(alpha: 0.5)),
        const SizedBox(width: 12),
        Flexible(child: Text(text.toUpperCase(), style: t.label(11, color: c))),
      ],
    );
  }
}

// ----------------------------------------------------------------- bottoni

/// Bottone del sito: pieno con l'accento (o a contorno, secondo il tema),
/// con la freccia che ruota al passaggio del mouse.
class PillButton extends StatefulWidget {
  const PillButton(
    this.text, {
    super.key,
    required this.onTap,
    this.filled = true,
    this.big = false,
    this.loading = false,
    this.light = false,
    this.icon = Icons.arrow_outward_rounded,
  });
  final String text;
  final VoidCallback? onTap;
  final bool filled;
  final bool big;
  final bool loading;

  /// Su foto scure: bianco invece del colore del tema.
  final bool light;
  final IconData icon;

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final Color main;
    final Color onMain;
    if (widget.light) {
      main = Colors.white;
      onMain = const Color(0xFF1A1714);
    } else {
      main = t.accent;
      onMain = t.onAccent;
    }
    final outline = !widget.filled || (t.outlineButtons && !widget.light);
    final Color bg;
    final Color fg;
    if (outline) {
      bg = _hover ? main : Colors.transparent;
      fg = _hover ? onMain : (widget.light ? main : t.accentText);
    } else {
      bg = _hover ? t.ink : main;
      fg = _hover ? t.bg : onMain;
    }
    final enabled = widget.onTap != null && !widget.loading;
    final h = widget.big ? 60.0 : 50.0;
    return Semantics(
      button: true,
      label: widget.text,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            height: h,
            padding: EdgeInsets.only(left: h * 0.5, right: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(h),
              border: Border.all(
                color: outline ? (widget.light ? main : t.accentText) : bg,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.text.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.label(widget.big ? 12.5 : 11.5, color: fg),
                  ),
                ),
                SizedBox(width: h * 0.3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: h - 12,
                  height: h - 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fg.withValues(alpha: _hover ? 0.16 : 0.1),
                  ),
                  child: widget.loading
                      ? Padding(
                          padding: EdgeInsets.all(h * 0.28),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: fg,
                          ),
                        )
                      : AnimatedRotation(
                          turns: _hover ? 0.125 : 0,
                          duration: const Duration(milliseconds: 260),
                          child: Icon(widget.icon, size: h * 0.38, color: fg),
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

/// Link testuale con sottolineatura animata.
class HoverLink extends StatefulWidget {
  const HoverLink(
    this.text, {
    super.key,
    required this.onTap,
    required this.style,
    this.active = false,
    this.arrow = false,
  });
  final String text;
  final VoidCallback onTap;
  final TextStyle style;
  final bool active;
  final bool arrow;

  @override
  State<HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<HoverLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final on = _hover || widget.active;
    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(widget.text, style: widget.style)),
                    if (widget.arrow) ...[
                      const SizedBox(width: 8),
                      AnimatedSlide(
                        offset: Offset(_hover ? 0.3 : 0, 0),
                        duration: const Duration(milliseconds: 260),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: (widget.style.fontSize ?? 14) * 1.15,
                          color: widget.style.color,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  height: 1.2,
                  width: on ? 24 : 0,
                  color: widget.style.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Istante di avvio dell'app (impostato in `main`).
DateTime appStartedAt = DateTime.now();

/// Durata del logo d'apertura definito in `web/index.html` (dissolvenza
/// compresa): le animazioni d'ingresso partono dopo.
const splashMs = 1900;

/// Tempo che manca alla fine del logo d'apertura.
Duration get untilSplashEnds {
  final ms = splashMs - DateTime.now().difference(appStartedAt).inMilliseconds;
  return Duration(milliseconds: ms.clamp(0, splashMs));
}
