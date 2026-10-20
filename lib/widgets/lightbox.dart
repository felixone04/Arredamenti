import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/site_theme.dart';
import 'common.dart';

/// Una foto da mostrare a schermo intero.
typedef LightboxItem = ({String url, String title, String caption});

/// Visualizzazione a schermo intero: frecce, tastiera, swipe e zoom.
Future<void> showLightbox(
  BuildContext context,
  List<LightboxItem> items,
  int start,
) {
  final t = context.st;
  return showGeneralDialog(
    context: context,
    barrierColor: t.bg,
    barrierDismissible: true,
    barrierLabel: 'Chiudi',
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (_, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: child,
    ),
    pageBuilder: (_, _, _) => _Lightbox(items: items, start: start),
  );
}

class _Lightbox extends StatefulWidget {
  const _Lightbox({required this.items, required this.start});
  final List<LightboxItem> items;
  final int start;

  @override
  State<_Lightbox> createState() => _LightboxState();
}

class _LightboxState extends State<_Lightbox> {
  late final PageController _c = PageController(initialPage: widget.start);
  late int _i = widget.start;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _go(int d) {
    final n = widget.items.length;
    _c.animateToPage(
      (_i + d + n) % n,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final p = widget.items[_i];
    final wide = context.w > 720;
    return Focus(
      autofocus: true,
      onKeyEvent: (_, e) {
        if (e is! KeyDownEvent) return KeyEventResult.ignored;
        if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
          _go(1);
        } else if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _go(-1);
        } else if (e.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(context);
        } else {
          return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      },
      child: Material(
        color: t.bg,
        child: Stack(
          children: [
            PageView.builder(
              controller: _c,
              itemCount: widget.items.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (_, i) => InteractiveViewer(
                maxScale: 4,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 90 : 0,
                    70,
                    wide ? 90 : 0,
                    120,
                  ),
                  child: PhotoImage(
                    widget.items[i].url,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              left: context.gutter,
              right: context.gutter,
              bottom: 26,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (p.title.isNotEmpty)
                          Text(
                            p.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.display(context.fluid(24, 36), italic: true),
                          ),
                        if (p.caption.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            p.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: t.body(14, color: t.muted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(_i + 1).toString().padLeft(2, '0')} / ${widget.items.length.toString().padLeft(2, '0')}',
                    style: t.label(11, color: t.accentText),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: 'Chiudi',
                icon: Icon(Icons.close_rounded, size: 30, color: t.ink),
              ),
            ),
            if (wide) ...[
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () => _go(-1),
                    tooltip: 'Foto precedente',
                    iconSize: 40,
                    color: t.ink,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    onPressed: () => _go(1),
                    tooltip: 'Foto successiva',
                    iconSize: 40,
                    color: t.ink,
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
