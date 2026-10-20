import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../config.dart';
import '../data/repository.dart';
import '../data/seed.dart';
import '../models/models.dart';
import '../services/google_calendar_service.dart';
import '../services/google_token.dart';
import '../theme/site_theme.dart';

class AppState extends ChangeNotifier {
  AppState(this.repo);
  final Repository repo;

  bool loaded = false;
  bool adminAuthenticated = false;

  late SiteContent content;
  List<Room> rooms = [];
  List<Brand> brands = [];
  List<ServiceItem> services = [];
  List<ServicePackage> packages = [];
  List<GalleryPhoto> gallery = [];
  List<Review> reviews = [];
  List<QuoteRequest> quotes = [];
  List<Appointment> appointments = [];
  LookSettings look = LookSettings();
  AdminSettings settings = AdminSettings();

  final GoogleCalendarService calendar = GoogleCalendarService();

  // ---------------------------------------------------------------- load

  Future<void> load() async {
    final seed = Seed.content();
    final c = await repo.read('content');
    content = c is Map
        ? SiteContent.fromJson(Map<String, dynamic>.from(c), seed)
        : seed;

    rooms = await _list('rooms', Room.fromJson) ?? Seed.rooms();
    brands = await _list('brands', Brand.fromJson) ?? Seed.brands();
    services = await _list('services', ServiceItem.fromJson) ?? Seed.services();
    packages =
        await _list('packages', ServicePackage.fromJson) ?? Seed.packages();
    gallery = await _list('gallery', GalleryPhoto.fromJson) ?? Seed.gallery();
    reviews = await _list('reviews', Review.fromJson) ?? Seed.reviews();
    quotes = await _list('quotes', QuoteRequest.fromJson) ?? [];
    appointments = await _list('appointments', Appointment.fromJson) ?? [];

    final l = await repo.read('look');
    look = l is Map
        ? LookSettings.fromJson(Map<String, dynamic>.from(l))
        : LookSettings();

    final s = await repo.read('settings');
    settings = s is Map
        ? AdminSettings.fromJson(Map<String, dynamic>.from(s))
        : AdminSettings();
    final until = settings.sessionUntil;
    adminAuthenticated = until != null && DateTime.now().isBefore(until);

    loaded = true;
    notifyListeners();
  }

  Future<List<T>?> _list<T>(
    String key,
    T Function(Map<String, dynamic>) f,
  ) async {
    final v = await repo.read(key);
    if (v is! List) return null;
    return [
      for (final e in v)
        if (e is Map) f(Map<String, dynamic>.from(e)),
    ];
  }

  Future<void> _persist(String key, Object json) async {
    await repo.write(key, json);
    notifyListeners();
  }

  // ------------------------------------------------------------------ temi

  /// Tema scelto da chi sta guardando il sito (solo per questa visita).
  String? _visitorTheme;

  /// Il link di prova (?prova=1) mostra il pulsante "Cambia stile" anche
  /// quando è riservato.
  bool trialUnlocked = false;

  /// Tutti i temi: quelli pronti e quelli creati nel gestionale.
  List<SiteTheme> get allThemes => [...builtInThemes, ...look.custom];

  SiteTheme? themeById(String? id) {
    for (final t in allThemes) {
      if (t.id == id) return t;
    }
    return null;
  }

  SiteTheme get defaultTheme =>
      themeById(look.defaultTheme) ?? builtInThemes.first;

  /// Temi proposti nel pulsante "Cambia stile" (il predefinito c'è sempre).
  List<SiteTheme> get offeredThemes => [
    for (final t in allThemes)
      if (!look.hidden.contains(t.id) || t.id == defaultTheme.id) t,
  ];

  /// Il tema con cui si vede ora il sito.
  SiteTheme get currentTheme => themeById(_visitorTheme) ?? defaultTheme;

  bool get switcherVisible =>
      look.switcher == SwitcherMode.tutti ||
      (look.switcher == SwitcherMode.link && trialUnlocked);

  void selectTheme(String id) {
    if (themeById(id) == null || id == _visitorTheme) return;
    _visitorTheme = id;
    notifyListeners();
  }

