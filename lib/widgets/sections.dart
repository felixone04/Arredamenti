import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../theme/site_theme.dart';
import 'common.dart';
import 'lightbox.dart';
import 'site_scaffold.dart';

// ------------------------------------------------------------------ titoli

/// Titolo su più righe: dalla seconda riga in poi corsivo e, se richiesto,
/// nel colore d'accento. Un tocco editoriale che cambia con il tema.
class SplitTitle extends StatelessWidget {
  const SplitTitle(
    this.text, {
    super.key,
    required this.size,
    this.color,
    this.accentColor,
    this.align = TextAlign.start,
    this.height = 1.04,
  });
  final String text;
  final double size;
  final Color? color;
  final Color? accentColor;
  final TextAlign align;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final lines = text.split('\n');
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < lines.length; i++)
            TextSpan(
              text: i < lines.length - 1 ? '${lines[i]}\n' : lines[i],
              style: t.display(
                size,
                color: i == 0 ? (color ?? t.ink) : (accentColor ?? color ?? t.ink),
                italic: i > 0,
                height: height,
              ),
            ),
        ],
      ),
      textAlign: align,
    );
  }
}

/// Intestazione di sezione: etichetta + titolo (+ testo e azione a destra).
class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.kicker,
    required this.title,
    this.number,
    this.intro,
    this.trailing,
    this.center = false,
  });
  final String kicker;
  final String title;
  final String? number;
  final String? intro;
  final Widget? trailing;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final head = Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Tag(kicker, number: number),
        SizedBox(height: context.fluid(16, 26)),
        SplitTitle(
          title,
          size: context.fluid(38, 76),
          accentColor: t.accentText,
          align: center ? TextAlign.center : TextAlign.start,
        ),
      ],
    );
    final introText = intro == null || intro!.trim().isEmpty
        ? null
        : Text(
            intro!,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: t.body(context.fluid(15, 17), color: t.muted),
          );
    if (center) {
      return Column(
        children: [
          head,
          if (introText != null) ...[
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: introText,
            ),
          ],
          if (trailing != null) ...[const SizedBox(height: 26), trailing!],
        ],
      );
    }
    if (context.isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          head,
          if (introText != null) ...[const SizedBox(height: 20), introText],
          if (trailing != null) ...[const SizedBox(height: 22), trailing!],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 7, child: head),
        const SizedBox(width: 60),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ?introText,
              if (trailing != null) ...[const SizedBox(height: 22), trailing!],
            ],
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- apertura

