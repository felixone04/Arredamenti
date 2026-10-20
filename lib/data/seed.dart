import '../models/models.dart';

/// Foto di esempio (Unsplash), da sostituire dal gestionale.
const _photos = [
  '1586023492125-27b2c045efd7', // 0 poltrona gialla
  '1555041469-a586c61ea9bc', // 1 divano in velluto verde
  '1493663284031-b7e3aefcae8e', // 2 divano capitonné
  '1567016432779-094069958ea5', // 3 divano arancio
  '1556228453-efd6c1ff04f6', // 4 soggiorno bohémien
  '1556911220-bff31c812dba', // 5 cucina bianca
  '1565538810643-b5bdb714032a', // 6 cucina, lavello
  '1505693416388-ac5ce068fe85', // 7 camera classica
  '1522771739844-6a9f6d5f14af', // 8 camera, comodino
  '1560448204-e02f11c3d0e2', // 9 open space luminoso
  '1600210492486-724fe5c67fb0', // 10 soggiorno con quadri
  '1600585154340-be6161a56a0c', // 11 villa al tramonto
  '1600566753190-17f0baa2a6c3', // 12 casa in legno
  '1600607687939-ce8a6c25118c', // 13 soggiorno con legno
  '1600607687644-c7171b42498f', // 14 camera con vetrate
  '1584622650111-993a426fbf0a', // 15 bagno con doccia
  '1552321554-5fefe8c9ef14', // 16 bagno bianco
  '1620626011761-996317b8d101', // 17 bagno con vasca
  '1617806118233-18e1de247200', // 18 sala da pranzo verde
  '1618221195710-dd6b41faaea6', // 19 soggiorno chiaro
  '1618219908412-a29a1bb7b86e', // 20 ingresso con specchio
  '1616486338812-3dadae4b4ace', // 21 soggiorno beige
  '1615874959474-d609969a20ed', // 22 camera con lampade
  '1600121848594-d8644e57abab', // 23 soggiorno grigio
  '1595526114035-0d45ed16cfbf', // 24 camera bianca
  '1524758631624-e2822e304c36', // 25 studio con lampada
  '1497366216548-37526070297c', // 26 ufficio
  '1600494603989-9650cf6ddd3d', // 27 studio verde
  '1600047509807-ba8f99d2cdde', // 28 villa moderna
  '1631679706909-1844bbd07221', // 29 soggiorno con specchi
  '1538688525198-9b88f6f53126', // 30 loft in mattoni
  '1503602642458-232111445657', // 31 sgabello
  '1592078615290-033ee584e267', // 32 sedia
  '1513694203232-719a280e022f', // 33 madia
  '1507089947368-19c1da9775ae', // 34 cucina con isola
  '1484101403633-562f891dc89a', // 35 divano azzurro
  '1556020685-ae41abfc9365', // 36 consolle
  '1540518614846-7eded433c457', // 37 camera arancio
  '1600573472550-8090b5e0745e', // 38 terrazza con piscina
  '1616594039964-ae9021a400a0', // 39 camera elegante
  '1616137466211-f939a420be84', // 40 soggiorno bianco
  '1600585154526-990dced4db0d', // 41 facciata scura
  '1604014237800-1c9102c219da', // 42 open space con pranzo
  '1598928506311-c55ded91a20c', // 43 soggiorno classico
  '1615529182904-14819c35db37', // 44 soggiorno con cesti
  '1617098900591-3f90928e8c54', // 45 camera con quadri
  '1611486212557-88be5ff6f941', // 46 comodino in legno
  '1600489000022-c2086d79f9d4', // 47 cucina con mensole
  '1556909114-f6e7ad7d3136', // 48 cucina vissuta
  '1600566752355-35792bedcfea', // 49 bagno scuro
  '1617103996702-96ff29b1c467', // 50 soggiorno con tappeto
  '1594026112284-02bb6f3352fe', // 51 mensole
  '1560185007-cde436f6a4d0', // 52 pranzo con bovindo
  '1583847268964-b28dc8f51f92', // 53 divano grigio
  '1600210491892-03d54c0aaf87', // 54 soggiorno ad archi
  '1571508601891-ca5e7a713859', // 55 camera calda
  '1600607688969-a5bfcd646154', // 56 casa nel verde
  '1602872030219-ad2b9a54315c', // 57 pranzo e scala
  '1588854337236-6889d631faa8', // 58 cucina blu
  '1564078516393-cf04bd966897', // 59 soggiorno scuro
];

