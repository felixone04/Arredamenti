import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/site_theme.dart';
import '../widgets/common.dart';
import '../widgets/site_scaffold.dart';

// ------------------------------------------------------------ controlli

/// Il "+" del prefisso internazionale è ammesso solo come primo carattere.
class _PlusOnlyFirst extends TextInputFormatter {
  const _PlusOnlyFirst();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final lead = newValue.text.trimLeft();
    final plus = lead.startsWith('+');
    final out =
        (plus ? '+' : '') + (plus ? lead.substring(1) : lead).replaceAll('+', '');
    if (out == newValue.text) return newValue;
    return TextEditingValue(
      text: out,
      selection: TextSelection.collapsed(offset: out.length),
    );
  }
}

final _phoneFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
  const _PlusOnlyFirst(),
  LengthLimitingTextInputFormatter(20),
];

final _nameFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿ' \-]")),
  LengthLimitingTextInputFormatter(40),
];

final _emailFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.deny(RegExp(r'\s')),
  LengthLimitingTextInputFormatter(80),
];

final _emailRe = RegExp(
  r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$',
);

/// Controlli dei campi (usati sia dal modulo sia dai test).
abstract final class QuoteRules {
  static String? name(String? v, String what) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Inserisci il $what';
    if (t.replaceAll(RegExp(r"[' \-]"), '').length < 2) {
      return 'Il $what deve avere almeno 2 lettere';
    }
    return null;
  }

  static String? phone(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Inserisci il numero di telefono';
    final d = t.replaceAll(RegExp(r'\D'), '');
    if (d.length < 8 || d.length > 15) {
      return 'Numero non valido: servono da 8 a 15 cifre';
    }
    return null;
  }

  static String? email(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Inserisci l\'indirizzo email';
    return _emailRe.hasMatch(t) ? null : 'Email non valida (es. nome@email.it)';
  }

  static String? city(String? v) =>
      (v ?? '').trim().length < 2 ? 'Indica la città dell\'immobile' : null;

  static String? size(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null || n < 1 || n > 5000) return 'Scrivi i metri quadri (1–5000)';
    return null;
  }
}

// ------------------------------------------------------------------ pagina

class QuotePage extends StatefulWidget {
  const QuotePage({super.key, this.preService, this.prePackage, this.preRoom});
  final String? preService;
  final String? prePackage;

  /// Ambiente da cui si arriva (es. dal pulsante nella pagina "Cucina").
  final String? preRoom;

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  final _formKey = GlobalKey<FormState>();
  final _topAnchor = GlobalKey();
  final _projectKey = GlobalKey();
  final _contactsKey = GlobalKey();
  final _privacyKey = GlobalKey();

  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _city = TextEditingController();
  final _size = TextEditingController();
  final _message = TextEditingController();

  final Set<String> _rooms = {};
  String? _style;
  String? _budget;
  String? _timing;
  final Set<String> _services = {};
  String? _packageId;
  bool _privacy = false;
  bool _tried = false;
  bool _sending = false;
  String? _sendError;
  QuoteRequest? _sent;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    final p = s.packageById(widget.prePackage);
    if (p != null && p.active) {
      _pickPackage(s, p);
    } else if (widget.preService != null &&
        (s.serviceById(widget.preService!)?.active ?? false)) {
      _services.add(widget.preService!);
    }
    // L'ambiente arriva col suo nome: si spunta la voce corrispondente.
    final room = widget.preRoom?.trim().toLowerCase();
    if (room != null && room.isNotEmpty) {
      for (final r in s.content.roomTypes) {
        if (r.toLowerCase() == room) _rooms.add(r);
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_first, _last, _phone, _email, _city, _size, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  void _pickPackage(AppState s, ServicePackage p) {
    _packageId = p.id;
    _services
      ..clear()
      ..addAll(p.serviceIds.where((id) => s.serviceById(id)?.active ?? false));
  }

  List<String> _selectedServices(AppState s) => [
    for (final sv in s.activeServices)
      if (_services.contains(sv.id)) sv.id,
  ];

  String? _roomsError(AppState s) =>
      _rooms.isEmpty && s.content.roomTypes.isNotEmpty
      ? 'Scegli almeno un ambiente'
      : null;

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
      alignment: 0.1,
    );
  }