  /// Legge i parametri del link: `?prova=1` sblocca il pulsante dei temi,
  /// `?tema=notte` apre il sito con quel tema (utile da mandare a un cliente).
  void applyLinkParams(Map<String, String> q) {
    var changed = false;
    if (q['prova'] == '1' && !trialUnlocked) {
      trialUnlocked = true;
      changed = true;
    }
    final t = q['tema'];
    if (t != null && themeById(t) != null && t != _visitorTheme) {
      _visitorTheme = t;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<void> setLook(LookSettings l) {
    look = l;
    if (themeById(_visitorTheme) == null) _visitorTheme = null;
    return _persist('look', l.toJson());
  }

  // -------------------------------------------------------- public views

  List<Room> get publishedRooms => rooms.where((r) => r.published).toList();
  List<Brand> get activeBrands => brands.where((b) => b.active).toList();
  List<ServiceItem> get activeServices =>
      services.where((s) => s.active).toList();
  List<ServicePackage> get activePackages =>
      packages.where((p) => p.active).toList();
  List<Review> get publishedReviews =>
      reviews.where((r) => r.published).toList();
  int get pendingReviews => reviews.where((r) => !r.published).length;

  List<GalleryPhoto> get heroPhotos {
    final h = gallery.where((p) => p.inHero).toList();
    if (h.isNotEmpty) return h;
    if (gallery.isNotEmpty) return gallery;
    // Nessuna foto in galleria: si usano le copertine degli ambienti.
    return [
      for (final r in publishedRooms)
        if (r.coverUrl.isNotEmpty)
          GalleryPhoto(url: r.coverUrl, title: r.title, category: r.kicker),
    ];
  }

  Room? roomById(String? id) {
    for (final r in rooms) {
      if (r.id == id) return r;
    }
    return null;
  }

  Brand? brandById(String? id) {
    for (final b in brands) {
      if (b.id == id) return b;
    }
    return null;
  }

  ServiceItem? serviceById(String id) {
    for (final s in services) {
      if (s.id == id) return s;
    }
    return null;
  }

  ServicePackage? packageById(String? id) {
    if (id == null) return null;
    for (final p in packages) {
      if (p.id == id) return p;
    }
    return null;
  }

  QuoteRequest? quoteById(String? id) {
    if (id == null) return null;
    for (final q in quotes) {
      if (q.id == id) return q;
    }
    return null;
  }

  // ------------------------------------------------------------ mutations

  Future<void> updateContent(SiteContent c) {
    content = c;
    return _persist('content', c.toJson());
  }

  Future<void> setRooms(List<Room> list) {
    rooms = list;
    return _persist('rooms', list.map((e) => e.toJson()).toList());
  }

  Future<void> setBrands(List<Brand> list) {
    brands = list;
    return _persist('brands', list.map((e) => e.toJson()).toList());
  }

  Future<void> deleteBrand(String id) async {
    for (final r in rooms) {
      r.brandIds.remove(id);
    }
    await _persist('rooms', rooms.map((e) => e.toJson()).toList());
    await setBrands(brands.where((b) => b.id != id).toList());
  }

  Future<void> setServices(List<ServiceItem> list) {
    services = list;
    return _persist('services', list.map((e) => e.toJson()).toList());
  }

  Future<void> deleteService(String id) async {
    for (final p in packages) {
      p.serviceIds.remove(id);
    }
    await _persist('packages', packages.map((e) => e.toJson()).toList());
    await setServices(services.where((s) => s.id != id).toList());
  }

  Future<void> setPackages(List<ServicePackage> list) {
    packages = list;
    return _persist('packages', list.map((e) => e.toJson()).toList());
  }

  Future<void> setGallery(List<GalleryPhoto> list) {
    gallery = list;
    return _persist('gallery', list.map((e) => e.toJson()).toList());
  }

  Future<void> setReviews(List<Review> list) {
    reviews = list;
    return _persist('reviews', list.map((e) => e.toJson()).toList());
  }

  /// Recensione scritta da un visitatore: resta nascosta fino
  /// all'approvazione nel gestionale.
  Future<void> submitReview(Review r) {
    r
      ..published = false
      ..fromSite = true;
    return setReviews([r, ...reviews]);
  }

  Future<void> addQuote(QuoteRequest q) {
    quotes = [q, ...quotes];
    return _persist('quotes', quotes.map((e) => e.toJson()).toList());
  }

  Future<void> updateQuote(QuoteRequest q) {
    quotes = [for (final e in quotes) e.id == q.id ? q : e];
    return _persist('quotes', quotes.map((e) => e.toJson()).toList());
  }

  Future<void> deleteQuote(String id) {
    quotes = quotes.where((e) => e.id != id).toList();
    return _persist('quotes', quotes.map((e) => e.toJson()).toList());
  }

  Future<void> _persistAppointments() =>
      _persist('appointments', appointments.map((e) => e.toJson()).toList());

  // ---------------------------------------------------------- appointments

  /// Salva l'appuntamento in locale e, se Google è collegato, anche su Google
  /// Calendar. Restituisce un avviso se la sincronizzazione non è riuscita.
  Future<String?> saveAppointment(Appointment a) async {
    String? warning;
    if (calendar.connected) {
      try {
        if (a.googleEventId == null) {
          a.googleEventId = await calendar.insert(a);
        } else {
          await calendar.update(a);
        }
      } on GoogleAuthException catch (e) {
        warning = e.message;
      } catch (e) {
        warning = 'Sincronizzazione con Google non riuscita: $e';
      }
    } else if (settings.googleWasConnected) {
      warning =
          'Appuntamento salvato solo qui: ricollega Google Calendar per sincronizzarlo.';
    }
    final i = appointments.indexWhere((e) => e.id == a.id);
    if (i >= 0) {
      appointments[i] = a;
    } else {
      appointments = [...appointments, a];
    }
    // Un appuntamento fissato da una richiesta nuova la porta avanti.
    final q = quoteById(a.quoteId);
    if (q != null && q.status == QuoteStatus.nuova) {
      q.status = QuoteStatus.sopralluogo;
      await _persist('quotes', quotes.map((e) => e.toJson()).toList());
    }
    await _persistAppointments();
    return warning;
  }

  Future<String?> deleteAppointment(Appointment a) async {
    String? warning;
    if (a.googleEventId != null && calendar.connected) {
      try {
        await calendar.delete(a.googleEventId!);
      } on GoogleAuthException catch (e) {
        warning = e.message;
      } catch (e) {
        warning = 'Impossibile eliminarlo anche da Google Calendar: $e';
      }
    } else if (a.googleEventId != null) {
      warning =
          'Eliminato qui, ma resta su Google Calendar: ricollegalo per rimuoverlo anche lì.';
    }
    appointments = appointments.where((e) => e.id != a.id).toList();
    for (final q in quotes) {
      if (q.appointmentId == a.id) q.appointmentId = null;
    }
    await _persist('quotes', quotes.map((e) => e.toJson()).toList());
    await _persistAppointments();
    return warning;
  }

  /// Invia a Google gli appuntamenti locali non ancora sincronizzati.
  Future<int> pushUnsyncedToGoogle() async {
    var n = 0;
    try {
      for (final a in appointments.where((e) => e.googleEventId == null)) {
        a.googleEventId = await calendar.insert(a);
        n++;
      }
    } finally {
      // Anche se uno degli invii fallisce, quelli già riusciti vanno salvati:
      // altrimenti al prossimo tentativo finirebbero doppi su Google.
      if (n > 0) await _persistAppointments();
    }
    return n;
  }

  // ----------------------------------------------------- Google Calendar

  String get googleClientId => settings.googleClientId.trim().isNotEmpty
      ? settings.googleClientId.trim()
      : AppConfig.googleClientId;

  bool get googleConfigured => googleClientId.isNotEmpty;

  Future<void> connectGoogle() async {
    await calendar.connect(googleClientId);
    settings.googleWasConnected = true;
    await _persist('settings', settings.toJson());
  }

  Future<void> disconnectGoogle() async {
    calendar.disconnect();
    settings.googleWasConnected = false;
    await _persist('settings', settings.toJson());
  }

  Future<void> saveGoogleClientId(String id) {
    settings.googleClientId = id.trim();
    return _persist('settings', settings.toJson());
  }

  // ------------------------------------------------------------ admin auth

  bool get hasAdminPassword => settings.passwordHash.isNotEmpty;

  String _hash(String salt, String pw) =>
      sha256.convert(utf8.encode('$salt::$pw')).toString();

  Future<void> setAdminPassword(String pw, {bool remember = true}) async {
    final r = Random.secure();
    final salt = base64Url.encode(
      List<int>.generate(16, (_) => r.nextInt(256)),
    );
    settings.passwordSalt = salt;
    settings.passwordHash = _hash(salt, pw);
    adminAuthenticated = true;
    if (remember) _rememberSession();
    await _persist('settings', settings.toJson());
  }

  /// Verifica la password senza modificare lo stato di accesso.
  bool checkPassword(String pw) =>
      hasAdminPassword &&
      _hash(settings.passwordSalt, pw) == settings.passwordHash;

  Future<bool> login(String pw, {bool remember = true}) async {
    if (!checkPassword(pw)) return false;
    adminAuthenticated = true;
    if (remember) {
      _rememberSession();
      await _persist('settings', settings.toJson());
    } else {
      notifyListeners();
    }
    return true;
  }

  void _rememberSession() =>
      settings.sessionUntil = DateTime.now().add(const Duration(days: 30));

  Future<void> logout() async {
    adminAuthenticated = false;
    settings.sessionUntil = null;
    await _persist('settings', settings.toJson());
  }

  /// Caratteri occupati dalle immagini incorporate (data URL) nell'archivio del
  /// browser, che ha un limite di circa 5 MB.
  int get embeddedImageChars {
    var n = 0;
    void add(String u) {
      if (u.startsWith('data:')) n += u.length;
    }

    for (final p in gallery) {
      add(p.url);
    }
    for (final s in services) {
      add(s.image);
    }
    for (final p in packages) {
      add(p.image);
    }
    for (final b in brands) {
      add(b.logo);
    }
    for (final t in content.team) {
      add(t.photo);
    }
    for (final r in rooms) {
      add(r.cover);
      for (final p in r.photos) {
        add(p.url);
      }
    }
    for (final u in [
      content.bioImage,
      content.bioImage2,
      content.bannerImage,
      content.quoteImage,
    ]) {
      add(u);
    }
    return n;
  }

  static const _sections = [
    'content',
    'rooms',
    'brands',
    'services',
    'packages',
    'gallery',
    'reviews',
    'quotes',
    'appointments',
    'look',
  ];

  /// Copia di sicurezza di tutti i dati in un'unica stringa JSON.
  String exportBackup() => const JsonEncoder.withIndent(' ').convert({
    'version': 1,
    'content': content.toJson(),
    'rooms': rooms.map((e) => e.toJson()).toList(),
    'brands': brands.map((e) => e.toJson()).toList(),
    'services': services.map((e) => e.toJson()).toList(),
    'packages': packages.map((e) => e.toJson()).toList(),
    'gallery': gallery.map((e) => e.toJson()).toList(),
    'reviews': reviews.map((e) => e.toJson()).toList(),
    'quotes': quotes.map((e) => e.toJson()).toList(),
    'appointments': appointments.map((e) => e.toJson()).toList(),
    'look': look.toJson(),
  });

  Future<void> importBackup(String raw) async {
    const invalid = FormatException(
      'Il testo incollato non è una copia di sicurezza valida.',
    );
    final Object? j;
    try {
      j = jsonDecode(raw);
    } on FormatException {
      throw invalid;
    }
    if (j is! Map || j['content'] is! Map) throw invalid;
    // Prima di sovrascrivere i dati attuali verifica che ogni sezione si possa
    // leggere: un backup rovinato renderebbe il sito inutilizzabile anche
    // dopo aver ricaricato la pagina.
    final parsers = <String, Object Function(Map<String, dynamic>)>{
      'rooms': Room.fromJson,
      'brands': Brand.fromJson,
      'services': ServiceItem.fromJson,
      'packages': ServicePackage.fromJson,
      'gallery': GalleryPhoto.fromJson,
      'reviews': Review.fromJson,
      'quotes': QuoteRequest.fromJson,
      'appointments': Appointment.fromJson,
    };
    try {
      SiteContent.fromJson(
        Map<String, dynamic>.from(j['content'] as Map),
        Seed.content(),
      );
      for (final MapEntry(key: k, value: parse) in parsers.entries) {
        final v = j[k];
        if (v == null) continue;
        for (final e in v as List) {
          parse(Map<String, dynamic>.from(e as Map));
        }
      }
      if (j['look'] != null) {
        LookSettings.fromJson(Map<String, dynamic>.from(j['look'] as Map));
      }
    } catch (_) {
      throw invalid;
    }
    for (final k in _sections) {
      if (j[k] != null) await repo.write(k, j[k] as Object);
    }
    await load();
  }

  /// Rimette i contenuti di esempio. Richieste, appuntamenti e temi restano.
  Future<void> resetAll() async {
    await repo.write('content', Seed.content().toJson());
    await repo.write('rooms', Seed.rooms().map((e) => e.toJson()).toList());
    await repo.write('brands', Seed.brands().map((e) => e.toJson()).toList());
    await repo.write(
      'services',
      Seed.services().map((e) => e.toJson()).toList(),
    );
    await repo.write(
      'packages',
      Seed.packages().map((e) => e.toJson()).toList(),
    );
    await repo.write('gallery', Seed.gallery().map((e) => e.toJson()).toList());
    await load();
  }
}
