import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../widgets/common.dart';
import 'admin_widgets.dart';

// ================================================================= AMBIENTI

class AdminRooms extends StatelessWidget {
  const AdminRooms({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminHeader(
          title: 'Ambienti',
          subtitle:
              'In home compaiono uno dopo l\'altro, foto e descrizione. Trascina per riordinare.',
          actions: [
            FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const _RoomDialog(),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuovo ambiente'),
            ),
          ],
        ),
        storageWarning(s),
        Card(
          child: s.rooms.isEmpty
              ? const EmptyState(
                  icon: Icons.weekend_outlined,
                  message: 'Nessun ambiente ancora. Aggiungi il primo.',
                )
              : ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  itemCount: s.rooms.length,
                  onReorderItem: (o, n) => s.setRooms(moveItem(s.rooms, o, n)),
                  itemBuilder: (context, i) {
                    final r = s.rooms[i];
                    final meta = [
                      r.kicker,
                      '${r.photos.length} foto',
                      if (r.brandIds.isNotEmpty) '${r.brandIds.length} marchi',
                    ].where((e) => e.trim().isNotEmpty).join(' · ');
                    return AdminListRow(
                      key: ValueKey(r.id),
                      index: i,
                      image: r.coverUrl,
                      title: r.title,
                      subtitle: meta,
                      dimmed: !r.published,
                      trailing: [
                        Tooltip(
                          message: r.published
                              ? 'Visibile sul sito'
                              : 'Nascosto',
                          child: IconButton(
                            onPressed: () {
                              r.published = !r.published;
                              s.setRooms([...s.rooms]);
                            },
                            icon: Icon(
                              r.published
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: r.published
                                  ? Colors.black87
                                  : Colors.black38,
                            ),
                          ),
                        ),
                      ],
                      onEdit: () => showDialog(
                        context: context,
                        builder: (_) => _RoomDialog(existing: r),
                      ),
                      onDelete: () async {
                        if (await confirmDialog(
                          context,
                          'Eliminare l\'ambiente “${r.title}” con tutte le sue foto?',
                        )) {
                          s.setRooms(s.rooms.where((e) => e.id != r.id).toList());
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

class _RoomDialog extends StatefulWidget {
  const _RoomDialog({this.existing});
  final Room? existing;

  @override
  State<_RoomDialog> createState() => _RoomDialogState();
}

class _RoomDialogState extends State<_RoomDialog> {
  final _form = GlobalKey<FormState>();
  late final Room _d = widget.existing == null
      ? Room(title: '')
      : Room.fromJson(widget.existing!.toJson());
  bool _busy = false;
  String? _photosError;

  Future<void> _upload() async {
    setState(() => _busy = true);
    try {
      final files = await ImagePicker().pickMultiImage(
        maxWidth: 1800,
        imageQuality: 82,
      );
      for (final f in files) {
        final bytes = await f.readAsBytes();
        final mime = (f.mimeType?.startsWith('image/') ?? false)
            ? f.mimeType!
            : 'image/jpeg';
        _d.photos.add(
          RoomPhoto(url: 'data:$mime;base64,${base64Encode(bytes)}'),
        );
      }
      if (files.isNotEmpty) _photosError = null;
    } catch (e) {
      if (mounted) toast(context, 'Caricamento non riuscito: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addByUrl() async {
    var url = '';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Aggiungi foto'),
        content: SizedBox(
          width: dialogWidth(c, 480),
          child: ImageField(
            label: 'Fotografia',
            value: '',
            onChanged: (v) => url = v,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
    if (ok == true && url.trim().isNotEmpty && mounted) {
      setState(() {
        _d.photos.add(RoomPhoto(url: url.trim()));
        _photosError = null;
      });
    }
  }

  void _move(int i, int delta) => setState(() {
    final j = i + delta;
    if (j < 0 || j >= _d.photos.length) return;
    _d.photos.insert(j, _d.photos.removeAt(i));
  });

  void _save() {
    final ok = _form.currentState!.validate();
    setState(() {
      _d.photos.removeWhere((p) => p.url.trim().isEmpty);
      if (_d.photos.isEmpty && _d.cover.trim().isEmpty) {
        _photosError = 'Aggiungi almeno una foto o la copertina.';
      }
    });
    if ((_d.photos.isEmpty && _d.cover.trim().isEmpty) || !ok) return;
    _d.title = _d.title.trim();
    final s = context.read<AppState>();
    final list = [...s.rooms];
    if (widget.existing == null) {
      list.add(_d);
    } else {
      final i = list.indexWhere((e) => e.id == _d.id);
      if (i >= 0) list[i] = _d;
    }
    s.setRooms(list);
    Navigator.pop(context);
    toast(context, 'Salvato.');
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    const gap = SizedBox(height: 16);
    Widget text(
      String label,
      String value,
      ValueChanged<String> set, {
      int maxLines = 1,
      String? helper,
      bool required = false,
    }) => TextFormField(
      initialValue: value,
      minLines: maxLines > 1 ? 3 : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        helperText: helper,
        helperMaxLines: 2,
        alignLabelWithHint: maxLines > 1,
      ),
      onChanged: set,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obbligatorio' : null
          : null,
    );
    final narrow = isNarrow(context);

    return AlertDialog(
      title: Text(
        widget.existing == null ? 'Nuovo ambiente' : 'Modifica ambiente',
      ),
      content: SizedBox(
        width: dialogWidth(context, 760),
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FieldRow(
                  children: [
                    Expanded(
                      child: text(
                        'Nome',
                        _d.title,
                        (v) => _d.title = v,
                        required: true,
                        helper: 'Es. Soggiorno, Cucina, Camera da letto.',
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: text(
                        'Etichetta',
                        _d.kicker,
                        (v) => _d.kicker = v,
                        helper: 'Es. Zona giorno, Il cuore della casa.',
                      ),
                    ),
                  ],
                ),
                gap,
                text(
                  'Descrizione breve (in home)',
                  _d.description,
                  (v) => _d.description = v,
                  maxLines: 4,
                  required: true,
                ),
                gap,
                text(
                  'Racconto (nella pagina dell\'ambiente)',
                  _d.story,
                  (v) => _d.story = v,
                  maxLines: 8,
                  helper: 'Separa i paragrafi con una riga vuota.',
                ),
                gap,
                const Text(
                  'Caratteristiche',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                StringListEditor(
                  items: _d.features,
                  addLabel: 'Es. Su misura, Rovere naturale',
                  onChanged: (v) => _d.features = v,
                ),
                gap,
                if (s.brands.isNotEmpty) ...[
                  const Text(
                    'Marchi di questo ambiente',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final b in s.brands)
                        FilterChip(
                          label: Text(b.name),
                          selected: _d.brandIds.contains(b.id),
                          onSelected: (v) => setState(() {
                            if (v) {
                              _d.brandIds.add(b.id);
                            } else {
                              _d.brandIds.remove(b.id);
                            }
                          }),
                        ),
                    ],
                  ),
                  gap,
                ],
                ImageField(
                  label: 'Copertina (se vuota si usa la prima foto)',
                  aspect: 5 / 4,
                  value: _d.cover,
                  onChanged: (v) => _d.cover = v,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Foto (${_d.photos.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (_busy)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ogni foto ha la sua descrizione: nella pagina dell\'ambiente si susseguono in quest\'ordine.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _upload,
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Carica dal dispositivo'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _addByUrl,
                      icon: const Icon(Icons.link_rounded, size: 18),
                      label: const Text('Da indirizzo'),
                    ),
                  ],
                ),
                if (_photosError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _photosError!,
                      style: const TextStyle(
                        color: Color(0xFFB3382A),
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                for (var i = 0; i < _d.photos.length; i++)
                  _PhotoRow(
                    key: ObjectKey(_d.photos[i]),
                    photo: _d.photos[i],
                    number: i + 1,
                    narrow: narrow,
                    onUp: i > 0 ? () => _move(i, -1) : null,
                    onDown: i < _d.photos.length - 1 ? () => _move(i, 1) : null,
                    onDelete: () => setState(() => _d.photos.removeAt(i)),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Visibile sul sito'),
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
          onPressed: _busy ? null : _save,
          child: const Text('Salva'),
        ),
      ],
    );
  }
}

/// Una foto dell'ambiente: anteprima, descrizione e ordine.
class _PhotoRow extends StatelessWidget {
  const _PhotoRow({
    super.key,
    required this.photo,
    required this.number,
    required this.narrow,
    required this.onUp,
    required this.onDown,
    required this.onDelete,
  });
  final RoomPhoto photo;
  final int number;
  final bool narrow;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final thumb = narrow ? 56.0 : 80.0;
    final index = SizedBox(
      width: 26,
      child: Text(
        '$number',
        style: const TextStyle(color: Colors.black45, fontSize: 13),
      ),
    );
    final preview = ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: thumb,
        height: thumb * 0.72,
        child: PhotoImage(photo.url),
      ),
    );
    final caption = TextFormField(
      initialValue: photo.caption,
      maxLines: 2,
      minLines: 1,
      decoration: const InputDecoration(labelText: 'Descrizione', isDense: true),
      onChanged: (v) => photo.caption = v,
    );
    final buttons = [
      IconButton(
        tooltip: 'Sposta su',
        onPressed: onUp,
        icon: const Icon(Icons.arrow_upward_rounded, size: 18),
      ),
      IconButton(
        tooltip: 'Sposta giù',
        onPressed: onDown,
        icon: const Icon(Icons.arrow_downward_rounded, size: 18),
      ),
      IconButton(
        tooltip: 'Togli foto',
        onPressed: onDelete,
        icon: const Icon(Icons.close_rounded, size: 18),
      ),
    ];
    if (narrow) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          children: [
            Row(
              children: [
                preview,
                const SizedBox(width: 12),
                Expanded(child: caption),
              ],
            ),
            Row(children: [index, const Spacer(), ...buttons]),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          index,
          preview,
          const SizedBox(width: 12),
          Expanded(child: caption),
          ...buttons,
        ],
      ),
    );
  }
}
