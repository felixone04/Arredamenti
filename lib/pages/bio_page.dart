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

class BioPage extends StatelessWidget {
  const BioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final t = context.st;
    final c = s.content;
    return SiteScaffold(
      location: '/biografia',
      children: [
        PageHeader(kicker: c.tagline, title: c.bioTitle),
        Section(top: 0, child: _Story(content: c)),
        if (c.bioImage2.trim().isNotEmpty)
          Reveal(
            offset: 0,
            child: SizedBox(
              height: context.fluid(320, 640),
              child: PhotoImage(c.bioImage2),
            ),
          ),
        if (c.timeline.isNotEmpty)
          Section(
            color: t.surface,
            child: _Timeline(items: c.timeline),
          ),
        if (c.team.isNotEmpty)
          Section(child: _Team(title: c.teamTitle, team: c.team)),
        if (c.process.isNotEmpty)
          ProcessSection(
            title: c.processTitle,
            steps: c.process,
            color: t.alt,
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

class _Story extends StatelessWidget {
  const _Story({required this.content});
  final SiteContent content;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final c = content;
    final paragraphs = c.bioStory
        .split(RegExp(r'\n\s*\n'))
        .where((e) => e.trim().isNotEmpty);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          c.bioIntro,
          style: t.display(context.fluid(28, 44), italic: true, height: 1.2),
        ),
        SizedBox(height: context.fluid(28, 40)),
        for (final p in paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Text(p.trim(), style: t.body(16, color: t.muted)),
          ),
      ],
    );
    final image = AspectRatio(
      aspectRatio: 4 / 5,
      child: PhotoImage(c.bioImage),
    );
    if (context.isTablet) {
      return Reveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (c.bioImage.trim().isNotEmpty) ...[image, const SizedBox(height: 32)],
            text,
          ],
        ),
      );
    }
    return Reveal(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.bioImage.trim().isNotEmpty) ...[
            Expanded(flex: 5, child: image),
            const SizedBox(width: 90),
          ],
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: text,
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.items});
  final List<Milestone> items;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final cols = context.isPhone ? 1 : (context.isTablet ? 2 : items.length.clamp(1, 4));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          child: SectionHeading(
            kicker: 'Le tappe',
            title: 'Dalla bottega\nallo showroom',
          ),
        ),
        SizedBox(height: context.fluid(40, 80)),
        LayoutBuilder(
          builder: (context, box) {
            const gap = 28.0;
            final w = (box.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: 44,
              children: [
                for (var i = 0; i < items.length; i++)
                  SizedBox(
                    width: w,
                    child: Reveal(
                      delay: Duration(milliseconds: 120 * (i % cols)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: t.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Container(height: 1, color: t.lineStrong)),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Text(
                            items[i].year,
                            style: t.display(
                              context.fluid(48, 72),
                              color: t.accentText,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(items[i].title, style: t.display(26, height: 1.15)),
                          const SizedBox(height: 8),
                          Text(items[i].text, style: t.body(14.5, color: t.muted)),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Team extends StatelessWidget {
  const _Team({required this.title, required this.team});
  final String title;
  final List<TeamMember> team;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final cols = context.isPhone ? 1 : (context.isTablet ? 2 : 3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(child: SectionHeading(kicker: 'Il team', title: title)),
        SizedBox(height: context.fluid(40, 72)),
        LayoutBuilder(
          builder: (context, box) {
            final gap = context.fluid(20, 32);
            final w = (box.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap * 1.5,
              children: [
                for (var i = 0; i < team.length; i++)
                  SizedBox(
                    width: w,
                    child: Reveal(
                      delay: Duration(milliseconds: 120 * (i % cols)),
                      child: team[i].photo.trim().isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 4 / 5,
                                  child: PhotoImage(team[i].photo),
                                ),
                                const SizedBox(height: 16),
                                _person(t, team[i]),
                              ],
                            )
                          : Container(
                              padding: EdgeInsets.all(context.fluid(22, 30)),
                              decoration: BoxDecoration(
                                color: t.surface,
                                border: Border.all(color: t.line),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Initials(name: team[i].name, size: 64),
                                  const SizedBox(width: 18),
                                  Expanded(child: _person(t, team[i])),
                                ],
                              ),
                            ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _person(SiteTheme t, TeamMember m) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(m.name, style: t.display(28, height: 1.1)),
      const SizedBox(height: 4),
      Text(m.role.toUpperCase(), style: t.label(10.5, color: t.accentText)),
      if (m.bio.isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(m.bio, style: t.body(14, color: t.muted)),
      ],
    ],
  );
}
