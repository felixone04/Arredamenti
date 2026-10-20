import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/site_theme.dart';
import '../widgets/common.dart';
import '../widgets/page_header.dart';
import '../widgets/sections.dart';
import '../widgets/site_scaffold.dart';

class BrandsPage extends StatefulWidget {
  const BrandsPage({super.key});

  @override
  State<BrandsPage> createState() => _BrandsPageState();
}

class _BrandsPageState extends State<BrandsPage> {
  String? _cat;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final t = context.st;
    final c = s.content;
    final all = s.activeBrands;
    final cats = <String>{
      for (final b in all)
        if (b.category.trim().isNotEmpty) b.category.trim(),
    }.toList();
    final cat = cats.contains(_cat) ? _cat : null;
    final list = cat == null
        ? all
        : all.where((b) => b.category.trim() == cat).toList();
    final cols = context.isPhone ? 1 : (context.isTablet ? 2 : 3);

    Widget chip(String label, bool selected, VoidCallback onTap) => Semantics(
      button: true,
      selected: selected,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? t.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: selected ? t.ink : t.lineStrong),
            ),
            child: Text(
              label,
              style: t.body(13.5, color: selected ? t.bg : t.ink, height: 1.2),
            ),
          ),
        ),
      ),
    );

    return SiteScaffold(
      location: '/marchi',
      children: [
        PageHeader(
          kicker: c.brandsKicker,
          title: c.brandsTitle,
          intro: c.brandsIntro,
        ),
        Section(
          top: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cats.length > 1) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    chip('Tutti', cat == null, () => setState(() => _cat = null)),
                    for (final k in cats)
                      chip(k, cat == k, () => setState(() => _cat = k)),
                  ],
                ),
                SizedBox(height: context.fluid(28, 44)),
              ],
              LayoutBuilder(
                builder: (context, box) {
                  final w = box.maxWidth / cols;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: t.line),
                        left: BorderSide(color: t.line),
                      ),
                    ),
                    child: Wrap(
                      children: [
                        for (var i = 0; i < list.length; i++)
                          SizedBox(
                            width: w - (1 / cols),
                            child: _BrandCell(brand: list[i], index: i),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        CtaBanner(
          title: c.bannerTitle,
          text: c.bannerText,
          button: c.bannerButton,
          image: c.bannerImage,
        ),
      ],
    );
  }
}

class _BrandCell extends StatefulWidget {
  const _BrandCell({required this.brand, required this.index});
  final Brand brand;
  final int index;

  @override
  State<_BrandCell> createState() => _BrandCellState();
}

class _BrandCellState extends State<_BrandCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final b = widget.brand;
    final hasSite = b.website.trim().isNotEmpty;
    return MouseRegion(
      cursor: hasSite ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: hasSite ? () => openUrl(b.website) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: context.fluid(250, 300),
          padding: EdgeInsets.all(context.fluid(22, 34)),
          decoration: BoxDecoration(
            color: _hover ? t.surface : Colors.transparent,
            border: Border(
              right: BorderSide(color: t.line),
              bottom: BorderSide(color: t.line),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    (widget.index + 1).toString().padLeft(2, '0'),
                    style: t.label(10.5, color: t.accentText),
                  ),
                  const Spacer(),
                  if (b.category.isNotEmpty)
                    Flexible(
                      child: Text(
                        b.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.label(10, color: t.muted),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedScale(
                    scale: _hover ? 1.04 : 1,
                    alignment: Alignment.centerLeft,
                    duration: const Duration(milliseconds: 400),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: BrandWordmark(
                        brand: b,
                        size: context.fluid(38, 52),
                      ),
                    ),
                  ),
                ),
              ),
              if (b.description.isNotEmpty)
                Text(
                  b.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: t.body(14, color: t.muted),
                ),
              if (hasSite) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('SITO UFFICIALE', style: t.label(10, color: t.ink)),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_outward_rounded, size: 14, color: t.ink),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
