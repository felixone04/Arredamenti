import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import 'admin_widgets.dart';

/// Pagina di amministrazione scorrevole con margini coerenti.
class AdminPageScroll extends StatelessWidget {
  const AdminPageScroll({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 720;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        mobile ? 16 : 36,
        mobile ? 20 : 32,
        mobile ? 16 : 36,
        48,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// Editor a bozza dei contenuti del sito: le modifiche si applicano solo al
/// clic su "Salva", e si possono annullare.
class DraftEditor extends StatefulWidget {
  const DraftEditor({
    super.key,
    required this.title,
    this.subtitle,
    required this.builder,
  });
  final String title;
  final String? subtitle;
  final List<Widget> Function(
    BuildContext context,
    SiteContent draft,
    VoidCallback changed,
  )
  builder;

  @override
  State<DraftEditor> createState() => _DraftEditorState();
}

class _DraftEditorState extends State<DraftEditor> {
  late SiteContent _draft = context.read<AppState>().content.copy();
  bool _dirty = false;
  int _rev = 0;

  void _rebuild() => setState(() => _dirty = true);

  Future<void> _save() async {
    await context.read<AppState>().updateContent(_draft);
    if (!mounted) return;
    setState(() {
      _draft = context.read<AppState>().content.copy();
      _dirty = false;
    });
    toast(context, 'Modifiche salvate: il sito è aggiornato.');
  }

  void _discard() => setState(() {
    _draft = context.read<AppState>().content.copy();
    _dirty = false;
    _rev++;
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: AdminPageScroll(
            child: KeyedSubtree(
              key: ValueKey(_rev),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminHeader(title: widget.title, subtitle: widget.subtitle),
                  for (final w in widget.builder(
                    context,
                    _draft,
                    _rebuild,
                  )) ...[w, const SizedBox(height: 20)],
                ],
              ),
            ),
          ),
        ),
        SaveBar(dirty: _dirty, onSave: _save, onDiscard: _discard),
      ],
    );
  }
}

const _gap = SizedBox(height: 16);

/// Campo di testo collegato a un valore della bozza.
Widget _field(
  String label,
  String value,
  void Function(String) set,
  VoidCallback changed, {
  int maxLines = 1,
  String? helper,
}) => BoundField(
  label: label,
  value: value,
  maxLines: maxLines,
  helper: helper,
  onChanged: (v) {
    set(v);
    changed();
  },
);

/// Editor di un elenco di tappe (anno/numero, titolo, testo).
Widget _milestones(
  List<Milestone> list,
  VoidCallback changed, {
  required String item,
  required String numberLabel,
  required String addLabel,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    for (var i = 0; i < list.length; i++)
      ItemCard(
        key: ObjectKey(list[i]),
        title: '$item ${i + 1}',
        onUp: i == 0
            ? null
            : () {
                list.insert(i - 1, list.removeAt(i));
                changed();
              },
        onDown: i == list.length - 1
            ? null
            : () {
                list.insert(i + 1, list.removeAt(i));
                changed();
              },
        onDelete: () {
          list.removeAt(i);
          changed();
        },
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: _field(
                    numberLabel,
                    list[i].year,
                    (v) => list[i].year = v,
                    changed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    'Titolo',
                    list[i].title,
                    (v) => list[i].title = v,
                    changed,
                  ),
                ),
              ],
            ),
            _gap,
            _field(
              'Testo',
              list[i].text,
              (v) => list[i].text = v,
              changed,
              maxLines: 3,
            ),
          ],
        ),
      ),
    OutlinedButton.icon(
      onPressed: () {
        list.add(
          Milestone(
            year: (list.length + 1).toString().padLeft(2, '0'),
            title: '',
            text: '',
          ),
        );
        changed();
      },
      icon: const Icon(Icons.add),
      label: Text(addLabel),
    ),
  ],
);

const _titleHelper = 'Vai a capo per la seconda riga, che appare in corsivo.';

// ====================================================================== HOME

