import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/site_theme.dart';
import '../widgets/common.dart';
import '../widgets/lightbox.dart';
import '../widgets/page_header.dart';
import '../widgets/sections.dart';
import '../widgets/site_scaffold.dart';

// ================================================================== ELENCO

class RoomsPage extends StatelessWidget {
  const RoomsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final c = s.content;
    final rooms = s.publishedRooms;
    final cols = context.isPhone ? 1 : (context.isTablet ? 2 : 3);
    return SiteScaffold(
      location: '/ambienti',
      children: [
        PageHeader(
          kicker: c.roomsKicker,
          title: c.roomsTitle,
          intro: c.roomsIntro,
        ),
        Section(
          top: 0,
          child: rooms.isEmpty
              ? Text(
                  'Presto nuovi ambienti da scoprire.',
                  style: context.st.body(16, color: context.st.muted),
                )
              : LayoutBuilder(
                  builder: (context, box) {
                    final gap = context.fluid(16, 28);
                    final w = (box.maxWidth - gap * (cols - 1)) / cols;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap * 1.6,
                      children: [
                        for (var i = 0; i < rooms.length; i++)
                          SizedBox(
                            width: w,
                            child: Reveal(
                              delay: Duration(milliseconds: 100 * (i % cols)),
                              child: _RoomCard(room: rooms[i], index: i),
                            ),
                          ),
                      ],
                    );
                  },
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

class _RoomCard extends StatefulWidget {
  const _RoomCard({required this.room, required this.index});
  final Room room;
  final int index;

  @override
  State<_RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<_RoomCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final r = widget.room;
    return Semantics(
      link: true,
      label: r.title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => context.go('/ambienti/${r.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: _hover ? 1.06 : 1,
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        child: PhotoImage(r.coverUrl),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [Color(0x99000000), Color(0x00000000)],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 18,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                r.title,
                                style: t.display(
                                  context.fluid(32, 44),
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _hover ? 0.125 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: const Icon(
                                Icons.arrow_outward_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    (widget.index + 1).toString().padLeft(2, '0'),
                    style: t.label(10.5, color: t.accentText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${r.kicker.toUpperCase()}  ·  ${r.photos.length} FOTO',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.label(10.5, color: t.muted),
                    ),
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

// ================================================================ DETTAGLIO

class RoomPage extends StatelessWidget {
  const RoomPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final t = context.st;
    final r = s.roomById(id);
    if (r == null || !r.published) {
      return SiteScaffold(
        location: '/ambienti',
        children: [
          PageHeader(
            kicker: 'Ambienti',
            title: 'Ambiente\nnon trovato',
            intro: 'Forse è stato spostato. Guarda gli altri ambienti.',
          ),
          Section(
            top: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: PillButton(
                'Tutti gli ambienti',
                onTap: () => context.go('/ambienti'),
              ),
            ),
          ),
        ],
      );
    }
    final published = s.publishedRooms;
    final idx = published.indexWhere((e) => e.id == r.id);
    final next = published.length > 1
        ? published[(idx + 1) % published.length]
        : null;
    final brands = [
      for (final b in r.brandIds) s.brandById(b),
    ].whereType<Brand>().where((b) => b.active).toList();
    final items = [
      for (final p in r.photos) (url: p.url, title: r.title, caption: p.caption),
    ];

    return SiteScaffold(
      location: '/ambienti',
      overHero: true,
      children: [
        _RoomHero(room: r),
        Section(
          child: _RoomIntro(room: r, brands: brands),
        ),
        if (r.photos.isNotEmpty)
          Section(
            top: 0,
            child: Column(
              children: [
                for (var i = 0; i < r.photos.length; i++) ...[
                  if (i > 0) SizedBox(height: context.fluid(48, 110)),
                  _PhotoStep(
                    photo: r.photos[i],
                    index: i,
                    total: r.photos.length,
                    onOpen: () => showLightbox(context, items, i),
                  ),
                ],
              ],
            ),
          ),
        if (next != null) _NextRoom(room: next),
        Container(height: 1, color: t.line),
        CtaBanner(
          title: 'Ti piace questo ${r.title.toLowerCase()}?',
          text: 'Raccontaci il tuo spazio: lo progettiamo insieme, su misura per te.',
          button: 'Preventivo per questo ambiente',
          image: r.photos.length > 1 ? r.photos.last.url : r.coverUrl,
        ),
      ],
    );
  }
}

class _RoomHero extends StatelessWidget {
  const _RoomHero({required this.room});
  final Room room;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    return SizedBox(
      height: context.screenH * 0.86,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.08, end: 1),
            duration: const Duration(seconds: 3),
            curve: Curves.easeOutCubic,
            builder: (_, s, child) => Transform.scale(scale: s, child: child),
            child: PhotoImage(room.coverUrl),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xA6000000), Color(0x0D000000), Color(0x4D000000)],
                stops: [0, 0.6, 1],
              ),
            ),
          ),
          Positioned(
            left: context.gutter,
            right: context.gutter,
            bottom: context.fluid(36, 72),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/ambienti'),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AMBIENTI',
                              style: t.label(11, color: Colors.white),
                            ),
                            if (room.kicker.isNotEmpty)
                              Flexible(
                                child: Text(
                                  '   /   ${room.kicker.toUpperCase()}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.label(11, color: Colors.white70),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      room.title,
                      style: t.display(
                        context.fluid(56, 150),
                        color: Colors.white,
                        height: 0.95,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomIntro extends StatelessWidget {
  const _RoomIntro({required this.room, required this.brands});
  final Room room;
  final List<Brand> brands;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final r = room;
    final paragraphs = (r.story.trim().isNotEmpty ? r.story : r.description)
        .split(RegExp(r'\n\s*\n'))
        .where((e) => e.trim().isNotEmpty);

    final story = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r.description,
          style: t.display(context.fluid(26, 38), italic: true, height: 1.25),
        ),
        const SizedBox(height: 28),
        if (r.story.trim().isNotEmpty)
          for (final p in paragraphs)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(p.trim(), style: t.body(16, color: t.muted)),
            ),
      ],
    );

    Widget block(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: t.label(10.5, color: t.muted)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );

    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.features.isNotEmpty)
          block(
            'Caratteristiche',
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final f in r.features) FeatureChip(f)],
            ),
          ),
        if (brands.isNotEmpty)
          block(
            'Marchi per questo ambiente',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final b in brands)
                  HoverLink(
                    b.name,
                    style: t.display(24, height: 1.2),
                    onTap: () => context.go('/marchi'),
                  ),
              ],
            ),
          ),
        PillButton(
          'Chiedi un preventivo',
          onTap: () => goQuoteForRoom(context, r),
        ),
      ],
    );

    if (context.isTablet) {
      return Reveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [story, const SizedBox(height: 30), side],
        ),
      );
    }
    return Reveal(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 7, child: story),
          const SizedBox(width: 90),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.only(left: 36),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: t.line)),
              ),
              child: side,
            ),
          ),
        ],
      ),
    );
  }
}