  GlobalKey? _firstError(AppState s) {
    if (_roomsError(s) != null ||
        QuoteRules.city(_city.text) != null ||
        QuoteRules.size(_size.text) != null) {
      return _projectKey;
    }
    if (QuoteRules.name(_first.text, 'nome') != null ||
        QuoteRules.name(_last.text, 'cognome') != null ||
        QuoteRules.phone(_phone.text) != null ||
        QuoteRules.email(_email.text) != null) {
      return _contactsKey;
    }
    if (!_privacy) return _privacyKey;
    return null;
  }

  Future<void> _submit(AppState s) async {
    setState(() => _tried = true);
    final okForm = _formKey.currentState!.validate();
    final err = _firstError(s);
    if (!okForm || err != null) {
      if (err != null) _scrollTo(err);
      return;
    }
    setState(() {
      _sending = true;
      _sendError = null;
    });
    final q = QuoteRequest(
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      city: _city.text.trim(),
      rooms: [
        for (final r in s.content.roomTypes)
          if (_rooms.contains(r)) r,
      ],
      style: _style ?? '',
      budget: _budget ?? '',
      timing: _timing ?? '',
      size: _size.text.trim(),
      message: _message.text.trim(),
      serviceIds: _selectedServices(s),
      packageId: _packageId,
    );
    try {
      await s.addQuote(q);
    } catch (_) {
      if (mounted) {
        setState(() {
          _sending = false;
          _sendError = 'Invio non riuscito. Riprova tra qualche istante.';
        });
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = q;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollTo(_topAnchor));
  }

  void _reset() => setState(() {
    _sent = null;
    _tried = false;
    _rooms.clear();
    _services.clear();
    _packageId = null;
    _style = null;
    _budget = null;
    _timing = null;
    for (final c in [_city, _size, _message]) {
      c.clear();
    }
    _privacy = false;
  });

  // ----------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final c = s.content;
    final image = c.quoteImage.trim().isNotEmpty
        ? c.quoteImage
        : (s.heroPhotos.isEmpty ? '' : s.heroPhotos.first.url);

    return SiteScaffold(
      location: '/preventivo',
      children: [
        SizedBox(key: _topAnchor, height: 0),
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.gutter,
            context.fluid(36, 80),
            context.gutter,
            context.fluid(70, 120),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: _sent != null
                  ? _Success(quote: _sent!, onNew: _reset)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(content: c, image: image),
                        SizedBox(height: context.fluid(32, 56)),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 880),
                            child: _buildForm(s),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AppState s) {
    final t = context.st;
    final c = s.content;
    final twoCols = context.w >= 720;
    Widget pair(Widget a, Widget b) => twoCols
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              const SizedBox(width: 16),
              Expanded(child: b),
            ],
          )
        : Column(children: [a, const SizedBox(height: 16), b]);
    const gap = SizedBox(height: 16);
    const live = AutovalidateMode.onUserInteraction;
    final roomsError = _tried ? _roomsError(s) : null;

    final cats = <String>[];
    for (final sv in s.activeServices) {
      if (!cats.contains(sv.category)) cats.add(sv.category);
    }

