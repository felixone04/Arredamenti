import 'dart:math';

import '../theme/site_theme.dart';

int _idSeq = 0;

/// Genera un id univoco leggero (niente dipendenze extra). Il contatore
/// evita doppioni anche quando se ne creano molti nello stesso istante.
String newId() {
  final r = Random();
  return '${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
      '${(_idSeq++).toRadixString(36)}'
      '${r.nextInt(1 << 20).toRadixString(36)}';
}

List<T> _list<T>(Object? v, T Function(Map<String, dynamic>) f) => [
  if (v is List)
    for (final e in v)
      if (e is Map) f(Map<String, dynamic>.from(e)),
];

List<String> _strings(Object? v) =>
    v is List ? [for (final e in v) '$e'] : <String>[];

/// Titolo + testo breve (numeri del negozio, punti di forza).
class Highlight {
  String title;
  String text;
  Highlight({required this.title, required this.text});

  factory Highlight.fromJson(Map<String, dynamic> j) =>
      Highlight(title: j['title'] ?? '', text: j['text'] ?? '');
  Map<String, dynamic> toJson() => {'title': title, 'text': text};
}

/// Una tappa (anno della storia o passaggio del metodo).
class Milestone {
  String year;
  String title;
  String text;
  Milestone({required this.year, required this.title, required this.text});

  factory Milestone.fromJson(Map<String, dynamic> j) => Milestone(
    year: j['year'] ?? '',
    title: j['title'] ?? '',
    text: j['text'] ?? '',
  );
  Map<String, dynamic> toJson() => {'year': year, 'title': title, 'text': text};
}

class TeamMember {
  String id;
  String name;
  String role;
  String bio;
  String photo;
  TeamMember({
    String? id,
    required this.name,
    required this.role,
    this.bio = '',
    this.photo = '',
  }) : id = id ?? newId();

  factory TeamMember.fromJson(Map<String, dynamic> j) => TeamMember(
    id: j['id'],
    name: j['name'] ?? '',
    role: j['role'] ?? '',
    bio: j['bio'] ?? '',
    photo: j['photo'] ?? '',
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'bio': bio,
    'photo': photo,
  };
}

class Contacts {
  String phone;
  String whatsapp;
  String email;
  String address;
  String hours;
  String instagram;
  String facebook;
  String pinterest;
  String vat;
  Contacts({
    this.phone = '',
    this.whatsapp = '',
    this.email = '',
    this.address = '',
    this.hours = '',
    this.instagram = '',
    this.facebook = '',
    this.pinterest = '',
    this.vat = '',
  });

  factory Contacts.fromJson(Map<String, dynamic> j) => Contacts(
    phone: j['phone'] ?? '',
    whatsapp: j['whatsapp'] ?? '',
    email: j['email'] ?? '',
    address: j['address'] ?? '',
    hours: j['hours'] ?? '',
    instagram: j['instagram'] ?? '',
    facebook: j['facebook'] ?? '',
    pinterest: j['pinterest'] ?? '',
    vat: j['vat'] ?? '',
  );
  Map<String, dynamic> toJson() => {
    'phone': phone,
    'whatsapp': whatsapp,
    'email': email,
    'address': address,
    'hours': hours,
    'instagram': instagram,
    'facebook': facebook,
    'pinterest': pinterest,
    'vat': vat,
  };
}

/// Tutti i testi e le immagini modificabili del sito.
class SiteContent {
  String shopName;
  String tagline;

  // Home – apertura
  String heroKicker;
  String heroTitle;
  String heroSubtitle;

  // Home – presentazione
  String introKicker;
  String introTitle;
  String introText;
  List<Highlight> stats;

  // Home – ambienti
  String roomsKicker;
  String roomsTitle;
  String roomsIntro;

  // Home – carosello dello showroom
  String showcaseKicker;
  String showcaseTitle;

  // Home – marchi
  String brandsKicker;
  String brandsTitle;
  String brandsIntro;

  // Home e Biografia – metodo di lavoro
  String processTitle;
  List<Milestone> process;

  // Home – recensioni
  String reviewsKicker;
  String reviewsTitle;

