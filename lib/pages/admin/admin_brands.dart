import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import 'admin_widgets.dart';

// =================================================================== MARCHI

class AdminBrands extends StatelessWidget {
  const AdminBrands({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminHeader(
          title: 'Marchi',
          subtitle:
              'Scorrono nel nastro della home e hanno una pagina tutta loro. Senza logo si mostra il nome.',
          actions: [
            FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _BrandDialog(),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuovo marchio'),
            ),
          ],
        ),
        Card(
          child: s.brands.isEmpty
              ? const EmptyState(
                  icon: Icons.workspace_premium_outlined,
                  message: 'Nessun marchio inserito.',
                )
              : ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: s.brands.length,
                  onReorderItem: (o, n) => s.setBrands(moveItem(s.brands, o, n)),
                  itemBuilder: (context, i) {
                    final b = s.brands[i];
                    return AdminListRow(
                      key: ValueKey(b.id),
                      index: i,
                      image: b.logo,
                      title: b.name,
                      dimmed: !b.active,
                      subtitle: [
                        b.category,
                        b.description,
                      ].where((e) => e.isNotEmpty).join(' · '),
                      trailing: [
                        Tooltip(
                          message: b.active ? 'Visibile sul sito' : 'Nascosto',
                          child: Switch(
                            value: b.active,
                            onChanged: (v) {
                              b.active = v;
                              s.setBrands([...s.brands]);
                            },
                          ),
                        ),
                      ],
                      onEdit: () => showDialog(
                        context: context,
                        builder: (_) => _BrandDialog(existing: b),
                      ),
                      onDelete: () async {
                        if (await confirmDialog(
                          context,
                          'Eliminare il marchio “${b.name}”? Verrà tolto anche dagli ambienti.',
                        )) {
                          s.deleteBrand(b.id);
                        }
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _BrandDialog extends StatefulWidget {
  const _BrandDialog({this.existing});
  final Brand? existing;

  @override
  State<_BrandDialog> createState() => _BrandDialogState();
}

class _BrandDialogState extends State<_BrandDialog> {
  final _form = GlobalKey<FormState>();
  late final Brand _d = widget.existing == null
      ? Brand(name: '')
      : Brand.fromJson(widget.existing!.toJson());
  late final _cat = TextEditingController(text: _d.category);

  @override
  void dispose() {
    _cat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final cats = {
      for (final b in s.brands)
        if (b.category.trim().isNotEmpty) b.category.trim(),
    }.toList();
    const gap = SizedBox(height: 16);
    return AlertDialog(
      title: Text(widget.existing == null ? 'Nuovo marchio' : 'Modifica marchio'),
      content: SizedBox(
        width: dialogWidth(context, 560),
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _d.name,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  onChanged: (v) => _d.name = v,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Inserisci il nome'
                      : null,
                ),
                gap,
                TextFormField(
                  controller: _cat,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    helperText: 'Serve per i filtri della pagina Marchi.',
                  ),
                  onChanged: (v) => _d.category = v,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in cats)
                      ActionChip(
                        label: Text(c),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() {
                          _cat.text = c;
                          _d.category = c;
                        }),
                      ),
                  ],
                ),
                gap,
                TextFormField(
                  initialValue: _d.description,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descrizione breve',
                    alignLabelWithHint: true,
                  ),
                  onChanged: (v) => _d.description = v,
                ),
                gap,
                TextFormField(
                  initialValue: _d.website,
                  decoration: const InputDecoration(
                    labelText: 'Sito ufficiale (facoltativo)',
                    hintText: 'https://…',
                  ),
                  onChanged: (v) => _d.website = v.trim(),
                ),
                const SizedBox(height: 18),
                ImageField(
                  label: 'Logo (facoltativo, meglio PNG con fondo trasparente)',
                  aspect: 3 / 1,
                  value: _d.logo,
                  onChanged: (v) => _d.logo = v,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Visibile sul sito'),
                  value: _d.active,
                  onChanged: (v) => setState(() => _d.active = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            _d.name = _d.name.trim();
            _d.category = _d.category.trim();
            final list = [...s.brands];
            if (widget.existing == null) {
              list.add(_d);
            } else {
              final i = list.indexWhere((e) => e.id == _d.id);
              if (i >= 0) list[i] = _d;
            }
            s.setBrands(list);
            Navigator.pop(context);
            toast(context, 'Salvato.');
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}

// =============================================================== RECENSIONI

class AdminReviews extends StatefulWidget {
  const AdminReviews({super.key});

  @override
  State<AdminReviews> createState() => _AdminReviewsState();
}

class _AdminReviewsState extends State<AdminReviews> {
  bool _onlyPending = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pending = s.pendingReviews;
    final list = _onlyPending
        ? s.reviews.where((r) => !r.published).toList()
        : s.reviews;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminHeader(
          title: 'Recensioni',
          subtitle:
              'Quelle scritte dai clienti sul sito restano nascoste finché non le approvi.',
          actions: [
            FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _ReviewDialog(),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuova recensione'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: Text('Tutte (${s.reviews.length})'),
              selected: !_onlyPending,
              onSelected: (_) => setState(() => _onlyPending = false),
            ),
            ChoiceChip(
              label: Text('Da approvare ($pending)'),
              selected: _onlyPending,
              onSelected: (_) => setState(() => _onlyPending = true),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (list.isEmpty)
          const Card(
            child: EmptyState(
              icon: Icons.reviews_outlined,
              message: 'Nessuna recensione qui.',
            ),
          ),
        for (final r in list)
          Padding(
            key: ValueKey(r.id),
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (var i = 1; i <= 5; i++)
                          Icon(
                            i <= r.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 18,
                            color: const Color(0xFFC8962E),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${r.name}${r.project.isEmpty ? '' : ' · ${r.project}'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (!r.published)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x1FC25B2E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Da approvare',
                              style: TextStyle(
                                color: Color(0xFFC25B2E),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('“${r.text}”'),
                    const SizedBox(height: 6),
                    Text(
                      '${r.fromSite ? 'Inviata dal sito' : 'Inserita da te'} · ${DateFormat('d MMM y', 'it_IT').format(r.createdAt)}',
                      style: const TextStyle(color: Colors.black45, fontSize: 12.5),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        if (r.published)
                          OutlinedButton.icon(
                            onPressed: () {
                              r.published = false;
                              s.setReviews([...s.reviews]);
                            },
                            icon: const Icon(Icons.visibility_off_outlined, size: 18),
                            label: const Text('Nascondi'),
                          )
                        else
                          FilledButton.icon(
                            onPressed: () {
                              r.published = true;
                              s.setReviews([...s.reviews]);
                              toast(context, 'Recensione pubblicata.');
                            },
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Approva e pubblica'),
                          ),
                        TextButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => _ReviewDialog(existing: r),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: const Text('Modifica'),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            if (await confirmDialog(
                              context,
                              'Eliminare la recensione di ${r.name}?',
                            )) {
                              s.setReviews(
                                s.reviews.where((e) => e.id != r.id).toList(),
                              );
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFB3382A),
                          ),
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: const Text('Elimina'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({this.existing});
  final Review? existing;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  final _form = GlobalKey<FormState>();
  late final Review _d = widget.existing == null
      ? Review(name: '', text: '')
      : Review.fromJson(widget.existing!.toJson());

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    const gap = SizedBox(height: 16);
    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Nuova recensione' : 'Modifica recensione',
      ),
      content: SizedBox(
        width: dialogWidth(context, 520),
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      IconButton(
                        tooltip: '$i stelle',
                        onPressed: () => setState(() => _d.rating = i),
                        icon: Icon(
                          i <= _d.rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: const Color(0xFFC8962E),
                        ),
                      ),
                  ],
                ),
                gap,
                TextFormField(
                  initialValue: _d.name,
                  decoration: const InputDecoration(labelText: 'Nome del cliente *'),
                  onChanged: (v) => _d.name = v,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Inserisci il nome'
                      : null,
                ),
                gap,
                TextFormField(
                  initialValue: _d.project,
                  decoration: const InputDecoration(
                    labelText: 'Cosa avete arredato (es. Cucina e soggiorno)',
                  ),
                  onChanged: (v) => _d.project = v,
                ),
                gap,
                TextFormField(
                  initialValue: _d.text,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Testo *',
                    alignLabelWithHint: true,
                  ),
                  onChanged: (v) => _d.text = v,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Scrivi il testo'
                      : null,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Pubblicata sul sito'),
                  value: _d.published,
                  onChanged: (v) => setState(() => _d.published = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            _d.name = _d.name.trim();
            _d.text = _d.text.trim();
            final list = [...s.reviews];
            if (widget.existing == null) {
              list.insert(0, _d);
            } else {
              final i = list.indexWhere((e) => e.id == _d.id);
              if (i >= 0) list[i] = _d;
            }
            s.setReviews(list);
            Navigator.pop(context);
            toast(context, 'Salvato.');
          },
          child: const Text('Salva'),
        ),
      ],
    );
  }
}
