import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/site_theme.dart';
import '../../widgets/site_scaffold.dart' show openUrl;
import 'admin_widgets.dart';

/// Link al sito pubblico con dei parametri (es. `?tema=notte&prova=1`).
String siteLink(Map<String, String> params) {
  final q = params.entries.map((e) => '${e.key}=${e.value}').join('&');
  final base = Uri.base.replace(fragment: '').toString().replaceAll('#', '');
  return '$base#/${q.isEmpty ? '' : '?$q'}';
}

class AdminLook extends StatelessWidget {
  const AdminLook({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final look = s.look;
    final trial = siteLink({'prova': '1'});

    Future<void> update(void Function(LookSettings l) f) {
      final l = LookSettings.fromJson(look.toJson());
      f(l);
      return s.setLook(l);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminHeader(
          title: 'Stile e temi',
          subtitle:
              'Lo stesso sito con colori e caratteri diversi: scegli quello predefinito '
              'e quali proporre ai clienti con il pulsante “Cambia stile”.',
          actions: [
            FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => ThemeEditorDialog(base: s.defaultTheme),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crea un tema'),
            ),
          ],
        ),
        Panel(
          title: 'Pulsante “Cambia stile”',
          subtitle: 'Compare in basso a sinistra sul sito.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadioGroup<SwitcherMode>(
                groupValue: look.switcher,
                onChanged: (v) {
                  if (v != null) update((l) => l.switcher = v);
                },
                child: Column(
                  children: [
                    for (final m in SwitcherMode.values)
                      RadioListTile<SwitcherMode>(
                        value: m,
                        contentPadding: EdgeInsets.zero,
                        title: Text(m.label),
                        subtitle: Text(switch (m) {
                          SwitcherMode.tutti =>
                            'Ogni visitatore può provare gli stili.',
                          SwitcherMode.link =>
                            'Lo vedi solo aprendo il link di prova: comodo in showroom, davanti al cliente.',
                          SwitcherMode.nessuno =>
                            'Il sito mostra sempre il tema predefinito.',
                        }),
                      ),
                  ],
                ),
              ),
              if (look.switcher == SwitcherMode.link) ...[
                const SizedBox(height: 10),
                _LinkBox(link: trial),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Panel(
          title: 'Temi',
          subtitle:
              'La stella indica il tema predefinito. Con “Link per il cliente” mandi il sito già vestito con quel tema.',
          child: LayoutBuilder(
            builder: (context, box) {
              final cols = box.maxWidth > 900 ? 3 : (box.maxWidth > 560 ? 2 : 1);
              const gap = 14.0;
              final w = (box.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final t in s.allThemes)
                    SizedBox(
                      width: w,
                      child: _ThemeCard(
                        theme: t,
                        isDefault: t.id == s.defaultTheme.id,
                        offered: !look.hidden.contains(t.id),
                        onDefault: () => update((l) {
                          l.defaultTheme = t.id;
                          l.hidden.remove(t.id);
                        }),
                        onOffered: (v) => update((l) {
                          if (v) {
                            l.hidden.remove(t.id);
                          } else if (!l.hidden.contains(t.id)) {
                            l.hidden.add(t.id);
                          }
                        }),
                        onEdit: () => showDialog(
                          context: context,
                          builder: (_) => ThemeEditorDialog(
                            base: t,
                            existing: t.custom ? t : null,
                          ),
                        ),
                        onDelete: t.custom
                            ? () async {
                                if (await confirmDialog(
                                  context,
                                  'Eliminare il tema “${t.name}”?',
                                )) {
                                  update((l) {
                                    l.custom.removeWhere((e) => e.id == t.id);
                                    l.hidden.remove(t.id);
                                    if (l.defaultTheme == t.id) {
                                      l.defaultTheme = builtInThemes.first.id;
                                    }
                                  });
                                }
                              }
                            : null,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LinkBox extends StatelessWidget {
  const _LinkBox({required this.link});
  final String link;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              link,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
          IconButton(
            tooltip: 'Copia',
            icon: const Icon(Icons.copy_rounded, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              if (context.mounted) toast(context, 'Link copiato.');
            },
          ),
          IconButton(
            tooltip: 'Apri',
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            onPressed: () => openUrl(link),
          ),
        ],
      ),
    );
  }
}

/// Anteprima in miniatura del sito con un tema.
class ThemePreview extends StatelessWidget {
  const ThemePreview({super.key, required this.theme, this.height = 130});
  final SiteTheme theme;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      height: height,
      color: t.bg,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Transform.rotate(
                angle: 0.785398,
                child: Container(width: 6, height: 6, color: t.accent),
              ),
              const SizedBox(width: 8),
              Text(
                'ARREDAMENTI',
                style: t.display(11, height: 1).copyWith(letterSpacing: 2.5),
              ),
              const Spacer(),
              Container(width: 18, height: 2, color: t.ink),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'La casa che\n', style: t.display(22, height: 1)),
                      TextSpan(
                        text: 'ti somiglia',
                        style: t.display(22, italic: true, color: t.accentText, height: 1),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: t.outlineButtons ? Colors.transparent : t.accent,
                  border: Border.all(color: t.outlineButtons ? t.accentText : t.accent),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'PREVENTIVO',
                  style: t.label(8, color: t.outlineButtons ? t.accentText : t.onAccent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final c in [t.surface, t.alt, t.muted, t.ink, t.accent])
                Expanded(child: Container(height: 8, color: c)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.isDefault,
    required this.offered,
    required this.onDefault,
    required this.onOffered,
    required this.onEdit,
    this.onDelete,
  });
  final SiteTheme theme;
  final bool isDefault;
  final bool offered;
  final VoidCallback onDefault;
  final ValueChanged<bool> onOffered;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDefault ? Theme.of(context).colorScheme.primary : const Color(0xFFE6DDD0),
          width: isDefault ? 2 : 1,
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ThemePreview(theme: t),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        '${t.headingFont} · ${t.dark ? 'scuro' : 'chiaro'}${t.custom ? ' · creato da te' : ''}',
                        style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isDefault ? 'Tema predefinito' : 'Rendi predefinito',
                  onPressed: isDefault ? null : onDefault,
                  icon: Icon(
                    isDefault ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isDefault ? const Color(0xFFC8962E) : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            title: const Text('Proponi nel pulsante'),
            value: offered || isDefault,
            onChanged: isDefault ? null : onOffered,
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Wrap(
              children: [
                TextButton.icon(
                  onPressed: () => openUrl(siteLink({'tema': t.id, 'prova': '1'})),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('Prova'),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: siteLink({'tema': t.id})),
                    );
                    if (context.mounted) {
                      toast(context, 'Link copiato: il sito si apre con “${t.name}”.');
                    }
                  },
                  icon: const Icon(Icons.link_rounded, size: 16),
                  label: const Text('Link per il cliente'),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: Icon(t.custom ? Icons.edit_outlined : Icons.copy_rounded, size: 16),
                  label: Text(t.custom ? 'Modifica' : 'Duplica e modifica'),
                ),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFB3382A),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Elimina'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================ EDITOR TEMA

/// Colori proposti nei campi colore dell'editor.
const _presets = [
  0xFFFFFFFF, 0xFFF7F6F2, 0xFFF4EEE4, 0xFFF6E9DD, 0xFFEEEDE6, 0xFFF2F0EA,
  0xFFE1D4C1, 0xFFC9B79F, 0xFFA7B095, 0xFF7F93A8, 0xFFB5562E, 0xFF9C3F1E,
  0xFFC8A36A, 0xFFD9B48F, 0xFF5E6B4E, 0xFF1F3A5F, 0xFF6B5A4B, 0xFF2B2119,
  0xFF23281F, 0xFF16243A, 0xFF1E2227, 0xFF15130F, 0xFF1C1C1C, 0xFF000000,
];

class ThemeEditorDialog extends StatefulWidget {
  const ThemeEditorDialog({super.key, required this.base, this.existing});

  /// Tema di partenza (copiato).
  final SiteTheme base;

  /// Tema creato in precedenza da modificare (null = nuovo).
  final SiteTheme? existing;

  @override
  State<ThemeEditorDialog> createState() => _ThemeEditorDialogState();
}

class _ThemeEditorDialogState extends State<ThemeEditorDialog> {
  late SiteTheme _t = widget.existing ??
      widget.base.copyWith(
        id: 'tema-${newId()}',
        name: '${widget.base.name} (mio)',
        custom: true,
      );
  late final _name = TextEditingController(text: _t.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Widget _color(String label, Color value, ValueChanged<Color> set) =>
      _ColorField(label: label, value: value, onChanged: (c) => setState(() => set(c)));

  @override
  Widget build(BuildContext context) {
    final s = context.read<AppState>();
    final narrow = isNarrow(context);
    final fields = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Nome del tema *'),
          onChanged: (v) => setState(() => _t = _t.copyWith(name: v)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _t.headingFont,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Carattere dei titoli'),
          items: [
            for (final f in headingFonts.keys)
              DropdownMenuItem(
                value: f,
                child: Text(f, style: _t.copyWith(headingFont: f).display(18, color: Colors.black87)),
              ),
          ],
          onChanged: (v) => setState(() => _t = _t.copyWith(headingFont: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Tema scuro'),
          value: _t.dark,
          onChanged: (v) => setState(() => _t = _t.copyWith(dark: v)),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Pulsanti a contorno'),
          subtitle: const Text('Eleganti soprattutto sui temi scuri.'),
          value: _t.outlineButtons,
          onChanged: (v) => setState(() => _t = _t.copyWith(outlineButtons: v)),
        ),
        const SizedBox(height: 8),
        _color('Fondo', _t.bg, (c) => _t = _t.copyWith(bg: c)),
        _color('Riquadri', _t.surface, (c) => _t = _t.copyWith(surface: c)),
        _color('Sezioni alternate', _t.alt, (c) => _t = _t.copyWith(alt: c)),
        _color('Testo', _t.ink, (c) => _t = _t.copyWith(ink: c)),
        _color('Testo secondario', _t.muted, (c) => _t = _t.copyWith(muted: c)),
        _color('Accento (pulsanti)', _t.accent, (c) => _t = _t.copyWith(accent: c)),
        _color('Testo sull\'accento', _t.onAccent, (c) => _t = _t.copyWith(onAccent: c)),
      ],
    );
    final preview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Anteprima', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: ThemePreview(theme: _t, height: 200),
        ),
      ],
    );
    return AlertDialog(
      title: Text(widget.existing == null ? 'Nuovo tema' : 'Modifica tema'),
      content: SizedBox(
        width: dialogWidth(context, 820),
        child: SingleChildScrollView(
          child: narrow
              ? Column(children: [preview, const SizedBox(height: 18), fields])
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: fields),
                    const SizedBox(width: 24),
                    Expanded(flex: 4, child: preview),
                  ],
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
            if (_t.name.trim().isEmpty) {
              toast(context, 'Dai un nome al tema.', error: true);
              return;
            }
            final l = LookSettings.fromJson(s.look.toJson());
            final saved = _t.copyWith(name: _t.name.trim(), custom: true);
            final i = l.custom.indexWhere((e) => e.id == saved.id);
            if (i >= 0) {
              l.custom[i] = saved;
            } else {
              l.custom.add(saved);
            }
            s.setLook(l);
            Navigator.pop(context);
            toast(context, 'Tema salvato.');
          },
          child: const Text('Salva tema'),
        ),
      ],
    );
  }
}