  // Home – invito al preventivo
  String bannerTitle;
  String bannerText;
  String bannerButton;
  String bannerImage;

  // Pagina preventivo
  String quoteTitle;
  String quoteIntro;
  String quoteImage;

  // Biografia
  String bioTitle;
  String bioIntro;
  String bioStory; // paragrafi separati da riga vuota
  String bioImage;
  String bioImage2;
  List<Milestone> timeline;
  String teamTitle;
  List<TeamMember> team;

  Contacts contacts;
  String footerNote;

  // Opzioni del modulo preventivo
  List<String> roomTypes;
  List<String> styles;
  List<String> budgets;
  List<String> timings;

  SiteContent({
    required this.shopName,
    required this.tagline,
    required this.heroKicker,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.introKicker,
    required this.introTitle,
    required this.introText,
    required this.stats,
    required this.roomsKicker,
    required this.roomsTitle,
    required this.roomsIntro,
    required this.showcaseKicker,
    required this.showcaseTitle,
    required this.brandsKicker,
    required this.brandsTitle,
    required this.brandsIntro,
    required this.processTitle,
    required this.process,
    required this.reviewsKicker,
    required this.reviewsTitle,
    required this.bannerTitle,
    required this.bannerText,
    required this.bannerButton,
    required this.bannerImage,
    required this.quoteTitle,
    required this.quoteIntro,
    required this.quoteImage,
    required this.bioTitle,
    required this.bioIntro,
    required this.bioStory,
    required this.bioImage,
    required this.bioImage2,
    required this.timeline,
    required this.teamTitle,
    required this.team,
    required this.contacts,
    required this.footerNote,
    required this.roomTypes,
    required this.styles,
    required this.budgets,
    required this.timings,
  });

  factory SiteContent.fromJson(Map<String, dynamic> j, SiteContent d) {
    String s(String k, String def) => j[k] is String ? j[k] as String : def;
    List<T> l<T>(String k, T Function(Map<String, dynamic>) f, List<T> def) =>
        j[k] is List ? _list(j[k], f) : def;
    List<String> ls(String k, List<String> def) =>
        j[k] is List ? _strings(j[k]) : def;

    return SiteContent(
      shopName: s('shopName', d.shopName),
      tagline: s('tagline', d.tagline),
      heroKicker: s('heroKicker', d.heroKicker),
      heroTitle: s('heroTitle', d.heroTitle),
      heroSubtitle: s('heroSubtitle', d.heroSubtitle),
      introKicker: s('introKicker', d.introKicker),
      introTitle: s('introTitle', d.introTitle),
      introText: s('introText', d.introText),
      stats: l('stats', Highlight.fromJson, d.stats),
      roomsKicker: s('roomsKicker', d.roomsKicker),
      roomsTitle: s('roomsTitle', d.roomsTitle),
      roomsIntro: s('roomsIntro', d.roomsIntro),
      showcaseKicker: s('showcaseKicker', d.showcaseKicker),
      showcaseTitle: s('showcaseTitle', d.showcaseTitle),
      brandsKicker: s('brandsKicker', d.brandsKicker),
      brandsTitle: s('brandsTitle', d.brandsTitle),
      brandsIntro: s('brandsIntro', d.brandsIntro),
      processTitle: s('processTitle', d.processTitle),
      process: l('process', Milestone.fromJson, d.process),
      reviewsKicker: s('reviewsKicker', d.reviewsKicker),
      reviewsTitle: s('reviewsTitle', d.reviewsTitle),
      bannerTitle: s('bannerTitle', d.bannerTitle),
      bannerText: s('bannerText', d.bannerText),
      bannerButton: s('bannerButton', d.bannerButton),
      bannerImage: s('bannerImage', d.bannerImage),
      quoteTitle: s('quoteTitle', d.quoteTitle),
      quoteIntro: s('quoteIntro', d.quoteIntro),
      quoteImage: s('quoteImage', d.quoteImage),
      bioTitle: s('bioTitle', d.bioTitle),
      bioIntro: s('bioIntro', d.bioIntro),
      bioStory: s('bioStory', d.bioStory),
      bioImage: s('bioImage', d.bioImage),
      bioImage2: s('bioImage2', d.bioImage2),
      timeline: l('timeline', Milestone.fromJson, d.timeline),
      teamTitle: s('teamTitle', d.teamTitle),
      team: l('team', TeamMember.fromJson, d.team),
      contacts: j['contacts'] is Map
          ? Contacts.fromJson(Map<String, dynamic>.from(j['contacts']))
          : d.contacts,
      footerNote: s('footerNote', d.footerNote),
      roomTypes: ls('roomTypes', d.roomTypes),
      styles: ls('styles', d.styles),
      budgets: ls('budgets', d.budgets),
      timings: ls('timings', d.timings),
    );
  }