String _u(int i) =>
    'https://images.unsplash.com/photo-${_photos[i]}?auto=format&fit=crop&q=80&w=1600';

class Seed {
  static SiteContent content() => SiteContent(
    shopName: 'Arredamenti',
    tagline: 'Casa e design dal 1978',
    heroKicker: 'Showroom di arredamento',
    heroTitle: 'La casa che\nti somiglia',
    heroSubtitle:
        'Progettiamo e arrediamo ogni ambiente con i migliori marchi del design italiano: dal primo schizzo al montaggio.',
    introKicker: 'Chi siamo',
    introTitle: 'Arrediamo case da tre generazioni,\ncon la cura di una bottega',
    introText:
        'Ascoltiamo come vivi, misuriamo gli spazi e scegliamo con te materiali, colori e marchi. '
        'Ogni progetto nasce in showroom e prende forma a casa tua, seguito sempre dalle stesse persone.',
    stats: [
      Highlight(title: '45', text: 'anni di esperienza'),
      Highlight(title: '3.200+', text: 'case arredate'),
      Highlight(title: '20', text: 'marchi selezionati'),
      Highlight(title: '1.500 m²', text: 'di showroom'),
    ],
    roomsKicker: 'Gli ambienti',
    roomsTitle: 'Ogni stanza,\nuna storia diversa',
    roomsIntro:
        'Dal soggiorno alla camera, dalla cucina agli esterni: idee e progetti realizzati per chi vive la casa ogni giorno.',
    showcaseKicker: 'Dallo showroom',
    showcaseTitle: 'Dettagli che fanno casa',
    brandsKicker: 'I nostri marchi',
    brandsTitle: 'Il meglio del design,\nscelto per te',
    brandsIntro:
        'Siamo rivenditori autorizzati dei marchi che amiamo: li conosciamo da vicino e ti aiutiamo a scegliere quello giusto.',
    processTitle: 'Come lavoriamo',
    process: [
      Milestone(
        year: '01',
        title: 'Ascolto',
        text: 'Ci racconti come vivi la casa, in showroom o da te. Raccogliamo idee, misure e desideri.',
      ),
      Milestone(
        year: '02',
        title: 'Sopralluogo',
        text: 'Rileviamo gli spazi con precisione: impianti, luce naturale, vincoli e possibilità.',
      ),
      Milestone(
        year: '03',
        title: 'Progetto 3D',
        text: 'Ti mostriamo la casa finita in 3D, con materiali e colori veri, prima di ordinare un solo mobile.',
      ),
      Milestone(
        year: '04',
        title: 'Consegna e montaggio',
        text: 'I nostri montatori consegnano e installano tutto, e ritirano gli imballi. Tu entri e vivi.',
      ),
    ],
    reviewsKicker: 'Dicono di noi',
    reviewsTitle: 'Case vere,\npersone contente',
    bannerTitle: 'Iniziamo dal tuo spazio',
    bannerText:
        'Raccontaci il progetto: ti richiamiamo per fissare un incontro in showroom o un sopralluogo. Il preventivo è gratuito.',
    bannerButton: 'Richiedi un preventivo',
    bannerImage: _u(40),
    quoteTitle: 'Il tuo preventivo',
    quoteIntro:
        'Bastano due minuti. Ti ricontattiamo entro due giorni lavorativi per parlarne insieme.',
    quoteImage: _u(13),
    bioTitle: 'La nostra storia',
    bioIntro:
        'Una piccola bottega di falegnameria diventata, anno dopo anno, uno showroom dove il design incontra il mestiere.',
    bioStory:
        'Tutto comincia nel 1978, quando il fondatore apre un laboratorio di falegnameria in centro. Si costruiscono cucine e armadi su misura, uno alla volta, per le famiglie del quartiere.\n\n'
        'Negli anni la bottega cresce: arrivano i primi marchi del design italiano, poi lo showroom, poi un ufficio tecnico che progetta case intere. Il metodo però è rimasto lo stesso: ascoltare, misurare, proporre poche soluzioni giuste.\n\n'
        'Oggi siamo una squadra di architetti, arredatori e montatori. Seguiamo ogni cliente dal primo caffè in showroom fino all\'ultima mensola montata, e torniamo volentieri anche dopo.',
    bioImage: _u(30),
    bioImage2: _u(10),
    timeline: [
      Milestone(
        year: '1978',
        title: 'La bottega',
        text: 'Apre il laboratorio di falegnameria: cucine e armadi su misura.',
      ),
      Milestone(
        year: '1995',
        title: 'Il primo showroom',
        text: 'Arrivano i grandi marchi del design italiano.',
      ),
      Milestone(
        year: '2010',
        title: 'L\'ufficio tecnico',
        text: 'Progetti in 3D e ristrutturazioni chiavi in mano.',
      ),
      Milestone(
        year: '2024',
        title: 'Il nuovo spazio',
        text: '1.500 m² di ambienti allestiti da vivere e toccare con mano.',
      ),
    ],
    teamTitle: 'Le persone',
    team: [
      TeamMember(
        name: 'Giulia',
        role: 'Architetto d\'interni',
        bio: 'Segue i progetti dalla prima idea al rendering.',
      ),
      TeamMember(
        name: 'Marco',
        role: 'Responsabile showroom',
        bio: 'Conosce ogni tessuto, essenza e finitura.',
      ),
      TeamMember(
        name: 'Luca',
        role: 'Capo montatore',
        bio: 'Da vent\'anni porta i progetti dentro le case.',
      ),
    ],
    contacts: Contacts(
      phone: '+39 000 000 0000',
      whatsapp: '+39 000 000 0000',
      email: 'info@arredamenti.example',
      address: 'Via del Design 18, Città',
      hours: 'Lun–Sab 9:30–13:00 · 15:30–19:30',
      instagram: 'https://instagram.com/',
      facebook: 'https://facebook.com/',
    ),
    footerNote: 'Showroom di arredamento, progettazione d\'interni e montaggio.',
    roomTypes: [
      'Casa intera',
      'Soggiorno',
      'Cucina',
      'Sala da pranzo',
      'Camera da letto',
      'Cameretta',
      'Bagno',
      'Studio',
      'Esterni',
      'Ufficio / negozio',
    ],
    styles: [
      'Moderno',
      'Classico',
      'Contemporaneo',
      'Scandinavo',
      'Industriale',
      'Rustico',
      'Non so ancora',
    ],
    budgets: [
      'Fino a 5.000 €',
      '5.000 – 15.000 €',
      '15.000 – 30.000 €',
      '30.000 – 60.000 €',
      'Oltre 60.000 €',
      'Da definire',
    ],
    timings: [
      'Il prima possibile',
      'Entro 3 mesi',
      'Entro 6 mesi',
      'Entro un anno',
      'Sto solo guardando',
    ],
  );

