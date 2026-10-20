import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/site_theme.dart';
import 'common.dart';
import 'sections.dart';

/// Stelle da 1 a 5 (anche selezionabili, se c'è [onChanged]).
class Stars extends StatelessWidget {
  const Stars({super.key, required this.value, this.size = 18, this.onChanged});
  final int value;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          onChanged == null
              ? Icon(
                  i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: size,
                  color: t.accentText,
                )
              : Semantics(
                  button: true,
                  label: '$i stelle',
                  child: InkResponse(
                    onTap: () => onChanged!(i),
                    radius: size,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        i <= value
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: size,
                        color: t.accentText,
                      ),
                    ),
                  ),
                ),
      ],
    );
  }
}

/// Recensioni dei clienti: media, carosello che scorre da solo e invito a
/// lasciarne una.
class ReviewsSection extends StatefulWidget {
  const ReviewsSection({
    super.key,
    required this.kicker,
    required this.title,
    required this.reviews,
    this.number,
  });
  final String kicker;
  final String title;
  final String? number;
  final List<Review> reviews;

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  PageController? _c;
  double? _fraction;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 7), (_) => _go(1));
  }

  void _go(int d) {
    final c = _c;
    final n = widget.reviews.length;
    if (c == null || !c.hasClients || n < 2) return;
    final perView = (1 / (_fraction ?? 1)).floor().clamp(1, n);
    final last = n - perView;
    var next = _page + d;
    if (next > last) next = 0;
    if (next < 0) next = last;
    c.animateToPage(
      next,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final list = widget.reviews;
    final fraction = context.isPhone ? 0.9 : (context.isTablet ? 0.5 : 1 / 3);
    if (_fraction != fraction) {
      _c?.dispose();
      _c = PageController(viewportFraction: fraction, initialPage: 0);
      _fraction = fraction;
      _page = 0;
    }
    final avg = list.isEmpty
        ? 0.0
        : list.map((e) => e.rating).reduce((a, b) => a + b) / list.length;
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

    return Section(
      color: t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Reveal(
            child: SectionHeading(
              kicker: widget.kicker,
              number: widget.number,
              title: widget.title,
              trailing: list.isEmpty
                  ? null
                  : Row(
                      children: [
                        Text(
                          avg.toStringAsFixed(1).replaceAll('.', ','),
                          style: t.display(56, color: t.accentText, height: 1),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stars(value: avg.round(), size: 20),
                            const SizedBox(height: 4),
                            Text(
                              '${list.length} ${list.length == 1 ? 'RECENSIONE' : 'RECENSIONI'}',
                              style: t.label(10.5, color: t.muted),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: context.fluid(36, 64)),
          if (list.isNotEmpty)
            SizedBox(
              height: context.isPhone ? 330 : 310,
              child: PageView.builder(
                controller: _c,
                padEnds: false,
                itemCount: list.length,
                onPageChanged: (i) => _page = i,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: _ReviewCard(review: list[i]),
                ),
              ),
            ),
          SizedBox(height: context.fluid(28, 40)),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              PillButton(
                'Lascia una recensione',
                filled: false,
                icon: Icons.edit_outlined,
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const _ReviewDialog(),
                ),
              ),
              if (list.length > 1 && !context.isPhone)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    arrow(Icons.arrow_back_rounded, 'Indietro', () {
                      _go(-1);
                      _timer?.cancel();
                    }),
                    const SizedBox(width: 12),
                    arrow(Icons.arrow_forward_rounded, 'Avanti', () {
                      _go(1);
                      _timer?.cancel();
                    }),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final r = review;
    return Container(
      padding: EdgeInsets.all(context.fluid(22, 32)),
      decoration: BoxDecoration(
        color: t.bg,
        border: Border.all(color: t.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stars(value: r.rating, size: 17),
              const Spacer(),
              Text(
                '“',
                style: t.display(64, color: t.accent.withValues(alpha: 0.5), height: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Text(
              r.text,
              overflow: TextOverflow.fade,
              style: t.display(context.fluid(20, 24), italic: true, height: 1.3),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Initials(name: r.name, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.body(14.5, weight: FontWeight.w600, height: 1.3),
                    ),
                    if (r.project.isNotEmpty)
                      Text(
                        r.project.toUpperCase(),
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
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog();

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _project = TextEditingController();
  final _text = TextEditingController();
  int _rating = 5;
  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _project.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    await context.read<AppState>().submitReview(
      Review(
        name: _name.text.trim(),
        project: _project.text.trim(),
        text: _text.text.trim(),
        rating: _rating,
      ),
    );
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final w = (context.w - 80).clamp(260.0, 520.0);
    if (_sent) {
      return AlertDialog(
        title: Text('Grazie!', style: t.display(34, italic: true)),
        content: SizedBox(
          width: w,
          child: Text(
            'La tua recensione è arrivata: la pubblicheremo dopo una rapida verifica.',
            style: t.body(15, color: t.muted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Chiudi', style: t.label(12)),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text('La tua esperienza', style: t.display(32)),
      content: SizedBox(
        width: w,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stars(
                  value: _rating,
                  size: 32,
                  onChanged: (v) => setState(() => _rating = v),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _name,
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Il tuo nome *'),
                  validator: (v) => (v ?? '').trim().length < 2
                      ? 'Scrivi il tuo nome'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _project,
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  decoration: const InputDecoration(
                    labelText: 'Cosa abbiamo arredato (es. Cucina)',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _text,
                  minLines: 3,
                  maxLines: 6,
                  inputFormatters: [LengthLimitingTextInputFormatter(400)],
                  decoration: const InputDecoration(
                    labelText: 'La tua recensione *',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => (v ?? '').trim().length < 10
                      ? 'Scrivi almeno qualche parola (10 caratteri)'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annulla', style: t.label(12, color: t.muted)),
        ),
        PillButton('Invia', icon: Icons.send_rounded, onTap: _send),
      ],
    );
  }
}