  Map<String, dynamic> toJson() => {
    'shopName': shopName,
    'tagline': tagline,
    'heroKicker': heroKicker,
    'heroTitle': heroTitle,
    'heroSubtitle': heroSubtitle,
    'introKicker': introKicker,
    'introTitle': introTitle,
    'introText': introText,
    'stats': stats.map((e) => e.toJson()).toList(),
    'roomsKicker': roomsKicker,
    'roomsTitle': roomsTitle,
    'roomsIntro': roomsIntro,
    'showcaseKicker': showcaseKicker,
    'showcaseTitle': showcaseTitle,
    'brandsKicker': brandsKicker,
    'brandsTitle': brandsTitle,
    'brandsIntro': brandsIntro,
    'processTitle': processTitle,
    'process': process.map((e) => e.toJson()).toList(),
    'reviewsKicker': reviewsKicker,
    'reviewsTitle': reviewsTitle,
    'bannerTitle': bannerTitle,
    'bannerText': bannerText,
    'bannerButton': bannerButton,
    'bannerImage': bannerImage,
    'quoteTitle': quoteTitle,
    'quoteIntro': quoteIntro,
    'quoteImage': quoteImage,
    'bioTitle': bioTitle,
    'bioIntro': bioIntro,
    'bioStory': bioStory,
    'bioImage': bioImage,
    'bioImage2': bioImage2,
    'timeline': timeline.map((e) => e.toJson()).toList(),
    'teamTitle': teamTitle,
    'team': team.map((e) => e.toJson()).toList(),
    'contacts': contacts.toJson(),
    'footerNote': footerNote,
    'roomTypes': roomTypes,
    'styles': styles,
    'budgets': budgets,
    'timings': timings,
  };

  /// Copia profonda, usata dagli editor del gestionale come bozza.
  SiteContent copy() => SiteContent.fromJson(toJson(), this);
}

/// Una voce del preventivo: servizio (progettazione, montaggio…) o
/// prodotto. Il prezzo resta interno.
class ServiceItem {
  String id;
  String name;
  String description;
  String category;
  String image;
  double? internalPrice; // visibile solo nel gestionale
  bool active;
  ServiceItem({
    String? id,
    required this.name,
    this.description = '',
    this.category = 'Servizi',
    this.image = '',
    this.internalPrice,
    this.active = true,
  }) : id = id ?? newId();

  factory ServiceItem.fromJson(Map<String, dynamic> j) => ServiceItem(
    id: j['id'],
    name: j['name'] ?? '',
    description: j['description'] ?? '',
    category: j['category'] ?? 'Servizi',
    image: j['image'] ?? '',
    internalPrice: (j['internalPrice'] as num?)?.toDouble(),
    active: j['active'] ?? true,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'image': image,
    'internalPrice': internalPrice,
    'active': active,
  };
}

/// Formula pronta: un insieme di servizi (es. "Casa chiavi in mano").
class ServicePackage {
  String id;
  String name;
  String tagline;
  String description;
  List<String> serviceIds;
  String image;
  bool featured;
  bool active;
  ServicePackage({
    String? id,
    required this.name,
    this.tagline = '',
    this.description = '',
    List<String>? serviceIds,
    this.image = '',
    this.featured = false,
    this.active = true,
  }) : id = id ?? newId(),
       serviceIds = serviceIds ?? [];