  static List<Brand> brands() => [
    Brand(
      id: 'b-poliform',
      name: 'Poliform',
      category: 'Sistemi e armadi',
      description: 'Librerie, armadi e sistemi giorno dal disegno essenziale.',
    ),
    Brand(
      id: 'b-molteni',
      name: 'Molteni&C',
      category: 'Zona giorno',
      description: 'Arredi iconici e su misura per il soggiorno e la notte.',
    ),
    Brand(
      id: 'b-cassina',
      name: 'Cassina',
      category: 'Imbottiti',
      description: 'Divani e poltrone che hanno fatto la storia del design.',
    ),
    Brand(
      id: 'b-bebitalia',
      name: 'B&B Italia',
      category: 'Imbottiti',
      description: 'Sedute contemporanee, comode e senza tempo.',
    ),
    Brand(
      id: 'b-minotti',
      name: 'Minotti',
      category: 'Imbottiti',
      description: 'Divani e complementi dall\'eleganza sobria.',
    ),
    Brand(
      id: 'b-scavolini',
      name: 'Scavolini',
      category: 'Cucine',
      description: 'Cucine e bagni per ogni stile e ogni budget.',
    ),
    Brand(
      id: 'b-lago',
      name: 'Lago',
      category: 'Zona giorno',
      description: 'Arredi leggeri e componibili, pensati per vivere gli spazi.',
    ),
    Brand(
      id: 'b-calligaris',
      name: 'Calligaris',
      category: 'Tavoli e sedie',
      description: 'Tavoli, sedie e complementi per la zona pranzo.',
    ),
    Brand(
      id: 'b-kartell',
      name: 'Kartell',
      category: 'Complementi',
      description: 'Complementi e lampade dal carattere inconfondibile.',
    ),
    Brand(
      id: 'b-flos',
      name: 'Flos',
      category: 'Illuminazione',
      description: 'Lampade che sono oggetti da collezione.',
    ),
    Brand(
      id: 'b-artemide',
      name: 'Artemide',
      category: 'Illuminazione',
      description: 'Luce di progetto per la casa e l\'ufficio.',
    ),
    Brand(
      id: 'b-porro',
      name: 'Porro',
      category: 'Sistemi e armadi',
      description: 'Sistemi e tavoli dalle proporzioni perfette.',
    ),
  ];

