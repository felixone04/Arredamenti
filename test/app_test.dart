import 'package:arredamenti/models/models.dart';
import 'package:arredamenti/pages/quote_page.dart';
import 'package:arredamenti/theme/site_theme.dart';
import 'package:arredamenti/widgets/theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/harness.dart';

void main() {
  setUpAll(setUpTestEnv);

  group('Pagine su ogni schermo', () {
    const pages = [
      '/',
      '/ambienti',
      '/ambienti/r-cucina',
      '/marchi',
      '/biografia',
      '/preventivo',
      '/admin',
    ];
    for (final size in screenSizes) {
      testWidgets('si aprono senza errori a ${sizeName(size)}', (t) async {
        final s = await loadState();
        await pumpApp(t, s, size: size);
        for (final p in pages) {
          await goTo(t, p);
          expect(t.takeException(), isNull, reason: 'pagina $p');
        }
        await disposeApp(t);
      });
    }
  });

  group('Temi', () {
    testWidgets('il pulsante "Cambia stile" compare solo col link di prova', (
      t,
    ) async {
      final s = await loadState();
      await pumpApp(t, s);
      expect(find.byType(ThemeSwitcher), findsNothing);

      s.applyLinkParams({'prova': '1'});
      await settle(t, 600);
      expect(find.byType(ThemeSwitcher), findsOneWidget);

      await t.tap(find.text('CAMBIA STILE'));
      await settle(t, 600);
      await t.tap(find.text('Notte e ottone'));
      await settle(t, 1200);
      expect(s.currentTheme.id, 'notte');
      final ctx = t.element(find.byType(ThemeSwitcher));
      expect(ctx.st.dark, isTrue);
      await disposeApp(t);
    });

    test('il link ?tema= apre il sito con quel tema', () async {
      final s = await loadState();
      expect(s.currentTheme.id, 'galleria');
      s.applyLinkParams({'tema': 'riviera'});
      expect(s.currentTheme.id, 'riviera');
      s.applyLinkParams({'tema': 'inesistente'});
      expect(s.currentTheme.id, 'riviera');
    });

    test('tema predefinito, temi nascosti e temi personalizzati', () async {
      final s = await loadState();
      final mine = builtInThemes[1].copyWith(
        id: 'mio',
        name: 'Il mio tema',
        custom: true,
      );
      await s.setLook(
        LookSettings(
          defaultTheme: 'mio',
          hidden: ['salvia'],
          switcher: SwitcherMode.tutti,
          custom: [mine],
        ),
      );
      final again = await loadState({
        'look': s.look.toJson(),
      });
      expect(again.currentTheme.name, 'Il mio tema');
      expect(again.switcherVisible, isTrue);
      expect(again.offeredThemes.map((e) => e.id), isNot(contains('salvia')));
      expect(again.offeredThemes.map((e) => e.id), contains('mio'));
    });

    test('l\'accento resta leggibile su ogni tema', () {
      for (final th in builtInThemes) {
        final a = th.accentText.computeLuminance() + 0.05;
        final b = th.bg.computeLuminance() + 0.05;
        final ratio = a > b ? a / b : b / a;
        expect(ratio, greaterThan(3), reason: th.name);
      }
    });
  });

  group('Preventivo', () {
    test('controlli dei campi', () {
      expect(QuoteRules.name('', 'nome'), isNotNull);
      expect(QuoteRules.name('Al', 'nome'), isNull);
      expect(QuoteRules.phone('123'), isNotNull);
      expect(QuoteRules.phone('+39 333 1234567'), isNull);
      expect(QuoteRules.email('nome@'), isNotNull);
      expect(QuoteRules.email('nome@email.it'), isNull);
      expect(QuoteRules.city(''), isNotNull);
      expect(QuoteRules.size(''), isNull);
      expect(QuoteRules.size('0'), isNotNull);
      expect(QuoteRules.size('120'), isNull);
    });

    testWidgets('si invia e arriva nel gestionale', (t) async {
      final s = await loadState();
      await pumpApp(t, s, location: '/preventivo?a=Cucina');

      // L'ambiente arriva già scelto dal link.
      Future<void> type(String label, String text) async {
        final f = find.widgetWithText(TextFormField, label);
        await t.ensureVisible(f);
        await t.enterText(f, text);
      }

      await type('Città dell\'immobile *', 'Bari');
      await type('Nome *', 'Anna');
      await type('Cognome *', 'Verdi');
      await type('Telefono *', '+39 333 1234567');
      await type('Email *', 'anna@email.it');
      // Il campo attivo fa scorrere la pagina: si aspetta che si fermi.
      await settle(t, 800);
      final privacy = find.byType(Checkbox);
      await t.ensureVisible(privacy);
      await settle(t, 400);
      await t.tap(privacy);
      await t.pump();
      final send = find.text('INVIA LA RICHIESTA');
      await t.ensureVisible(send);
      await settle(t, 400);
      await t.tap(send);
      await settle(t);

      expect(s.quotes, hasLength(1));
      final q = s.quotes.first;
      expect(q.fullName, 'Anna Verdi');
      expect(q.rooms, ['Cucina']);
      expect(q.city, 'Bari');
      expect(find.text('Grazie, Anna.'), findsOneWidget);
      await disposeApp(t);
    });

    testWidgets('senza consenso e ambienti non parte', (t) async {
      final s = await loadState();
      await pumpApp(t, s, location: '/preventivo');
      final send = find.text('INVIA LA RICHIESTA');
      await t.ensureVisible(send);
      await t.tap(send);
      await settle(t, 1000);
      expect(s.quotes, isEmpty);
      expect(find.text('Scegli almeno un ambiente'), findsOneWidget);
      await disposeApp(t);
    });
  });

  group('Recensioni e dati', () {
    test('quelle dal sito restano nascoste fino all\'approvazione', () async {
      final s = await loadState();
      final before = s.publishedReviews.length;
      await s.submitReview(Review(name: 'Mario', text: 'Bellissima cucina'));
      expect(s.publishedReviews.length, before);
      expect(s.pendingReviews, 1);
      s.reviews.first.published = true;
      await s.setReviews([...s.reviews]);
      expect(s.publishedReviews.length, before + 1);
    });

    test('backup e ripristino', () async {
      final s = await loadState();
      await s.addQuote(
        QuoteRequest(
          firstName: 'Luca',
          lastName: 'Bianchi',
          phone: '3331234567',
          email: 'luca@email.it',
          rooms: ['Bagno'],
        ),
      );
      final raw = s.exportBackup();
      final other = await loadState();
      await other.importBackup(raw);
      expect(other.quotes.single.rooms, ['Bagno']);
      expect(other.rooms.length, s.rooms.length);
      expect(() => other.importBackup('non è json'), throwsFormatException);
    });

    test('eliminare un marchio lo toglie dagli ambienti', () async {
      final s = await loadState();
      expect(s.roomById('r-cucina')!.brandIds, contains('b-scavolini'));
      await s.deleteBrand('b-scavolini');
      expect(s.roomById('r-cucina')!.brandIds, isNot(contains('b-scavolini')));
    });
  });
}