/// Carosello d'apertura a tutto schermo: le foto si alternano in
/// dissolvenza con un lento zoom, il titolo resta sopra.
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    super.key,
    required this.photos,
    required this.kicker,
    required this.title,
    required this.subtitle,
  });
  final List<GalleryPhoto> photos;
  final String kicker;
  final String title;
  final String subtitle;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  static const _every = Duration(seconds: 6);
  int _i = 0;
  Timer? _timer;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _restart();
    // Il titolo entra quando il logo d'apertura sta sparendo.
    Future.delayed(untilSplashEnds, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  void _restart() {
    _timer?.cancel();
    _timer = Timer.periodic(_every, (_) => _go(1, user: false));
  }

  void _go(int d, {bool user = true}) {
    final n = widget.photos.length;
    if (n < 2) return;
    setState(() => _i = (_i + d + n) % n);
    if (user) _restart();
  }

  void _jump(int i) {
    setState(() => _i = i);
    _restart();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final photos = widget.photos;
    final n = photos.length;
    if (_i >= n && n > 0) _i = 0;
    final p = n == 0 ? null : photos[_i];
    final phone = context.isPhone;

    Widget entrance(Widget child, int order) => AnimatedOpacity(
      opacity: _shown ? 1 : 0,
      duration: const Duration(milliseconds: 900),
      curve: Interval(order * 0.12, 1, curve: Curves.easeOut),
      child: AnimatedSlide(
        offset: _shown ? Offset.zero : const Offset(0, 0.25),
        duration: Duration(milliseconds: 1000 + order * 150),
        curve: Curves.easeOutQuart,
        child: child,
      ),
    );

    return SizedBox(
      height: context.screenH,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: t.alt),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1400),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            layoutBuilder: (cur, prev) => Stack(
              fit: StackFit.expand,
              children: [...prev, ?cur],
            ),
            child: p == null
                ? const SizedBox.expand()
                : _KenBurns(key: ValueKey('${p.id}-$_i'), url: p.url),
          ),
          // Velo scuro: in basso e a sinistra, dove stanno i testi.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xB3000000), Color(0x1A000000), Color(0x40000000)],
                stops: [0, 0.55, 1],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0x66000000), Color(0x00000000)],
                stops: [0, 0.7],
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          entrance(
                            Tag(widget.kicker, color: Colors.white),
                            0,
                          ),
                          SizedBox(height: context.fluid(18, 28)),
                          entrance(
                            SplitTitle(
                              widget.title,
                              size: context.fluid(50, 124),
                              color: Colors.white,
                              height: 0.98,
                            ),
                            1,
                          ),
                          SizedBox(height: context.fluid(18, 28)),
                          entrance(
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 520),
                              child: Text(
                                widget.subtitle,
                                style: t.body(
                                  context.fluid(15, 17.5),
                                  color: Colors.white.withValues(alpha: 0.88),
                                ),
                              ),
                            ),
                            2,
                          ),
                          SizedBox(height: context.fluid(24, 38)),
                          entrance(
                            Wrap(
                              spacing: 14,
                              runSpacing: 12,
                              children: [
                                PillButton(
                                  'Scopri gli ambienti',
                                  light: true,
                                  big: !phone,
                                  onTap: () => context.go('/ambienti'),
                                ),
                                PillButton(
                                  'Preventivo gratuito',
                                  light: true,
                                  filled: false,
                                  big: !phone,
                                  onTap: () => context.go('/preventivo'),
                                ),
                              ],
                            ),
                            3,
                          ),
                          if (n > 1) ...[
                            SizedBox(height: context.fluid(28, 44)),
                            _HeroProgress(
                              count: n,
                              index: _i,
                              every: _every,
                              onTap: _jump,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!context.isTablet && p != null) ...[
                      const SizedBox(width: 40),
                      _HeroCaption(
                        photo: p,
                        index: _i,
                        count: n,
                        onPrev: () => _go(-1),
                        onNext: () => _go(1),
                      ),
                    ],
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

class _KenBurns extends StatelessWidget {
  const _KenBurns({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.09),
      duration: const Duration(seconds: 9),
      curve: Curves.easeOut,
      builder: (_, s, child) => Transform.scale(scale: s, child: child),
      child: PhotoImage(url),
    );
  }
}