  static List<Room> rooms() => [
    Room(
      id: 'r-soggiorno',
      title: 'Soggiorno',
      kicker: 'Zona giorno',
      description:
          'Divani avvolgenti, librerie su misura e luce calda: il soggiorno è la stanza dove si sta insieme. Lo progettiamo intorno alle tue abitudini.',
      story:
          'Partiamo sempre da una domanda: come vivi il soggiorno? Chi legge ha bisogno di una poltrona e di una buona luce, chi riceve spesso di sedute in più, chi guarda film di un divano profondo.\n\n'
          'Proponiamo composizioni su misura, tessuti da toccare in showroom e un progetto dell\'illuminazione pensato per ogni momento della giornata.',
      cover: _u(43),
      photos: [
        RoomPhoto(url: _u(19), caption: 'Toni chiari e legno naturale per un living luminoso.'),
        RoomPhoto(url: _u(4), caption: 'Tessuti, piante e colori caldi: un soggiorno da vivere.'),
        RoomPhoto(url: _u(21), caption: 'Il divano angolare disegna lo spazio della conversazione.'),
        RoomPhoto(url: _u(29), caption: 'Specchi e fibre naturali per un\'atmosfera morbida.'),
        RoomPhoto(url: _u(59), caption: 'Doppia altezza e pareti scure: il soggiorno diventa scenografia.'),
        RoomPhoto(url: _u(53), caption: 'Linee semplici e tavolini in legno massello.'),
      ],
      features: ['Divani su misura', 'Librerie', 'Progetto luci'],
      brandIds: ['b-molteni', 'b-cassina', 'b-minotti', 'b-flos'],
    ),
    Room(
      id: 'r-cucina',
      title: 'Cucina',
      kicker: 'Il cuore della casa',
      description:
          'Isole, penisole e colonne attrezzate: disegniamo cucine belle da vedere e comode da usare, con elettrodomestici e piani scelti insieme.',
      story:
          'Una cucina dura vent\'anni: per questo la progettiamo al centimetro, partendo da come cucini. Misuriamo impianti e aperture, scegliamo con te ante, piani e maniglie.\n\n'
          'Ti accompagniamo nella scelta degli elettrodomestici e coordiniamo idraulico ed elettricista, così il giorno del montaggio è tutto pronto.',
      cover: _u(34),
      photos: [
        RoomPhoto(url: _u(5), caption: 'Ante laccate bianche e piano in quarzo.'),
        RoomPhoto(url: _u(58), caption: 'Blu profondo e marmo: una cucina dal carattere deciso.'),
        RoomPhoto(url: _u(47), caption: 'Mensole a vista e pensili scuri, tra tradizione e modernità.'),
        RoomPhoto(url: _u(6), caption: 'Rubinetteria in ottone spazzolato.'),
      ],
      features: ['Su misura', 'Elettrodomestici', 'Piani in quarzo e marmo'],
      brandIds: ['b-scavolini', 'b-poliform'],
    ),
    Room(
      id: 'r-pranzo',
      title: 'Sala da pranzo',
      kicker: 'Convivio',
      description:
          'Il tavolo giusto cambia le serate. Tavoli allungabili, sedie comode per le cene lunghe e lampade a sospensione che raccolgono la luce.',
      story:
          'La zona pranzo è il luogo delle feste e delle domeniche. Scegliamo tavoli che si allungano quando servono, sedie da provare in showroom e una luce che non abbaglia.',
      cover: _u(18),
      photos: [
        RoomPhoto(url: _u(52), caption: 'Il bovindo illumina la tavola tutto il giorno.'),
        RoomPhoto(url: _u(57), caption: 'Sedie imbottite e tavolo in rovere.'),
        RoomPhoto(url: _u(42), caption: 'Open space: cucina, pranzo e living in un unico respiro.'),
      ],
      features: ['Tavoli allungabili', 'Sedie', 'Sospensioni'],
      brandIds: ['b-calligaris', 'b-porro', 'b-artemide'],
    ),
    Room(
      id: 'r-notte',
      title: 'Camera da letto',
      kicker: 'Zona notte',
      description:
          'Letti imbottiti, cabine armadio e tessuti morbidi: una camera pensata per riposare davvero, con tutto in ordine e al suo posto.',
      story:
          'Nella camera contano i dettagli: la testata giusta, i comodini all\'altezza del letto, un armadio che contiene tutto senza ingombrare.\n\n'
          'Progettiamo cabine armadio su misura e scegliamo con te materassi, biancheria e luci per la lettura.',
      cover: _u(39),
      photos: [
        RoomPhoto(url: _u(7), caption: 'Testata capitonné e panca ai piedi del letto.'),
        RoomPhoto(url: _u(14), caption: 'Vetrate e luce naturale: la camera si apre sul giardino.'),
        RoomPhoto(url: _u(37), caption: 'Un tocco di colore con le sedute in velluto.'),
        RoomPhoto(url: _u(45), caption: 'Toni neutri e lampade da comodino in ceramica.'),
        RoomPhoto(url: _u(55), caption: 'Cuscini, plaid e legno: calore per le sere d\'inverno.'),
      ],
      features: ['Letti imbottiti', 'Cabine armadio', 'Tessili'],
      brandIds: ['b-poliform', 'b-molteni', 'b-lago'],
    ),
    Room(
      id: 'r-bagno',
      title: 'Bagno',
      kicker: 'Benessere',
      description:
          'Vasche freestanding, docce a filo pavimento e mobili sospesi: trasformiamo il bagno in una piccola spa di casa.',
      story:
          'Anche il bagno più piccolo può diventare comodo ed elegante. Progettiamo mobili sospesi, contenitori su misura e scegliamo con te rivestimenti e rubinetterie.',
      cover: _u(17),
      photos: [
        RoomPhoto(url: _u(15), caption: 'Doccia a filo pavimento con cristallo trasparente.'),
        RoomPhoto(url: _u(16), caption: 'Bianco e verde: freschezza e luce.'),
        RoomPhoto(url: _u(49), caption: 'Grès scuro e vasca freestanding.'),
      ],
      features: ['Mobili sospesi', 'Docce walk-in', 'Rivestimenti'],
      brandIds: ['b-scavolini'],
    ),
    Room(
      id: 'r-studio',
      title: 'Studio',
      kicker: 'Lavoro e lettura',
      description:
          'Scrivanie, librerie e sedute ergonomiche per lavorare da casa con stile, oppure per arredare uffici e spazi professionali.',
      story:
          'Lo studio deve essere bello e funzionale: luce giusta, cavi nascosti, contenitori a portata di mano. Arrediamo anche uffici, studi professionali e negozi.',
      cover: _u(27),
      photos: [
        RoomPhoto(url: _u(25), caption: 'Sedute colorate e grandi vetrate.'),
        RoomPhoto(url: _u(30), caption: 'Un loft in mattoni diventa spazio di lavoro condiviso.'),
        RoomPhoto(url: _u(26), caption: 'Uffici contemporanei: ordine e materiali resistenti.'),
      ],
      features: ['Home office', 'Uffici', 'Librerie'],
      brandIds: ['b-lago', 'b-kartell', 'b-artemide'],
    ),
    Room(
      id: 'r-esterni',
      title: 'Esterni',
      kicker: 'Outdoor',
      description:
          'Terrazze, giardini e bordi piscina: arredi da esterno che resistono al sole e alla pioggia e allungano la stagione.',
      story:
          'Portiamo la qualità dell\'interno anche all\'aperto: divani con tessuti tecnici, tavoli in teak e alluminio, ombrelloni e luci da giardino.',
      cover: _u(38),
      photos: [
        RoomPhoto(url: _u(56), caption: 'Il giardino diventa un\'altra stanza della casa.'),
        RoomPhoto(url: _u(11), caption: 'Grandi aperture e luce del tramonto.'),
        RoomPhoto(url: _u(28), caption: 'Architettura contemporanea e verde curato.'),
      ],
      features: ['Tessuti tecnici', 'Teak e alluminio', 'Luci da giardino'],
      brandIds: ['b-kartell', 'b-flos'],
    ),
  ];