  factory ServicePackage.fromJson(Map<String, dynamic> j) => ServicePackage(
    id: j['id'],
    name: j['name'] ?? '',
    tagline: j['tagline'] ?? '',
    description: j['description'] ?? '',
    serviceIds: _strings(j['serviceIds']),
    image: j['image'] ?? '',
    featured: j['featured'] ?? false,
    active: j['active'] ?? true,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tagline': tagline,
    'description': description,
    'serviceIds': serviceIds,
    'image': image,
    'featured': featured,
    'active': active,
  };
}

/// Foto della galleria: compare nel carosello dello showroom e, con la
/// stella, anche nella prima schermata.
class GalleryPhoto {
  String id;
  String url;
  String title;
  String caption;
  String category;
  bool inHero;
  GalleryPhoto({
    String? id,
    required this.url,
    required this.title,
    this.caption = '',
    this.category = '',
    this.inHero = false,
  }) : id = id ?? newId();

  factory GalleryPhoto.fromJson(Map<String, dynamic> j) => GalleryPhoto(
    id: j['id'],
    url: j['url'] ?? '',
    title: j['title'] ?? '',
    caption: j['caption'] ?? '',
    category: j['category'] ?? '',
    inHero: j['inHero'] ?? false,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'title': title,
    'caption': caption,
    'category': category,
    'inHero': inHero,
  };
}

/// Una foto di un ambiente, con la sua didascalia.
class RoomPhoto {
  String id;
  String url;
  String caption;
  RoomPhoto({String? id, required this.url, this.caption = ''})
    : id = id ?? newId();

  factory RoomPhoto.fromJson(Map<String, dynamic> j) =>
      RoomPhoto(id: j['id'], url: j['url'] ?? '', caption: j['caption'] ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'url': url, 'caption': caption};
}

/// Un ambiente della casa (soggiorno, cucina…): in home è una foto grande
/// con la descrizione, nella sua pagina la sequenza completa delle foto.
class Room {
  String id;
  String title;
  String kicker; // es. "Zona giorno"
  String description; // breve, in home
  String story; // più lunga, nella pagina dell'ambiente
  String cover;
  List<RoomPhoto> photos;
  List<String> features; // es. "Su misura", "Rovere naturale"
  List<String> brandIds;
  bool published;
  Room({
    String? id,
    required this.title,
    this.kicker = '',
    this.description = '',
    this.story = '',
    this.cover = '',
    List<RoomPhoto>? photos,
    List<String>? features,
    List<String>? brandIds,
    this.published = true,
  }) : id = id ?? newId(),
       photos = photos ?? [],
       features = features ?? [],
       brandIds = brandIds ?? [];

  /// Copertina: quella scelta, altrimenti la prima foto.
  String get coverUrl => cover.trim().isNotEmpty
      ? cover
      : (photos.isEmpty ? '' : photos.first.url);

  factory Room.fromJson(Map<String, dynamic> j) => Room(
    id: j['id'],
    title: j['title'] ?? '',
    kicker: j['kicker'] ?? '',
    description: j['description'] ?? '',
    story: j['story'] ?? '',
    cover: j['cover'] ?? '',
    photos: _list(j['photos'], RoomPhoto.fromJson),
    features: _strings(j['features']),
    brandIds: _strings(j['brandIds']),
    published: j['published'] ?? true,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'kicker': kicker,
    'description': description,
    'story': story,
    'cover': cover,
    'photos': photos.map((e) => e.toJson()).toList(),
    'features': features,
    'brandIds': brandIds,
    'published': published,
  };
}

/// Un marchio venduto dal negozio. Senza logo si mostra il nome in
/// carattere elegante.
class Brand {
  String id;
  String name;
  String logo;
  String category; // es. "Cucine", "Imbottiti", "Illuminazione"
  String description;
  String website;
  bool active;
  Brand({
    String? id,
    required this.name,
    this.logo = '',
    this.category = '',
    this.description = '',
    this.website = '',
    this.active = true,
  }) : id = id ?? newId();