    Widget dropdown(
      String label,
      List<String> options,
      String? value,
      ValueChanged<String?> onChanged,
    ) => DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final o in options) DropdownMenuItem(value: o, child: Text(o)),
      ],
      onChanged: onChanged,
    );

    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(context.fluid(20, 48)),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Step(
              key: _projectKey,
              number: 1,
              title: 'Il progetto',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FieldLabel('Quali ambienti vuoi arredare? *'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in c.roomTypes)
                        _ChoicePill(
                          label: r,
                          selected: _rooms.contains(r),
                          onTap: () => setState(() {
                            if (!_rooms.remove(r)) _rooms.add(r);
                          }),
                        ),
                    ],
                  ),
                  if (roomsError != null) _ErrorText(roomsError),
                  if (c.styles.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    _FieldLabel('Lo stile che ti piace'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final st in c.styles)
                          _ChoicePill(
                            label: st,
                            selected: _style == st,
                            onTap: () => setState(
                              () => _style = _style == st ? null : st,
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 26),
                  pair(
                    TextFormField(
                      controller: _city,
                      autovalidateMode: live,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [LengthLimitingTextInputFormatter(60)],
                      decoration: const InputDecoration(
                        labelText: 'Città dell\'immobile *',
                      ),
                      validator: QuoteRules.city,
                    ),
                    TextFormField(
                      controller: _size,
                      autovalidateMode: live,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Metri quadri (facoltativo)',
                        suffixText: 'm²',
                      ),
                      validator: QuoteRules.size,
                    ),
                  ),
                  gap,
                  pair(
                    dropdown(
                      'Budget indicativo',
                      c.budgets,
                      _budget,
                      (v) => setState(() => _budget = v),
                    ),
                    dropdown(
                      'Quando vorresti iniziare',
                      c.timings,
                      _timing,
                      (v) => setState(() => _timing = v),
                    ),
                  ),
                ],
              ),
            ),
            if (s.activePackages.isNotEmpty || s.activeServices.isNotEmpty)
              _Step(
                number: 2,
                title: 'Formule e servizi',
                subtitle: 'Facoltativo: scegli una formula pronta o le singole voci.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (s.activePackages.isNotEmpty) ...[
                      LayoutBuilder(
                        builder: (context, box) {
                          final n = box.maxWidth > 640 ? 3 : 1;
                          const g = 12.0;
                          final w = (box.maxWidth - g * (n - 1)) / n;
                          return Wrap(
                            spacing: g,
                            runSpacing: g,
                            children: [
                              for (final p in s.activePackages)
                                SizedBox(
                                  width: w,
                                  child: _PackageCard(
                                    pkg: p,
                                    selected: _packageId == p.id,
                                    onTap: () => setState(() {
                                      if (_packageId == p.id) {
                                        _packageId = null;
                                        _services.clear();
                                      } else {
                                        _pickPackage(s, p);
                                      }
                                    }),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                    ],
                    for (final cat in cats) ...[
                      _FieldLabel(cat),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final sv in s.activeServices.where(
                            (e) => e.category == cat,
                          ))
                            _ChoicePill(
                              label: sv.name,
                              tooltip: sv.description,
                              selected: _services.contains(sv.id),
                              onTap: () => setState(() {
                                if (!_services.remove(sv.id)) {
                                  _services.add(sv.id);
                                }
                                _packageId = null;
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),
            _Step(
              key: _contactsKey,
              number: s.activePackages.isNotEmpty || s.activeServices.isNotEmpty
                  ? 3
                  : 2,
              title: 'I tuoi contatti',
              last: true,
              child: Column(
                children: [
                  pair(
                    TextFormField(
                      controller: _first,
                      autovalidateMode: live,
                      inputFormatters: _nameFormatters,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.givenName],
                      decoration: const InputDecoration(labelText: 'Nome *'),
                      validator: (v) => QuoteRules.name(v, 'nome'),
                    ),
                    TextFormField(
                      controller: _last,
                      autovalidateMode: live,
                      inputFormatters: _nameFormatters,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.familyName],
                      decoration: const InputDecoration(labelText: 'Cognome *'),
                      validator: (v) => QuoteRules.name(v, 'cognome'),
                    ),
                  ),
                  gap,
                  pair(
                    TextFormField(
                      controller: _phone,
                      autovalidateMode: live,
                      keyboardType: TextInputType.phone,
                      inputFormatters: _phoneFormatters,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: const InputDecoration(
                        labelText: 'Telefono *',
                      ),
                      validator: QuoteRules.phone,
                    ),
                    TextFormField(
                      controller: _email,
                      autovalidateMode: live,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: _emailFormatters,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(labelText: 'Email *'),
                      validator: QuoteRules.email,
                    ),
                  ),
                  gap,
                  TextFormField(
                    controller: _message,
                    minLines: 3,
                    maxLines: 6,
                    inputFormatters: [LengthLimitingTextInputFormatter(1500)],
                    decoration: const InputDecoration(
                      labelText: 'Raccontaci il progetto (facoltativo)',
                      hintText: 'Misure, idee, foto che ti piacciono, vincoli…',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              key: _privacyKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _privacy,
                    onChanged: (v) => setState(() => _privacy = v ?? false),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _privacy = !_privacy),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Acconsento al trattamento dei miei dati per essere ricontattato riguardo a questa richiesta. *',
                          style: t.body(13.5, color: t.muted),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_tried && !_privacy)
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: _ErrorText('Serve il consenso per inviare la richiesta'),
              ),
            if (_sendError != null) _ErrorText(_sendError!),
            const SizedBox(height: 26),
            Align(
              alignment: twoCols ? Alignment.centerRight : Alignment.center,
              child: PillButton(
                'Invia la richiesta',
                big: true,
                loading: _sending,
                icon: Icons.send_rounded,
                onTap: () => _submit(s),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.content, required this.image});
  final SiteContent content;
  final String image;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final c = content.contacts;
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Tag('Preventivo gratuito'),
        SizedBox(height: context.fluid(18, 28)),
        Text(
          content.quoteTitle,
          style: t.display(context.fluid(48, 100), height: 1),
        ),
        const SizedBox(height: 20),
        Text(
          content.quoteIntro,
          style: t.body(context.fluid(15, 17), color: t.muted),
        ),
        if (c.phone.isNotEmpty || c.email.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            'PREFERISCI PARLARCI?',
            style: t.label(10.5, color: t.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 24,
            runSpacing: 4,
            children: [
              if (c.phone.isNotEmpty)
                HoverLink(
                  c.phone,
                  style: t.display(22),
                  onTap: () => openUrl('tel:${digitsOf(c.phone)}'),
                ),
              if (c.email.isNotEmpty)
                HoverLink(
                  c.email,
                  style: t.display(22),
                  onTap: () => openUrl('mailto:${c.email}'),
                ),
            ],
          ),
        ],
      ],
    );
    if (context.isTablet || image.isEmpty) return Reveal(child: text);
    return Reveal(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 6, child: text),
          const SizedBox(width: 70),
          Expanded(
            flex: 5,
            child: AspectRatio(aspectRatio: 4 / 3.4, child: PhotoImage(image)),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    super.key,
    required this.number,
    required this.title,
    required this.child,
    this.subtitle,
    this.last = false,
  });
  final int number;
  final String title;
  final String? subtitle;
  final Widget child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : context.fluid(34, 48)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                number.toString().padLeft(2, '0'),
                style: t.display(
                  context.fluid(36, 48),
                  color: t.accentText,
                  italic: true,
                  height: 1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: t.display(context.fluid(26, 34), height: 1.1),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: t.body(13.5, color: t.muted)),
          ],
          const SizedBox(height: 10),
          Container(height: 1, color: t.line),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: context.st.label(10.5, color: context.st.muted),
    ),
  );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      style: context.st.body(
        12.5,
        color: Theme.of(context).colorScheme.error,
      ),
    ),
  );
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tooltip,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    final pill = Semantics(
      button: true,
      selected: selected,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? t.ink : t.bg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: selected ? t.ink : t.lineStrong),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(Icons.check_rounded, size: 15, color: t.bg),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: t.body(13.5, color: selected ? t.bg : t.ink, height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (tooltip == null || tooltip!.isEmpty) return pill;
    return Tooltip(message: tooltip!, child: pill);
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.pkg,
    required this.selected,
    required this.onTap,
  });
  final ServicePackage pkg;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Formula ${pkg.name}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: t.bg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected ? t.accent : t.line,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pkg.image.isNotEmpty)
                  SizedBox(height: 110, child: PhotoImage(pkg.image)),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pkg.name,
                              style: t.display(21, height: 1.15),
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 20,
                            color: selected ? t.accentText : t.muted,
                          ),
                        ],
                      ),
                      if (pkg.featured) ...[
                        const SizedBox(height: 4),
                        Text(
                          'LA PIÙ SCELTA',
                          style: t.label(9.5, color: t.accentText),
                        ),
                      ],
                      if (pkg.tagline.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(pkg.tagline, style: t.body(13, color: t.muted, height: 1.4)),
                      ],
                    ],
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

class _Success extends StatelessWidget {
  const _Success({required this.quote, required this.onNew});
  final QuoteRequest quote;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final t = context.st;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.fluid(40, 100)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: t.accent, width: 1.5),
                ),
                child: Icon(Icons.check_rounded, color: t.accentText, size: 36),
              ),
              const SizedBox(height: 30),
              Text(
                'Grazie, ${quote.firstName}.',
                textAlign: TextAlign.center,
                style: t.display(context.fluid(42, 72), italic: true),
              ),
              const SizedBox(height: 18),
              Text(
                'Abbiamo ricevuto la tua richiesta${quote.rooms.isEmpty ? '' : ' per ${quote.rooms.join(', ').toLowerCase()}'}. '
                'Ti ricontattiamo al più presto al ${quote.phone} per fissare un incontro.',
                textAlign: TextAlign.center,
                style: t.body(16, color: t.muted),
              ),
              const SizedBox(height: 36),
              Wrap(
                spacing: 14,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  PillButton('Torna alla home', onTap: () => context.go('/')),
                  PillButton(
                    'Nuova richiesta',
                    filled: false,
                    icon: Icons.add_rounded,
                    onTap: onNew,
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