  static List<GalleryPhoto> gallery() => [
    GalleryPhoto(id: 'g1', url: _u(19), title: 'Living luminoso', caption: 'Toni chiari e legno naturale.', category: 'Soggiorno', inHero: true),
    GalleryPhoto(id: 'g2', url: _u(18), title: 'La tavola verde', caption: 'Sedie in velluto e lampade a sospensione.', category: 'Sala da pranzo', inHero: true),
    GalleryPhoto(id: 'g3', url: _u(54), title: 'Archi e luce', caption: 'Un soggiorno classico rivisto in chiave moderna.', category: 'Soggiorno', inHero: true),
    GalleryPhoto(id: 'g4', url: _u(39), title: 'Notte elegante', caption: 'Testata imbottita e tessuti preziosi.', category: 'Camera da letto', inHero: true),
    GalleryPhoto(id: 'g5', url: _u(59), title: 'Doppia altezza', caption: 'Pareti scure e divano avvolgente.', category: 'Soggiorno', inHero: true),
    GalleryPhoto(id: 'g6', url: _u(42), title: 'Open space', caption: 'Cucina, pranzo e living insieme.', category: 'Zona giorno', inHero: true),
    GalleryPhoto(id: 'g7', url: _u(0), title: 'Poltrona gialla', caption: 'Un colore che accende la stanza.', category: 'Complementi'),
    GalleryPhoto(id: 'g8', url: _u(3), title: 'Divano arancio', caption: 'Tessuto bouclé e piedini in legno.', category: 'Imbottiti'),
    GalleryPhoto(id: 'g9', url: _u(1), title: 'Velluto verde', caption: 'Il divano protagonista del soggiorno.', category: 'Imbottiti'),
    GalleryPhoto(id: 'g10', url: _u(46), title: 'Comodino in noce', caption: 'Piccoli arredi, grande carattere.', category: 'Complementi'),
    GalleryPhoto(id: 'g11', url: _u(36), title: 'Consolle e specchio', caption: 'L\'ingresso che accoglie.', category: 'Ingresso'),
    GalleryPhoto(id: 'g12', url: _u(51), title: 'Mensole sospese', caption: 'Legno chiaro e oggetti da collezione.', category: 'Complementi'),
    GalleryPhoto(id: 'g13', url: _u(20), title: 'Specchio tondo', caption: 'Madia in rattan e luce calda.', category: 'Ingresso'),
    GalleryPhoto(id: 'g14', url: _u(44), title: 'Fibre naturali', caption: 'Cesti, lino e lampade intrecciate.', category: 'Soggiorno'),
    GalleryPhoto(id: 'g15', url: _u(50), title: 'Tappeti d\'autore', caption: 'Il tappeto disegna lo spazio.', category: 'Tessili'),
    GalleryPhoto(id: 'g16', url: _u(32), title: 'Sedia iconica', caption: 'Design senza tempo.', category: 'Sedute'),
  ];

