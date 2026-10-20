import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/site_theme.dart';
import 'common.dart';
import 'sections.dart';

/// Apertura delle pagine interne: etichetta, titolo grande e introduzione.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.kicker,
    required this.title,
    this.intro,
  });
  final String kicker;
  final String title;
  final String? intro;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    return Section(
      top: context.fluid(48, 100),
      bottom: context.fluid(40, 80),
      child: Reveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Tag(kicker),
            SizedBox(height: context.fluid(18, 28)),
            SplitTitle(
              title,
              size: context.fluid(48, 112),
              accentColor: t.accentText,
              height: 1,
            ),
            if (intro != null && intro!.trim().isNotEmpty) ...[
              SizedBox(height: context.fluid(20, 32)),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  intro!,
                  style: t.body(context.fluid(15, 18), color: t.muted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
