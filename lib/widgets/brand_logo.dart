import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/site_theme.dart';

/// Logotipo tipografico: il nome del negozio in maiuscolo spaziato, nel
/// carattere del tema, con un piccolo rombo nel colore d'accento. Cambia
/// insieme al tema, e il nome si modifica dal gestionale.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 20,
    this.color,
    this.accent,
    this.showTagline = false,
    this.theme,
  });

  /// Altezza delle lettere.
  final double size;
  final Color? color;
  final Color? accent;
  final bool showTagline;

  /// Tema da usare al posto di quello del sito (es. nel gestionale).
  final SiteTheme? theme;

  @override
  Widget build(BuildContext context) {
    final c = context.select<AppState, (String, String)>(
      (s) => (s.content.shopName, s.content.tagline),
    );
    final t = theme ?? context.st;
    final ink = color ?? t.ink;
    final name = c.$1.trim().isEmpty ? 'Arredamenti' : c.$1.trim();
    final word = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: 0.785398,
          child: Container(
            width: size * 0.34,
            height: size * 0.34,
            color: accent ?? t.accent,
          ),
        ),
        SizedBox(width: size * 0.55),
        Flexible(
          child: Text(
            name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: t
                .display(size, color: ink, height: 1)
                .copyWith(letterSpacing: size * 0.26),
          ),
        ),
      ],
    );
    if (!showTagline || c.$2.trim().isEmpty) {
      return Semantics(label: name, child: ExcludeSemantics(child: word));
    }
    return Semantics(
      label: name,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            word,
            SizedBox(height: size * 0.5),
            Text(
              c.$2.toUpperCase(),
              textAlign: TextAlign.center,
              style: t.label(size * 0.36, color: ink.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