  static List<Review> reviews() => [
    Review(
      id: 'rv1',
      name: 'Laura e Paolo',
      project: 'Cucina e soggiorno',
      text: 'Ci hanno seguito dal primo disegno fino all\'ultima mensola. Il progetto 3D era identico alla casa finita.',
      createdAt: DateTime(2026, 5, 12),
    ),
    Review(
      id: 'rv2',
      name: 'Francesca R.',
      project: 'Camera da letto',
      text: 'Gentilissimi e precisi. La cabina armadio su misura ha risolto tutti i problemi di spazio.',
      createdAt: DateTime(2026, 3, 4),
    ),
    Review(
      id: 'rv3',
      name: 'Studio legale Bianchi',
      project: 'Ufficio',
      text: 'Arredo completo dello studio in tre settimane, montaggio impeccabile e nessun disagio per il lavoro.',
      rating: 5,
      createdAt: DateTime(2026, 1, 20),
    ),
    Review(
      id: 'rv4',
      name: 'Marco e Elena',
      project: 'Casa intera',
      text: 'Avevamo idee confuse: ci hanno aiutato a scegliere stile, colori e marchi. Oggi la casa ci somiglia davvero.',
      createdAt: DateTime(2025, 11, 8),
    ),
    Review(
      id: 'rv5',
      name: 'Giovanni T.',
      project: 'Esterni',
      text: 'Terrazza trasformata: arredi resistenti e bellissimi. Consigliati.',
      rating: 4,
      createdAt: DateTime(2025, 9, 15),
    ),
  ];