class _ColorField extends StatefulWidget {
  const _ColorField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  State<_ColorField> createState() => _ColorFieldState();
}

class _ColorFieldState extends State<_ColorField> {
  late final _c = TextEditingController(text: _hex(widget.value));

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  @override
  void didUpdateWidget(_ColorField old) {
    super.didUpdateWidget(old);
    final h = _hex(widget.value);
    if (old.value != widget.value && _c.text.toUpperCase() != h) _c.text = h;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final c = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(widget.label),
        content: SizedBox(
          width: dialogWidth(ctx, 330),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in _presets)
                InkWell(
                  onTap: () => Navigator.pop(ctx, p),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(p),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (c != null) {
      _c.text = _hex(Color(c));
      widget.onChanged(Color(c));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          InkWell(
            onTap: _pick,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.value,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _c,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[#0-9a-fA-F]')),
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: InputDecoration(
                labelText: widget.label,
                isDense: true,
                suffixIcon: IconButton(
                  tooltip: 'Scegli tra i colori proposti',
                  icon: const Icon(Icons.palette_outlined, size: 18),
                  onPressed: _pick,
                ),
              ),
              onChanged: (v) {
                final h = v.replaceAll('#', '');
                if (h.length == 6) {
                  final n = int.tryParse(h, radix: 16);
                  if (n != null) widget.onChanged(Color(0xFF000000 | n));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