class AdminHomeEditor extends StatelessWidget {
  const AdminHomeEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return DraftEditor(
      title: 'Pagina Home',
      subtitle:
          'Le foto del carosello si gestiscono da Galleria, gli ambienti e i marchi dalle loro sezioni.',
      builder: (context, d, changed) => [
        Panel(
          title: 'Apertura',
          subtitle: 'I testi sopra il carosello a tutto schermo.',
          trailing: TextButton.icon(
            onPressed: () => context.go('/admin/galleria'),
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text('Foto del carosello'),
          ),
          child: Column(
            children: [
              _field('Etichetta', d.heroKicker, (v) => d.heroKicker = v, changed),
              _gap,
              _field(
                'Titolo',
                d.heroTitle,
                (v) => d.heroTitle = v,
                changed,
                maxLines: 3,
                helper: _titleHelper,
              ),
              _gap,
              _field(
                'Sottotitolo',
                d.heroSubtitle,
                (v) => d.heroSubtitle = v,
                changed,
                maxLines: 3,
              ),
            ],
          ),
        ),
        Panel(
          title: 'Presentazione e numeri',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('Etichetta', d.introKicker, (v) => d.introKicker = v, changed),
              _gap,
              _field(
                'Titolo',
                d.introTitle,
                (v) => d.introTitle = v,
                changed,
                maxLines: 3,
                helper: _titleHelper,
              ),
              _gap,
              _field('Testo', d.introText, (v) => d.introText = v, changed, maxLines: 5),
              const SizedBox(height: 22),
              const Text('Numeri', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              for (var i = 0; i < d.stats.length; i++)
                ItemCard(
                  key: ObjectKey(d.stats[i]),
                  onDelete: () {
                    d.stats.removeAt(i);
                    changed();
                  },
                  child: FieldRow(
                    children: [
                      SizedBox(
                        width: 150,
                        child: _field(
                          'Numero',
                          d.stats[i].title,
                          (v) => d.stats[i].title = v,
                          changed,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          'Descrizione',
                          d.stats[i].text,
                          (v) => d.stats[i].text = v,
                          changed,
                        ),
                      ),
                    ],
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () {
                  d.stats.add(Highlight(title: '', text: ''));
                  changed();
                },
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi numero'),
              ),
            ],
          ),
        ),
        Panel(
          title: 'Ambienti',
          trailing: TextButton.icon(
            onPressed: () => context.go('/admin/ambienti'),
            icon: const Icon(Icons.weekend_outlined, size: 18),
            label: const Text('Gestisci gli ambienti'),
          ),
          child: Column(
            children: [
              _field('Etichetta', d.roomsKicker, (v) => d.roomsKicker = v, changed),
              _gap,
              _field(
                'Titolo',
                d.roomsTitle,
                (v) => d.roomsTitle = v,
                changed,
                maxLines: 3,
                helper: _titleHelper,
              ),
              _gap,
              _field('Introduzione', d.roomsIntro, (v) => d.roomsIntro = v, changed, maxLines: 3),
            ],
          ),
        ),
        Panel(
          title: 'Carosello dello showroom',
          child: FieldRow(
            children: [
              Expanded(
                child: _field(
                  'Etichetta',
                  d.showcaseKicker,
                  (v) => d.showcaseKicker = v,
                  changed,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _field(
                  'Titolo',
                  d.showcaseTitle,
                  (v) => d.showcaseTitle = v,
                  changed,
                ),
              ),
            ],
          ),
        ),
        Panel(
          title: 'Marchi',
          trailing: TextButton.icon(
            onPressed: () => context.go('/admin/marchi'),
            icon: const Icon(Icons.workspace_premium_outlined, size: 18),
            label: const Text('Gestisci i marchi'),
          ),
          child: Column(
            children: [
              _field('Etichetta', d.brandsKicker, (v) => d.brandsKicker = v, changed),
              _gap,
              _field(
                'Titolo',
                d.brandsTitle,
                (v) => d.brandsTitle = v,
                changed,
                maxLines: 3,
                helper: _titleHelper,
              ),
              _gap,
              _field('Introduzione', d.brandsIntro, (v) => d.brandsIntro = v, changed, maxLines: 3),
            ],
          ),
        ),
        Panel(
          title: 'Il metodo',
          subtitle: 'I passaggi del lavoro: compaiono in home e nella biografia.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('Titolo', d.processTitle, (v) => d.processTitle = v, changed),
              _gap,
              _milestones(
                d.process,
                changed,
                item: 'Passaggio',
                numberLabel: 'Numero',
                addLabel: 'Aggiungi passaggio',
              ),
            ],
          ),
        ),
        Panel(
          title: 'Recensioni',
          trailing: TextButton.icon(
            onPressed: () => context.go('/admin/recensioni'),
            icon: const Icon(Icons.reviews_outlined, size: 18),
            label: const Text('Gestisci le recensioni'),
          ),
          child: Column(
            children: [
              _field('Etichetta', d.reviewsKicker, (v) => d.reviewsKicker = v, changed),
              _gap,
              _field(
                'Titolo',
                d.reviewsTitle,
                (v) => d.reviewsTitle = v,
                changed,
                maxLines: 3,
                helper: _titleHelper,
              ),
            ],
          ),
        ),
        Panel(
          title: 'Invito al preventivo',
          subtitle: 'La fascia con la foto in fondo alle pagine.',
          child: Column(
            children: [
              _field('Titolo', d.bannerTitle, (v) => d.bannerTitle = v, changed),
              _gap,
              _field('Testo', d.bannerText, (v) => d.bannerText = v, changed, maxLines: 3),
              _gap,
              _field('Pulsante', d.bannerButton, (v) => d.bannerButton = v, changed),
              _gap,
              ImageField(
                label: 'Foto di sfondo',
                aspect: 16 / 9,
                value: d.bannerImage,
                onChanged: (v) {
                  d.bannerImage = v;
                  changed();
                },
              ),
            ],
          ),
        ),
        Panel(
          title: 'Pagina preventivo',
          child: Column(
            children: [
              _field('Titolo', d.quoteTitle, (v) => d.quoteTitle = v, changed),
              _gap,
              _field('Introduzione', d.quoteIntro, (v) => d.quoteIntro = v, changed, maxLines: 3),
              _gap,
              ImageField(
                label: 'Foto accanto al titolo',
                aspect: 4 / 3,
                value: d.quoteImage,
                onChanged: (v) {
                  d.quoteImage = v;
                  changed();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================= BIOGRAFIA

class AdminBioEditor extends StatelessWidget {
  const AdminBioEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return DraftEditor(
      title: 'Biografia',
      subtitle: 'La storia del negozio, le tappe e le persone.',
      builder: (context, d, changed) => [
        Panel(
          title: 'La storia',
          child: Column(
            children: [
              _field(
                'Titolo della pagina',
                d.bioTitle,
                (v) => d.bioTitle = v,
                changed,
                helper: _titleHelper,
                maxLines: 2,
              ),
              _gap,
              _field(
                'Introduzione (frase in evidenza)',
                d.bioIntro,
                (v) => d.bioIntro = v,
                changed,
                maxLines: 3,
              ),
              _gap,
              BoundField(
                label: 'Racconto',
                value: d.bioStory,
                maxLines: 14,
                minLines: 8,
                helper: 'Separa i paragrafi con una riga vuota.',
                onChanged: (v) {
                  d.bioStory = v;
                  changed();
                },
              ),
              _gap,
              ImageField(
                label: 'Foto accanto al racconto',
                aspect: 4 / 5,
                value: d.bioImage,
                onChanged: (v) {
                  d.bioImage = v;
                  changed();
                },
              ),
              _gap,
              ImageField(
                label: 'Foto panoramica (a tutta larghezza)',
                aspect: 16 / 7,
                value: d.bioImage2,
                onChanged: (v) {
                  d.bioImage2 = v;
                  changed();
                },
              ),
            ],
          ),
        ),
        Panel(
          title: 'Le tappe',
          subtitle: 'Gli anni importanti del negozio.',
          child: _milestones(
            d.timeline,
            changed,
            item: 'Tappa',
            numberLabel: 'Anno',
            addLabel: 'Aggiungi tappa',
          ),
        ),
        Panel(
          title: 'Le persone',
          subtitle: 'Senza foto si mostrano le iniziali.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field('Titolo', d.teamTitle, (v) => d.teamTitle = v, changed),
              _gap,
              for (var i = 0; i < d.team.length; i++)
                ItemCard(
                  key: ValueKey(d.team[i].id),
                  title: d.team[i].name.isEmpty ? 'Persona ${i + 1}' : d.team[i].name,
                  onUp: i == 0
                      ? null
                      : () {
                          d.team.insert(i - 1, d.team.removeAt(i));
                          changed();
                        },
                  onDown: i == d.team.length - 1
                      ? null
                      : () {
                          d.team.insert(i + 1, d.team.removeAt(i));
                          changed();
                        },
                  onDelete: () {
                    d.team.removeAt(i);
                    changed();
                  },
                  child: Column(
                    children: [
                      FieldRow(
                        children: [
                          Expanded(
                            child: _field(
                              'Nome',
                              d.team[i].name,
                              (v) => d.team[i].name = v,
                              changed,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _field(
                              'Ruolo',
                              d.team[i].role,
                              (v) => d.team[i].role = v,
                              changed,
                            ),
                          ),
                        ],
                      ),
                      _gap,
                      _field(
                        'Breve presentazione',
                        d.team[i].bio,
                        (v) => d.team[i].bio = v,
                        changed,
                        maxLines: 2,
                      ),
                      _gap,
                      ImageField(
                        label: 'Foto (facoltativa)',
                        aspect: 4 / 5,
                        value: d.team[i].photo,
                        onChanged: (v) {
                          d.team[i].photo = v;
                          changed();
                        },
                      ),
                    ],
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () {
                  d.team.add(TeamMember(name: '', role: ''));
                  changed();
                },
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi persona'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ======================================================= IDENTITÀ E CONTATTI

class AdminIdentityEditor extends StatelessWidget {
  const AdminIdentityEditor({super.key});

  @override
  Widget build(BuildContext context) {
    Widget list(
      String title,
      String subtitle,
      List<String> items,
      String add,
      void Function(List<String>) set,
      VoidCallback changed,
    ) => Panel(
      title: title,
      subtitle: subtitle,
      child: StringListEditor(
        items: items,
        addLabel: add,
        onChanged: (v) {
          set(v);
          changed();
        },
      ),
    );

    return DraftEditor(
      title: 'Identità e contatti',
      subtitle: 'Nome, recapiti e opzioni del modulo preventivo. I colori si scelgono in “Stile e temi”.',
      builder: (context, d, changed) => [
        Panel(
          title: 'Identità',
          child: Column(
            children: [
              _field(
                'Nome del negozio',
                d.shopName,
                (v) => d.shopName = v,
                changed,
                helper: 'Diventa il logo in alto a sinistra.',
              ),
              _gap,
              _field('Slogan', d.tagline, (v) => d.tagline = v, changed),
              _gap,
              _field('Frase nel footer', d.footerNote, (v) => d.footerNote = v, changed, maxLines: 2),
            ],
          ),
        ),
        Panel(
          title: 'Contatti',
          subtitle: 'Compaiono nel footer e nel preventivo. I campi vuoti non vengono mostrati; '
              'con il WhatsApp compilato compare il pulsante verde sul sito.',
          child: Column(
            children: [
              FieldRow(
                children: [
                  Expanded(
                    child: BoundField(
                      label: 'Telefono',
                      value: d.contacts.phone,
                      prefixIcon: Icons.phone_outlined,
                      onChanged: (v) {
                        d.contacts.phone = v;
                        changed();
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: BoundField(
                      label: 'WhatsApp',
                      value: d.contacts.whatsapp,
                      prefixIcon: Icons.chat_bubble_outline_rounded,
                      onChanged: (v) {
                        d.contacts.whatsapp = v;
                        changed();
                      },
                    ),
                  ),
                ],
              ),
              _gap,
              BoundField(
                label: 'Email',
                value: d.contacts.email,
                prefixIcon: Icons.mail_outline_rounded,
                onChanged: (v) {
                  d.contacts.email = v;
                  changed();
                },
              ),
              _gap,
              BoundField(
                label: 'Indirizzo dello showroom',
                value: d.contacts.address,
                prefixIcon: Icons.place_outlined,
                onChanged: (v) {
                  d.contacts.address = v;
                  changed();
                },
              ),
              _gap,
              BoundField(
                label: 'Orari di apertura',
                value: d.contacts.hours,
                prefixIcon: Icons.schedule_rounded,
                onChanged: (v) {
                  d.contacts.hours = v;
                  changed();
                },
              ),
              _gap,
              FieldRow(
                children: [
                  Expanded(
                    child: BoundField(
                      label: 'Instagram (link)',
                      value: d.contacts.instagram,
                      onChanged: (v) {
                        d.contacts.instagram = v;
                        changed();
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: BoundField(
                      label: 'Facebook (link)',
                      value: d.contacts.facebook,
                      onChanged: (v) {
                        d.contacts.facebook = v;
                        changed();
                      },
                    ),
                  ),
                ],
              ),
              _gap,
              FieldRow(
                children: [
                  Expanded(
                    child: BoundField(
                      label: 'Pinterest (link)',
                      value: d.contacts.pinterest,
                      onChanged: (v) {
                        d.contacts.pinterest = v;
                        changed();
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: BoundField(
                      label: 'Partita IVA / dati legali',
                      value: d.contacts.vat,
                      onChanged: (v) {
                        d.contacts.vat = v;
                        changed();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        list(
          'Ambienti nel preventivo',
          'Le voci tra cui il cliente sceglie cosa arredare.',
          d.roomTypes,
          'Nuovo ambiente',
          (v) => d.roomTypes = v,
          changed,
        ),
        list(
          'Stili nel preventivo',
          'Lascia vuoto per non chiedere lo stile.',
          d.styles,
          'Nuovo stile',
          (v) => d.styles = v,
          changed,
        ),
        list(
          'Fasce di budget',
          'Le voci del menu “Budget indicativo”.',
          d.budgets,
          'Nuova fascia',
          (v) => d.budgets = v,
          changed,
        ),
        list(
          'Tempi',
          'Le voci del menu “Quando vorresti iniziare”.',
          d.timings,
          'Nuova voce',
          (v) => d.timings = v,
          changed,
        ),
      ],
    );
  }
}