  factory Brand.fromJson(Map<String, dynamic> j) => Brand(
    id: j['id'],
    name: j['name'] ?? '',
    logo: j['logo'] ?? '',
    category: j['category'] ?? '',
    description: j['description'] ?? '',
    website: j['website'] ?? '',
    active: j['active'] ?? true,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo': logo,
    'category': category,
    'description': description,
    'website': website,
    'active': active,
  };
}

/// Recensione di un cliente. Quelle inviate dal sito restano nascoste
/// finché il titolare non le approva.
class Review {
  String id;
  String name;
  String text;
  int rating; // da 1 a 5
  String project; // es. "Cucina e soggiorno"
  DateTime createdAt;
  bool published;
  bool fromSite; // scritta da un visitatore (da approvare)
  Review({
    String? id,
    required this.name,
    required this.text,
    this.rating = 5,
    this.project = '',
    DateTime? createdAt,
    this.published = true,
    this.fromSite = false,
  }) : id = id ?? newId(),
       createdAt = createdAt ?? DateTime.now();

  factory Review.fromJson(Map<String, dynamic> j) => Review(
    id: j['id'],
    name: j['name'] ?? '',
    text: j['text'] ?? '',
    rating: ((j['rating'] as num?)?.toInt() ?? 5).clamp(1, 5),
    project: j['project'] ?? '',
    createdAt: DateTime.tryParse(j['createdAt'] ?? ''),
    published: j['published'] ?? true,
    fromSite: j['fromSite'] ?? false,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'text': text,
    'rating': rating,
    'project': project,
    'createdAt': createdAt.toIso8601String(),
    'published': published,
    'fromSite': fromSite,
  };
}

enum QuoteStatus { nuova, contattata, sopralluogo, confermata, archiviata }

extension QuoteStatusLabel on QuoteStatus {
  String get label => switch (this) {
    QuoteStatus.nuova => 'Nuova',
    QuoteStatus.contattata => 'Contattata',
    QuoteStatus.sopralluogo => 'Sopralluogo',
    QuoteStatus.confermata => 'Confermata',
    QuoteStatus.archiviata => 'Archiviata',
  };
}

class QuoteRequest {
  String id;
  DateTime createdAt;
  String firstName;
  String lastName;
  String phone;
  String email;
  String city;
  List<String> rooms;
  String style;
  String budget;
  String timing;
  String size; // metri quadri, testo libero
  String message;
  List<String> serviceIds;
  String? packageId;
  QuoteStatus status;
  String? appointmentId;
  String notes; // appunti interni del negozio

  QuoteRequest({
    String? id,
    DateTime? createdAt,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.city = '',
    List<String>? rooms,
    this.style = '',
    this.budget = '',
    this.timing = '',
    this.size = '',
    this.message = '',
    List<String>? serviceIds,
    this.packageId,
    this.status = QuoteStatus.nuova,
    this.appointmentId,
    this.notes = '',
  }) : id = id ?? newId(),
       createdAt = createdAt ?? DateTime.now(),
       rooms = rooms ?? [],
       serviceIds = serviceIds ?? [];

  String get fullName => '$firstName $lastName'.trim();

  /// Riga riassuntiva: ambienti e città.
  String get summary => [
    if (rooms.isNotEmpty) rooms.join(', '),
    if (city.trim().isNotEmpty) city.trim(),
  ].join(' · ');

  factory QuoteRequest.fromJson(Map<String, dynamic> j) => QuoteRequest(
    id: j['id'],
    createdAt: DateTime.tryParse(j['createdAt'] ?? ''),
    firstName: j['firstName'] ?? '',
    lastName: j['lastName'] ?? '',
    phone: j['phone'] ?? '',
    email: j['email'] ?? '',
    city: j['city'] ?? '',
    rooms: _strings(j['rooms']),
    style: j['style'] ?? '',
    budget: j['budget'] ?? '',
    timing: j['timing'] ?? '',
    size: j['size'] ?? '',
    message: j['message'] ?? '',
    serviceIds: _strings(j['serviceIds']),
    packageId: j['packageId'],
    status: QuoteStatus.values.firstWhere(
      (e) => e.name == j['status'],
      orElse: () => QuoteStatus.nuova,
    ),
    appointmentId: j['appointmentId'],
    notes: j['notes'] ?? '',
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'email': email,
    'city': city,
    'rooms': rooms,
    'style': style,
    'budget': budget,
    'timing': timing,
    'size': size,
    'message': message,
    'serviceIds': serviceIds,
    'packageId': packageId,
    'status': status.name,
    'appointmentId': appointmentId,
    'notes': notes,
  };
}