/// Barre di avanzamento del carosello: quella attiva si riempie.
class _HeroProgress extends StatelessWidget {
  const _HeroProgress({
    required this.count,
    required this.index,
    required this.every,
    required this.onTap,
  });
  final int count;
  final int index;
  final Duration every;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final w = context.isPhone ? 28.0 : 44.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Semantics(
            button: true,
            label: 'Foto ${i + 1}',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                  child: SizedBox(
                    width: w,
                    height: 2,
                    child: Stack(
                      children: [
                        Container(color: Colors.white.withValues(alpha: 0.3)),
                        if (i < index)
                          Container(color: Colors.white)
                        else if (i == index)
                          TweenAnimationBuilder<double>(
                            key: ValueKey('bar-$index'),
                            tween: Tween(begin: 0, end: 1),
                            duration: every,
                            builder: (_, v, _) => FractionallySizedBox(
                              widthFactor: v,
                              child: Container(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroCaption extends StatelessWidget {
  const _HeroCaption({
    required this.photo,
    required this.index,
    required this.count,
    required this.onPrev,
    required this.onNext,
  });
  final GalleryPhoto photo;
  final int index;
  final int count;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    Widget arrow(IconData i, String tip, VoidCallback f) => Tooltip(
      message: tip,
      child: InkResponse(
        onTap: f,
        radius: 26,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          ),
          child: Icon(i, color: Colors.white, size: 20),
        ),
      ),
    );
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: Column(
              key: ValueKey(photo.id + photo.url),
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (photo.category.isNotEmpty)
                  Text(
                    photo.category.toUpperCase(),
                    style: t.label(10.5, color: Colors.white70),
                  ),
                const SizedBox(height: 6),
                Text(
                  photo.title,
                  textAlign: TextAlign.right,
                  style: t.display(26, color: Colors.white, italic: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(index + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}',
                style: t.label(11, color: Colors.white),
              ),
              if (count > 1) ...[
                const SizedBox(width: 18),
                arrow(Icons.arrow_back_rounded, 'Foto precedente', onPrev),
                const SizedBox(width: 10),
                arrow(Icons.arrow_forward_rounded, 'Foto successiva', onNext),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ presentazione

class IntroSection extends StatelessWidget {
  const IntroSection({super.key, required this.content});
  final SiteContent content;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final c = content;
    final cols = context.isPhone ? 2 : 4;
    return Section(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            child: SectionHeading(
              kicker: c.introKicker,
              number: '01',
              title: c.introTitle,
              intro: c.introText,
              trailing: HoverLink(
                'La nostra storia',
                arrow: true,
                style: t.label(12, color: t.accentText),
                onTap: () => context.go('/biografia'),
              ),
            ),
          ),
          if (c.stats.isNotEmpty) ...[
            SizedBox(height: context.fluid(56, 100)),
            Container(height: 1, color: t.line),
            LayoutBuilder(
              builder: (context, box) {
                final w = box.maxWidth / cols;
                return Wrap(
                  children: [
                    for (var i = 0; i < c.stats.length; i++)
                      SizedBox(
                        width: w,
                        child: Reveal(
                          delay: Duration(milliseconds: 120 * (i % cols)),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              i % cols == 0 ? 0 : 20,
                              context.fluid(26, 40),
                              10,
                              0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    c.stats[i].title,
                                    style: t.display(
                                      context.fluid(44, 84),
                                      color: t.accentText,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  c.stats[i].text.toUpperCase(),
                                  style: t.label(10.5, color: t.muted),
                                ),
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- ambienti

/// Gli ambienti uno dopo l'altro: foto grande e descrizione, alternate a
/// destra e a sinistra.
class RoomsSequence extends StatelessWidget {
  const RoomsSequence({super.key, required this.content, required this.rooms});
  final SiteContent content;
  final List<Room> rooms;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    return Section(
      color: t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: SectionHeading(
              kicker: content.roomsKicker,
              number: '02',
              title: content.roomsTitle,
              intro: content.roomsIntro,
              trailing: HoverLink(
                'Tutti gli ambienti',
                arrow: true,
                style: t.label(12, color: t.accentText),
                onTap: () => context.go('/ambienti'),
              ),
            ),
          ),
          SizedBox(height: context.fluid(56, 110)),
          for (var i = 0; i < rooms.length; i++) ...[
            if (i > 0) SizedBox(height: context.fluid(64, 140)),
            RoomFeature(room: rooms[i], index: i),
          ],
        ],
      ),
    );
  }
}

class RoomFeature extends StatefulWidget {
  const RoomFeature({super.key, required this.room, required this.index});
  final Room room;
  final int index;

  @override
  State<RoomFeature> createState() => _RoomFeatureState();
}

class _RoomFeatureState extends State<RoomFeature> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final r = widget.room;
    final flip = widget.index.isOdd;
    final stacked = context.isTablet;
    void open() => context.go('/ambienti/${r.id}');

    final image = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: open,
        child: AspectRatio(
          aspectRatio: stacked ? 4 / 3 : 5 / 4,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedScale(
                  scale: _hover ? 1.05 : 1,
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  child: PhotoImage(r.coverUrl),
                ),
                Positioned(
                  left: 18,
                  top: 16,
                  child: Text(
                    (widget.index + 1).toString().padLeft(2, '0'),
                    style: t.display(
                      context.fluid(40, 72),
                      color: Colors.white,
                      italic: true,
                      height: 1,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: AnimatedOpacity(
                    opacity: _hover ? 1 : 0.85,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${r.photos.length} FOTO',
                            style: t.label(10, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.kicker.isNotEmpty) Tag(r.kicker),
        const SizedBox(height: 18),
        Text(r.title, style: t.display(context.fluid(40, 72))),
        const SizedBox(height: 18),
        Text(r.description, style: t.body(context.fluid(15, 16.5), color: t.muted)),
        if (r.features.isNotEmpty) ...[
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final f in r.features) FeatureChip(f)],
          ),
        ],
        const SizedBox(height: 26),
        HoverLink(
          'Scopri l\'ambiente',
          arrow: true,
          style: t.label(12, color: t.accentText),
          onTap: open,
        ),
      ],
    );

    if (stacked) {
      return Reveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [image, const SizedBox(height: 26), text],
        ),
      );
    }
    final gap = SizedBox(width: context.fluid(40, 100));
    return Reveal(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: flip
            ? [Expanded(flex: 5, child: text), gap, Expanded(flex: 7, child: image)]
            : [Expanded(flex: 7, child: image), gap, Expanded(flex: 5, child: text)],
      ),
    );
  }
}

/// Etichetta a contorno (caratteristiche, categorie).
class FeatureChip extends StatelessWidget {
  const FeatureChip(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: t.lineStrong),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(text, style: t.body(12.5, height: 1.3)),
    );
  }
}

// --------------------------------------------------------- carosello foto

/// Carosello orizzontale di foto con didascalia: si trascina, si scorre con
/// le frecce e ogni foto si apre a schermo intero.
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({
    super.key,
    required this.kicker,
    required this.title,
    required this.photos,
    this.number,
  });
  final String kicker;
  final String title;
  final String? number;
  final List<GalleryPhoto> photos;

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final _c = ScrollController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _itemW(BuildContext context) => context.fluid(250, 400);

  void _by(int d) {
    if (!_c.hasClients) return;
    final step = (_itemW(context) + 20) * (context.isPhone ? 1 : 2);
    _c.animateTo(
      (_c.offset + step * d).clamp(0.0, _c.position.maxScrollExtent),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final photos = widget.photos;
    final w = _itemW(context);
    Widget arrow(IconData i, String tip, VoidCallback f) => Tooltip(
      message: tip,
      child: InkResponse(
        onTap: f,
        radius: 28,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: t.lineStrong),
          ),
          child: Icon(i, size: 20, color: t.ink),
        ),
      ),
    );
    final items = [
      for (final p in photos) (url: p.url, title: p.title, caption: p.caption),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.fluid(72, 140)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.gutter),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Reveal(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Tag(widget.kicker, number: widget.number),
                            SizedBox(height: context.fluid(16, 24)),
                            SplitTitle(
                              widget.title,
                              size: context.fluid(36, 68),
                              accentColor: t.accentText,
                            ),
                          ],
                        ),
                      ),
                      if (!context.isPhone) ...[
                        arrow(Icons.arrow_back_rounded, 'Indietro', () => _by(-1)),
                        const SizedBox(width: 12),
                        arrow(Icons.arrow_forward_rounded, 'Avanti', () => _by(1)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: context.fluid(32, 56)),
          SizedBox(
            height: w * 1.25 + 74,
            child: ListView.separated(
              controller: _c,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: context.gutter),
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 20),
              itemBuilder: (context, i) => _CarouselCard(
                photo: photos[i],
                width: w,
                index: i,
                onTap: () => showLightbox(context, items, i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselCard extends StatefulWidget {
  const _CarouselCard({
    required this.photo,
    required this.width,
    required this.index,
    required this.onTap,
  });
  final GalleryPhoto photo;
  final double width;
  final int index;
  final VoidCallback onTap;

  @override
  State<_CarouselCard> createState() => _CarouselCardState();
}

class _CarouselCardState extends State<_CarouselCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final p = widget.photo;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: widget.width * 1.25,
                child: ClipRect(
                  child: AnimatedScale(
                    scale: _hover ? 1.06 : 1,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    child: PhotoImage(p.url),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (widget.index + 1).toString().padLeft(2, '0'),
                    style: t.label(10.5, color: t.accentText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.display(22, height: 1.1),
                        ),
                        if (p.category.isNotEmpty)
                          Text(
                            p.category.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.label(10, color: t.muted),
                          ),
                      ],
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

// ----------------------------------------------------------------- marchi

/// Nastro che scorre all'infinito (si ferma passandoci sopra col mouse).
class Marquee extends StatefulWidget {
  const Marquee({
    super.key,
    required this.children,
    required this.height,
    this.speed = 40,
    this.reverse = false,
  });
  final List<Widget> children;
  final double height;

  /// Pixel al secondo.
  final double speed;
  final bool reverse;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  final _c = ScrollController();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (_paused || !_c.hasClients || dt <= 0 || dt > 0.2) return;
    _c.jumpTo(_c.offset + widget.speed * dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.children.length;
    if (n == 0) return SizedBox(height: widget.height);
    return MouseRegion(
      onEnter: (_) => _paused = true,
      onExit: (_) => _paused = false,
      child: SizedBox(
        height: widget.height,
        child: ListView.builder(
          controller: _c,
          reverse: widget.reverse,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, i) => widget.children[i % n],
        ),
      ),
    );
  }
}

class BrandsBand extends StatelessWidget {
  const BrandsBand({super.key, required this.content, required this.brands});
  final SiteContent content;
  final List<Brand> brands;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final size = context.fluid(30, 58);
    Widget item(Brand b) => Semantics(
      link: true,
      label: b.name,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go('/marchi'),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.fluid(22, 44)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BrandWordmark(brand: b, size: size),
                SizedBox(width: context.fluid(44, 88)),
                Transform.rotate(
                  angle: 0.785398,
                  child: Container(width: 7, height: 7, color: t.accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final half = (brands.length / 2).ceil();
    final rowA = [for (final b in brands.take(half)) item(b)];
    final rowB = [for (final b in brands.skip(half)) item(b)];

    return Container(
      color: t.alt,
      padding: EdgeInsets.symmetric(vertical: context.fluid(72, 130)),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.gutter),
            child: Reveal(
              child: SectionHeading(
                kicker: content.brandsKicker,
                number: '04',
                title: content.brandsTitle,
                intro: content.brandsIntro,
                center: true,
              ),
            ),
          ),
          SizedBox(height: context.fluid(40, 80)),
          Container(height: 1, color: t.line),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Marquee(height: size * 1.6, speed: 45, children: rowA),
          ),
          if (rowB.isNotEmpty) ...[
            Container(height: 1, color: t.line),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Marquee(
                height: size * 1.6,
                speed: 35,
                reverse: true,
                children: rowB,
              ),
            ),
          ],
          Container(height: 1, color: t.line),
          SizedBox(height: context.fluid(36, 56)),
          PillButton('Tutti i marchi', filled: false, onTap: () => context.go('/marchi')),
        ],
      ),
    );
  }
}

/// Il marchio: logo se caricato, altrimenti il nome in carattere elegante.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, required this.brand, required this.size});
  final Brand brand;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    if (brand.logo.trim().isNotEmpty) {
      return SizedBox(
        height: size * 1.1,
        width: size * 3.6,
        child: PhotoImage(brand.logo, fit: BoxFit.contain),
      );
    }
    return Center(
      child: Text(
        brand.name,
        maxLines: 1,
        softWrap: false,
        style: t.display(size, height: 1),
      ),
    );
  }
}

// ----------------------------------------------------------------- metodo

class ProcessSection extends StatelessWidget {
  const ProcessSection({
    super.key,
    required this.title,
    required this.steps,
    this.number,
    this.color,
  });
  final String title;
  final List<Milestone> steps;
  final String? number;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final cols = context.isPhone ? 1 : (context.isTablet ? 2 : 4);
    return Section(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            child: SectionHeading(
              kicker: 'Il metodo',
              number: number,
              title: title,
            ),
          ),
          SizedBox(height: context.fluid(40, 80)),
          LayoutBuilder(
            builder: (context, box) {
              const gap = 28.0;
              final w = (box.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: 40,
                children: [
                  for (var i = 0; i < steps.length; i++)
                    SizedBox(
                      width: w,
                      child: Reveal(
                        delay: Duration(milliseconds: 120 * (i % cols)),
                        child: Container(
                          padding: const EdgeInsets.only(top: 22),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: t.ink, width: 1.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                steps[i].year,
                                style: t.display(
                                  context.fluid(40, 56),
                                  color: t.accentText,
                                  italic: true,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(steps[i].title, style: t.display(26, height: 1.15)),
                              const SizedBox(height: 10),
                              Text(steps[i].text, style: t.body(14.5, color: t.muted)),
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
      ),
    );
  }
}

// ----------------------------------------------------------- invito finale

class CtaBanner extends StatelessWidget {
  const CtaBanner({
    super.key,
    required this.title,
    required this.text,
    required this.button,
    required this.image,
  });
  final String title;
  final String text;
  final String button;
  final String image;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    return SizedBox(
      height: context.fluid(520, 680),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PhotoImage(image),
          const ColoredBox(color: Color(0x8C000000)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.gutter),
            child: Center(
              child: Reveal(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tag('Preventivo gratuito', color: Colors.white),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: t.display(
                          context.fluid(42, 84),
                          color: Colors.white,
                          italic: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: t.body(
                          context.fluid(15, 17),
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                      const SizedBox(height: 34),
                      PillButton(
                        button,
                        light: true,
                        big: true,
                        onTap: () => context.go('/preventivo'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cerchio con le iniziali (persone senza foto).
class Initials extends StatelessWidget {
  const Initials({super.key, required this.name, this.size = 64});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final ini = parts.take(2).map((e) => e[0].toUpperCase()).join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: t.alt, shape: BoxShape.circle),
      child: Text(ini, style: t.display(size * 0.4, color: t.accentText)),
    );
  }
}

/// Apre il preventivo già impostato su un ambiente.
void goQuoteForRoom(BuildContext context, Room r) =>
    context.go('/preventivo?a=${Uri.encodeQueryComponent(r.title)}');

/// Usato dalle pagine per mettere un link al telefono del negozio.
void callShop(String phone) => openUrl('tel:${digitsOf(phone)}');
