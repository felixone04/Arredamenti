// Infrastruttura comune ai test: archivio in memoria, caricamento dei font,
// avvio dell'app su una rotta e dimensione dello schermo a scelta.

// ignore_for_file: implementation_imports

import 'dart:convert';
import 'dart:io';

import 'package:arredamenti/app.dart';
import 'package:arredamenti/data/repository.dart';
import 'package:arredamenti/state/app_state.dart';
import 'package:arredamenti/theme/site_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/src/google_fonts_base.dart' as gf;
import 'package:google_fonts/src/google_fonts_family_with_variant.dart';
import 'package:google_fonts/src/google_fonts_variant.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Archivio in memoria: ogni scrittura passa da jsonEncode/jsonDecode, così
/// la serializzazione viene esercitata come con il vero localStorage.
class MemoryRepository implements Repository {
  MemoryRepository([Map<String, Object?>? initial]) {
    initial?.forEach((k, v) {
      if (v != null) raw[k] = jsonEncode(v);
    });
  }

  final Map<String, String> raw = {};

  @override
  Future<Object?> read(String key) async {
    final r = raw[key];
    if (r == null) return null;
    try {
      return jsonDecode(r);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, Object value) async {
    raw[key] = jsonEncode(value);
  }
}

Future<AppState> loadState([Map<String, Object?>? data]) async {
  final s = AppState(MemoryRepository(data));
  await s.load();
  return s;
}

// ------------------------------------------------------------------ font

class _FakeManifest implements AssetManifest {
  _FakeManifest(this.assets);
  final List<String> assets;
  @override
  List<String> listAssets() => assets;
  @override
  List<AssetMetadata>? getAssetVariants(String key) => null;
}

bool _envReady = false;

/// Tutte le famiglie usate: titoli dei temi + Manrope del testo.
final _families = [...headingFonts.keys, 'Manrope'];

/// Prepara l'ambiente: font Google sostituiti da Roboto (metriche realistiche,
/// niente rete), date in italiano, VisibilityDetector immediato.
Future<void> setUpTestEnv() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  if (_envReady) return;
  _envReady = true;
  await initializeDateFormatting('it_IT');
  GoogleFonts.config.allowRuntimeFetching = false;

  final root = Platform.environment['FLUTTER_ROOT'] ?? r'C:\src\flutter';
  final fontDir = '$root/bin/cache/artifacts/material_fonts';
  final regular = File('$fontDir/roboto-regular.ttf').readAsBytesSync();
  final italic = File('$fontDir/roboto-italic.ttf').readAsBytesSync();

  final paths = <String>[];
  for (final family in _families) {
    for (final w in FontWeight.values) {
      for (final st in FontStyle.values) {
        final prefix = GoogleFontsFamilyWithVariant(
          family: family.replaceAll(' ', ''),
          googleFontsVariant: GoogleFontsVariant(fontWeight: w, fontStyle: st),
        ).toApiFilenamePrefix();
        paths.add('gf/$prefix.ttf');
      }
    }
  }
  gf.assetManifest = _FakeManifest(paths.toSet().toList());

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMessageHandler('flutter/assets', (message) async {
    final key = utf8.decode(message!.buffer.asUint8List());
    if (key.startsWith('gf/')) {
      final bytes = key.contains('Italic') ? italic : regular;
      return Uint8List.fromList(bytes).buffer.asByteData();
    }
    return null;
  });

  for (final family in _families) {
    for (final w in FontWeight.values) {
      for (final st in FontStyle.values) {
        try {
          GoogleFonts.getFont(family, fontWeight: w, fontStyle: st);
        } catch (_) {}
      }
    }
  }
  await GoogleFonts.pendingFonts();
  messenger.setMockMessageHandler('flutter/assets', null);
}

// ---------------------------------------------------------------- schermi

/// Telefoni, tablet, PC e TV (anche 4K).
const screenSizes = <Size>[
  Size(320, 568),
  Size(390, 844),
  Size(820, 1180),
  Size(1180, 820),
  Size(1440, 900),
  Size(1920, 1080),
  Size(3840, 2160),
];

String sizeName(Size s) => '${s.width.toInt()}x${s.height.toInt()}';

void setScreen(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Avvia l'app sulla rotta indicata.
Future<void> pumpApp(
  WidgetTester tester,
  AppState state, {
  String location = '/',
  Size size = const Size(1440, 900),
}) async {
  setScreen(tester, size);
  tester.binding.platformDispatcher.defaultRouteNameTestValue = location;
  addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: state, child: const ShopApp()),
  );
  await settle(tester);
}

/// Fa avanzare il tempo a piccoli passi (l'app ha animazioni infinite, quindi
/// niente pumpAndSettle).
Future<void> settle(WidgetTester tester, [int ms = 2400]) async {
  for (var t = 0; t < ms; t += 200) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Smonta l'albero e lascia scadere i timer residui.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 12));
}

/// Naviga dentro l'app già avviata.
Future<void> goTo(WidgetTester tester, String location) async {
  final ctx = tester.element(find.byType(Scaffold).first);
  GoRouter.of(ctx).go(location);
  await settle(tester);
}