class Appointment {
  String id;
  String title;
  DateTime start;
  DateTime end;
  bool allDay;
  String location;
  String notes;
  String? quoteId;
  String? googleEventId;

  Appointment({
    String? id,
    required this.title,
    required this.start,
    required this.end,
    this.allDay = false,
    this.location = '',
    this.notes = '',
    this.quoteId,
    this.googleEventId,
  }) : id = id ?? newId();

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
    id: j['id'],
    title: j['title'] ?? '',
    start: DateTime.tryParse(j['start'] ?? '') ?? DateTime.now(),
    end: DateTime.tryParse(j['end'] ?? '') ?? DateTime.now(),
    allDay: j['allDay'] ?? false,
    location: j['location'] ?? '',
    notes: j['notes'] ?? '',
    quoteId: j['quoteId'],
    googleEventId: j['googleEventId'],
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'allDay': allDay,
    'location': location,
    'notes': notes,
    'quoteId': quoteId,
    'googleEventId': googleEventId,
  };
}

/// Chi vede il pulsante "Cambia stile" sul sito.
enum SwitcherMode { tutti, link, nessuno }

extension SwitcherModeLabel on SwitcherMode {
  String get label => switch (this) {
    SwitcherMode.tutti => 'Visibile a tutti',
    SwitcherMode.link => 'Solo con il link di prova',
    SwitcherMode.nessuno => 'Nascosto',
  };
}

/// Stile del sito: tema predefinito, temi proponibili e temi creati dal
/// titolare.
class LookSettings {
  String defaultTheme;
  List<String> hidden; // temi pronti da non proporre
  SwitcherMode switcher;
  List<SiteTheme> custom;
  LookSettings({
    this.defaultTheme = 'galleria',
    List<String>? hidden,
    this.switcher = SwitcherMode.link,
    List<SiteTheme>? custom,
  }) : hidden = hidden ?? [],
       custom = custom ?? [];

  factory LookSettings.fromJson(Map<String, dynamic> j) => LookSettings(
    defaultTheme: j['defaultTheme'] ?? 'galleria',
    hidden: _strings(j['hidden']),
    switcher: SwitcherMode.values.firstWhere(
      (e) => e.name == j['switcher'],
      orElse: () => SwitcherMode.link,
    ),
    custom: _list(j['custom'], SiteTheme.fromJson),
  );
  Map<String, dynamic> toJson() => {
    'defaultTheme': defaultTheme,
    'hidden': hidden,
    'switcher': switcher.name,
    'custom': custom.map((e) => e.toJson()).toList(),
  };
}

/// Impostazioni riservate al titolare (non pubbliche).
class AdminSettings {
  String passwordHash;
  String passwordSalt;
  String googleClientId;
  bool googleWasConnected;

  /// Fine della sessione "ricordami" su questo dispositivo.
  DateTime? sessionUntil;
  AdminSettings({
    this.passwordHash = '',
    this.passwordSalt = '',
    this.googleClientId = '',
    this.googleWasConnected = false,
    this.sessionUntil,
  });

  factory AdminSettings.fromJson(Map<String, dynamic> j) => AdminSettings(
    passwordHash: j['passwordHash'] ?? '',
    passwordSalt: j['passwordSalt'] ?? '',
    googleClientId: j['googleClientId'] ?? '',
    googleWasConnected: j['googleWasConnected'] ?? false,
    sessionUntil: DateTime.tryParse(j['sessionUntil'] ?? ''),
  );
  Map<String, dynamic> toJson() => {
    'passwordHash': passwordHash,
    'passwordSalt': passwordSalt,
    'googleClientId': googleClientId,
    'googleWasConnected': googleWasConnected,
    'sessionUntil': sessionUntil?.toIso8601String(),
  };
}