/// Una foto dell'ambiente con la sua descrizione. Una foto ogni tre è a
/// tutta larghezza, le altre si alternano a destra e a sinistra del testo.
class _PhotoStep extends StatefulWidget {
  const _PhotoStep({
    required this.photo,
    required this.index,
    required this.total,
    required this.onOpen,
  });
  final RoomPhoto photo;
  final int index;
  final int total;
  final VoidCallback onOpen;

  @override
  State<_PhotoStep> createState() => _PhotoStepState();
}

class _PhotoStepState extends State<_PhotoStep> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final i = widget.index;
    final full = i % 3 == 0 || context.isTablet;
    final flip = i % 3 == 2;

    final image = MouseRegion(
      cursor: SystemMouseCursors.zoomIn,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onOpen,
        child: AspectRatio(
          aspectRatio: full ? (context.isPhone ? 4 / 3 : 16 / 8.5) : 4 / 5,
          child: ClipRect(
            child: AnimatedScale(
              scale: _hover ? 1.04 : 1,
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              child: PhotoImage(widget.photo.url),
            ),
          ),
        ),
      ),
    );

    final caption = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${(i + 1).toString().padLeft(2, '0')} — ${widget.total.toString().padLeft(2, '0')}',
          style: t.label(11, color: t.accentText),
        ),
        const SizedBox(height: 14),
        Text(
          widget.photo.caption,
          style: t.display(
            full ? context.fluid(22, 30) : context.fluid(24, 36),
            italic: true,
            height: 1.25,
          ),
        ),
      ],
    );

    if (full) {
      return Reveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image,
            if (widget.photo.caption.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: caption,
              ),
            ],
          ],
        ),
      );
    }
    final gap = SizedBox(width: context.fluid(40, 100));
    return Reveal(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: flip
            ? [Expanded(flex: 4, child: caption), gap, Expanded(flex: 6, child: image)]
            : [Expanded(flex: 6, child: image), gap, Expanded(flex: 4, child: caption)],
      ),
    );
  }
}

class _NextRoom extends StatefulWidget {
  const _NextRoom({required this.room});
  final Room room;

  @override
  State<_NextRoom> createState() => _NextRoomState();
}

class _NextRoomState extends State<_NextRoom> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final r = widget.room;
    final thumb = context.fluid(110, 220);
    return Section(
      color: t.surface,
      top: context.fluid(48, 80),
      bottom: context.fluid(48, 80),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => context.go('/ambienti/${r.id}'),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AMBIENTE SUCCESSIVO',
                      style: t.label(10.5, color: t.muted),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            r.title,
                            style: t.display(
                              context.fluid(40, 88),
                              italic: _hover,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        AnimatedSlide(
                          offset: Offset(_hover ? 0.25 : 0, 0),
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: context.fluid(28, 48),
                            color: t.accentText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: thumb,
                height: thumb * 0.75,
                child: ClipRect(
                  child: AnimatedScale(
                    scale: _hover ? 1.08 : 1,
                    duration: const Duration(milliseconds: 700),
                    child: PhotoImage(r.coverUrl),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
