import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/site_theme.dart';

/// Pallino che riassume un tema: metà fondo, metà accento, bordo del testo.
class ThemeSwatch extends StatelessWidget {
  const ThemeSwatch({
    super.key,
    required this.theme,
    this.size = 28,
    this.selected = false,
  });
  final SiteTheme theme;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      padding: EdgeInsets.all(selected ? 2.5 : 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? context.st.ink : context.st.lineStrong,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: _SwatchPainter(theme),
          size: Size.square(size),
        ),
      ),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  _SwatchPainter(this.t);
  final SiteTheme t;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..color = t.bg);
    final p = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p, Paint()..color = t.accent);
    canvas.drawCircle(
      r.center,
      size.width * 0.14,
      Paint()..color = t.ink,
    );
  }

  @override
  bool shouldRepaint(_SwatchPainter o) => o.t != t;
}

/// Pulsante fisso "Stile": apre l'elenco dei temi e li applica al volo a
/// tutto il sito, per mostrare ai clienti la stessa casa con atmosfere
/// diverse.
class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final t = context.st;
    final current = s.currentTheme;
    final themes = s.offeredThemes;
    final maxW = (context.w - 28).clamp(200.0, 300.0);

    final panel = Container(
      width: maxW,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: t.dark ? 0.5 : 0.14),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: Text(
              'SCEGLI UNO STILE',
              style: t.label(10, color: t.muted),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: context.h * 0.6),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final th in themes)
                    _ThemeRow(
                      theme: th,
                      selected: th.id == current.id,
                      onTap: () => s.selectTheme(th.id),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomLeft,
          child: _open ? panel : const SizedBox(width: 0, height: 0),
        ),
        Semantics(
          button: true,
          label: _open ? 'Chiudi stili' : 'Cambia stile',
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: context.isPhone ? 52 : 56,
                padding: EdgeInsets.only(
                  left: 8,
                  right: !_open && context.isPhone ? 14 : 18,
                ),
                decoration: BoxDecoration(
                  color: t.ink,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: t.bg.withValues(alpha: 0.5)),
                      ),
                      child: ClipOval(
                        child: CustomPaint(
                          painter: _SwatchPainter(current),
                          size: const Size.square(30),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      _open ? Icons.close_rounded : Icons.palette_outlined,
                      size: 18,
                      color: t.bg,
                    ),
                    // Da telefono, chiuso, resta solo l'icona: copre meno.
                    if (_open || !context.isPhone) ...[
                      const SizedBox(width: 8),
                      Text(
                        _open ? 'CHIUDI' : 'CAMBIA STILE',
                        style: t.label(11, color: t.bg),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeRow extends StatefulWidget {
  const _ThemeRow({
    required this.theme,
    required this.selected,
    required this.onTap,
  });
  final SiteTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ThemeRow> createState() => _ThemeRowState();
}

class _ThemeRowState extends State<_ThemeRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final th = widget.theme;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: 'Stile ${th.name}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: widget.selected || _hover
                  ? t.ink.withValues(alpha: widget.selected ? 0.08 : 0.04)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                ThemeSwatch(theme: th, size: 30, selected: widget.selected),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        th.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // Il nome nel carattere del tema: anteprima immediata.
                        style: th.display(19, color: t.ink, height: 1.15),
                      ),
                      Text(
                        th.dark ? 'Scuro' : 'Chiaro',
                        style: t.body(11.5, color: t.muted, height: 1.3),
                      ),
                    ],
                  ),
                ),
                if (widget.selected)
                  Icon(Icons.check_rounded, size: 18, color: t.accentText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