  static List<ServiceItem> services() => [
    ServiceItem(id: 's-sopralluogo', name: 'Sopralluogo e misure', category: 'Progettazione', description: 'Rilievo degli spazi a casa tua.', internalPrice: 80),
    ServiceItem(id: 's-3d', name: 'Progetto e rendering 3D', category: 'Progettazione', description: 'Vedi la casa finita prima di ordinare.', internalPrice: 300),
    ServiceItem(id: 's-materiali', name: 'Consulenza colori e materiali', category: 'Progettazione', description: 'Scelta di finiture, tessuti e palette.'),
    ServiceItem(id: 's-cucina', name: 'Cucina su misura', category: 'Arredi', description: 'Progetto, elettrodomestici e montaggio.'),
    ServiceItem(id: 's-armadi', name: 'Armadi e cabine armadio', category: 'Arredi', description: 'Su misura, anche sottotetto e nicchie.'),
    ServiceItem(id: 's-imbottiti', name: 'Divani e imbottiti', category: 'Arredi', description: 'Composizioni e tessuti a scelta.'),
    ServiceItem(id: 's-luci', name: 'Illuminazione', category: 'Arredi', description: 'Progetto luci e lampade di design.'),
    ServiceItem(id: 's-tende', name: 'Tende e tessili', category: 'Arredi', description: 'Tende, tappeti e biancheria.'),
    ServiceItem(id: 's-montaggio', name: 'Trasporto e montaggio', category: 'Servizi', description: 'Con i nostri montatori.', internalPrice: 250),
    ServiceItem(id: 's-smaltimento', name: 'Ritiro del vecchio arredo', category: 'Servizi', description: 'Smontaggio e smaltimento.', internalPrice: 150),
    ServiceItem(id: 's-finanziamento', name: 'Pagamento rateale', category: 'Servizi', description: 'Finanziamento su misura.'),
  ];

  static List<ServicePackage> packages() => [
    ServicePackage(
      id: 'p-chiavi',
      name: 'Casa chiavi in mano',
      tagline: 'Pensiamo a tutto noi',
      description: 'Progetto completo, arredi, luci, tessili, consegna e montaggio.',
      serviceIds: ['s-sopralluogo', 's-3d', 's-materiali', 's-imbottiti', 's-luci', 's-tende', 's-montaggio'],
      image: _u(9),
      featured: true,
    ),
    ServicePackage(
      id: 'p-cucina',
      name: 'Cucina completa',
      tagline: 'Dal rilievo al primo caffè',
      description: 'Misure, progetto 3D, cucina su misura, montaggio e ritiro della vecchia.',
      serviceIds: ['s-sopralluogo', 's-3d', 's-cucina', 's-montaggio', 's-smaltimento'],
      image: _u(34),
    ),
    ServicePackage(
      id: 'p-rinnova',
      name: 'Rinnova un ambiente',
      tagline: 'Un nuovo volto in poche settimane',
      description: 'Consulenza, scelta di imbottiti, luci e tessili per una stanza.',
      serviceIds: ['s-materiali', 's-imbottiti', 's-luci', 's-tende'],
      image: _u(29),
    ),
  ];
}
