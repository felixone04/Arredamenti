import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Caratteri tra cui scegliere i titoli di un tema, con il peso che li fa
/// rendere meglio in grande.
const headingFonts = <String, FontWeight>{
  'Cormorant Garamond': FontWeight.w500,
  'Playfair Display': FontWeight.w400,
  'Fraunces': FontWeight.w300,
  'DM Serif Display': FontWeight.w400,
  'Bodoni Moda': FontWeight.w400,
  'Manrope': FontWeight.w300,
  'Josefin Sans': FontWeight.w300,
};

/// Caratteri senza grazie: in grande vogliono una spaziatura più stretta.
const _sansFonts = {'Manrope', 'Josefin Sans'};

/// Un "vestito" completo del sito: colori, carattere dei titoli e stile dei
/// pulsanti. Le foto restano le stesse: cambia solo l'atmosfera.
///
/// È un [ThemeExtension]: quando si cambia tema, MaterialApp passa da uno
/// all'altro con una dissolvenza dei colori ([lerp]).
@immutable
class SiteTheme extends ThemeExtension<SiteTheme> {
  const SiteTheme({
    required this.id,
    required this.name,
    required this.bg,
    required this.surface,
    required this.alt,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    this.dark = false,
    this.headingFont = 'Cormorant Garamond',
    this.outlineButtons = false,
    this.custom = false,
  });

  final String id;
  final String name;

  /// Fondo della pagina.
  final Color bg;

  /// Schede e superfici in rilievo (moduli, riquadri).
  final Color surface;

  /// Sezioni alternate e segnaposto delle foto.
  final Color alt;

  /// Testi e segni.
  final Color ink;

  /// Testo secondario.
  final Color muted;

  /// Colore dei pulsanti e dei dettagli.
  final Color accent;

  /// Testo sopra l'accento.
  final Color onAccent;

  final bool dark;
  final String headingFont;

  /// Pulsanti a contorno (eleganti sui temi scuri) invece che pieni.
  final bool outlineButtons;

  /// Creato dal titolare nel gestionale (modificabile ed eliminabile).
  final bool custom;

  Color get line => ink.withValues(alpha: dark ? 0.16 : 0.13);
  Color get lineStrong => ink.withValues(alpha: dark ? 0.40 : 0.32);

  /// Accento usato come testo sul fondo: se è troppo simile al fondo lo si
  /// scurisce (o schiarisce sui temi scuri) finché si legge.
  Color get accentText {
    var c = HSLColor.fromColor(accent);
    for (var i = 0; i < 12 && _contrast(c.toColor(), bg) < 3.2; i++) {
      c = c.withLightness(
        (c.lightness + (dark ? 0.06 : -0.06)).clamp(0.0, 1.0),
      );
    }
    return c.toColor();
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance() + 0.05;
    final lb = b.computeLuminance() + 0.05;
    return la > lb ? la / lb : lb / la;
  }

  FontWeight get _headingWeight => headingFonts[headingFont] ?? FontWeight.w400;
  bool get _sans => _sansFonts.contains(headingFont);

  // -------------------------------------------------------------- testi

  /// Titoli, nel carattere del tema.
  TextStyle display(
    double size, {
    Color? color,
    bool italic = false,
    double height = 1.08,
    FontWeight? weight,
  }) {
    try {
      return GoogleFonts.getFont(
        headingFont,
        fontSize: size,
        color: color ?? ink,
        fontWeight: weight ?? _headingWeight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        height: height,
        letterSpacing: size * (_sans ? -0.025 : -0.01),
      );
    } catch (_) {
      // Nome di carattere sconosciuto (es. backup modificato a mano).
      return GoogleFonts.cormorantGaramond(
        fontSize: size,
        color: color ?? ink,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        height: height,
      );
    }
  }

  /// Etichette maiuscole spaziate.
  TextStyle label(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w600,
    double spacing = 0.2,
  }) => GoogleFonts.manrope(
    fontSize: size,
    fontWeight: weight,
    color: color ?? ink,
    height: 1.3,
    letterSpacing: size * spacing,
  );

  /// Testo corrente.
  TextStyle body(
    double size, {
    Color? color,
    FontWeight weight = FontWeight.w400,
    double height = 1.65,
  }) => GoogleFonts.manrope(
    fontSize: size,
    fontWeight: weight,
    color: color ?? ink,
    height: height,
  );

  // ------------------------------------------------------- ThemeExtension

  @override
  SiteTheme copyWith({
    String? id,
    String? name,
    Color? bg,
    Color? surface,
    Color? alt,
    Color? ink,
    Color? muted,
    Color? accent,
    Color? onAccent,
    bool? dark,
    String? headingFont,
    bool? outlineButtons,
    bool? custom,
  }) => SiteTheme(
    id: id ?? this.id,
    name: name ?? this.name,
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    alt: alt ?? this.alt,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    dark: dark ?? this.dark,
    headingFont: headingFont ?? this.headingFont,
    outlineButtons: outlineButtons ?? this.outlineButtons,
    custom: custom ?? this.custom,
  );

  @override
  SiteTheme lerp(covariant SiteTheme? other, double t) {
    if (other == null) return this;
    final next = t < 0.5 ? this : other;
    return SiteTheme(
      id: other.id,
      name: other.name,
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      alt: Color.lerp(alt, other.alt, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      // Carattere e stile dei pulsanti cambiano a metà della dissolvenza.
      dark: next.dark,
      headingFont: next.headingFont,
      outlineButtons: next.outlineButtons,
      custom: other.custom,
    );
  }

  // ------------------------------------------------------------- JSON

  factory SiteTheme.fromJson(Map<String, dynamic> j) {
    Color c(String k, int d) => Color((j[k] as int?) ?? d);
    return SiteTheme(
      id: j['id'] ?? 'tema',
      name: j['name'] ?? 'Tema',
      bg: c('bg', 0xFFF4EEE4),
      surface: c('surface', 0xFFFBF7F0),
      alt: c('alt', 0xFFEAE1D3),
      ink: c('ink', 0xFF2B2119),
      muted: c('muted', 0xFF6B5A4B),
      accent: c('accent', 0xFFB5562E),
      onAccent: c('onAccent', 0xFFFFF8EE),
      dark: j['dark'] ?? false,
      headingFont: headingFonts.containsKey(j['headingFont'])
          ? j['headingFont']
          : 'Cormorant Garamond',
      outlineButtons: j['outlineButtons'] ?? false,
      custom: true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bg': bg.toARGB32(),
    'surface': surface.toARGB32(),
    'alt': alt.toARGB32(),
    'ink': ink.toARGB32(),
    'muted': muted.toARGB32(),
    'accent': accent.toARGB32(),
    'onAccent': onAccent.toARGB32(),
    'dark': dark,
    'headingFont': headingFont,
    'outlineButtons': outlineButtons,
  };
}

/// I temi pronti. Il primo è quello predefinito.
const builtInThemes = <SiteTheme>[
  SiteTheme(
    id: 'galleria',
    name: 'Galleria calda',
    bg: Color(0xFFF4EEE4),
    surface: Color(0xFFFBF7F0),
    alt: Color(0xFFEAE1D3),
    ink: Color(0xFF2B2119),
    muted: Color(0xFF6B5A4B),
    accent: Color(0xFFB5562E),
    onAccent: Color(0xFFFFF8EE),
    headingFont: 'Cormorant Garamond',
  ),
  SiteTheme(
    id: 'notte',
    name: 'Notte e ottone',
    bg: Color(0xFF15130F),
    surface: Color(0xFF1E1B16),
    alt: Color(0xFF1B1914),
    ink: Color(0xFFEDE4D0),
    muted: Color(0xFFA89C86),
    accent: Color(0xFFC8A36A),
    onAccent: Color(0xFF15130F),
    dark: true,
    headingFont: 'Playfair Display',
    outlineButtons: true,
  ),
  SiteTheme(
    id: 'salvia',
    name: 'Atelier salvia',
    bg: Color(0xFFEEEDE6),
    surface: Color(0xFFF7F6F1),
    alt: Color(0xFFE1E1D6),
    ink: Color(0xFF23281F),
    muted: Color(0xFF59624F),
    accent: Color(0xFF5E6B4E),
    onAccent: Color(0xFFF4F3EC),
    headingFont: 'Fraunces',
  ),
  SiteTheme(
    id: 'cemento',
    name: 'Bianco cemento',
    bg: Color(0xFFF6F6F4),
    surface: Color(0xFFFFFFFF),
    alt: Color(0xFFEAEAE6),
    ink: Color(0xFF1C1C1C),
    muted: Color(0xFF5E5E5A),
    accent: Color(0xFF1C1C1C),
    onAccent: Color(0xFFF6F6F4),
    headingFont: 'Manrope',
  ),
  SiteTheme(
    id: 'riviera',
    name: 'Blu Riviera',
    bg: Color(0xFFF2F0EA),
    surface: Color(0xFFFAF8F3),
    alt: Color(0xFFE3E5E6),
    ink: Color(0xFF16243A),
    muted: Color(0xFF4A5870),
    accent: Color(0xFF1F3A5F),
    onAccent: Color(0xFFF2F0EA),
    headingFont: 'Playfair Display',
  ),
  SiteTheme(
    id: 'terracotta',
    name: 'Terracotta',
    bg: Color(0xFFF6E9DD),
    surface: Color(0xFFFCF4EC),
    alt: Color(0xFFEED9C6),
    ink: Color(0xFF3B1F14),
    muted: Color(0xFF7A5444),
    accent: Color(0xFF9C3F1E),
    onAccent: Color(0xFFFFF4EA),
    headingFont: 'Bodoni Moda',
  ),
  SiteTheme(
    id: 'ardesia',
    name: 'Ardesia',
    bg: Color(0xFF1E2227),
    surface: Color(0xFF262B31),
    alt: Color(0xFF22262B),
    ink: Color(0xFFE8E6E1),
    muted: Color(0xFFA3A7AC),
    accent: Color(0xFFD9B48F),
    onAccent: Color(0xFF1E2227),
    dark: true,
    headingFont: 'DM Serif Display',
  ),
];

extension SiteThemeX on BuildContext {
  /// Il tema del sito in uso (con le transizioni di colore).
  SiteTheme get st =>
      Theme.of(this).extension<SiteTheme>() ?? builtInThemes.first;
}

/// Tema Material del sito pubblico, costruito sui colori del [SiteTheme].
ThemeData siteThemeData(SiteTheme t) {
  final base = ThemeData(
    brightness: t.dark ? Brightness.dark : Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: t.dark ? Brightness.dark : Brightness.light,
      primary: t.ink,
      onPrimary: t.bg,
      secondary: t.accentText,
      onSecondary: t.bg,
      tertiary: t.accent,
      onTertiary: t.onAccent,
      surface: t.bg,
      onSurface: t.ink,
      onSurfaceVariant: t.muted,
      error: t.dark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
      onError: t.bg,
    ),
    scaffoldBackgroundColor: t.bg,
  );
  final error = base.colorScheme.error;
  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: BorderSide(color: c, width: w),
  );
  return base.copyWith(
    extensions: [t],
    textTheme: GoogleFonts.manropeTextTheme(
      base.textTheme,
    ).apply(bodyColor: t.ink, displayColor: t.ink),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: t.ink,
      selectionColor: t.accent.withValues(alpha: 0.35),
      selectionHandleColor: t.ink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.surface,
      border: b(t.lineStrong),
      enabledBorder: b(t.lineStrong),
      focusedBorder: b(t.ink, 1.6),
      errorBorder: b(error),
      focusedErrorBorder: b(error, 1.6),
      labelStyle: t.body(15, color: t.muted),
      floatingLabelStyle: t.body(14, weight: FontWeight.w600),
      hintStyle: t.body(15, color: t.muted.withValues(alpha: 0.7)),
      helperStyle: t.body(12.5, color: t.muted),
      errorStyle: t.body(12.5, color: error),
      suffixIconColor: t.muted,
      prefixIconColor: t.muted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: t.ink, width: 1.4),
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.ink : null,
      ),
      checkColor: WidgetStatePropertyAll(t.bg),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: t.ink,
      contentTextStyle: t.body(14, color: t.bg),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: t.bg,
      headerBackgroundColor: t.alt,
      headerForegroundColor: t.ink,
      surfaceTintColor: Colors.transparent,
    ),
    popupMenuTheme: PopupMenuThemeData(color: t.surface),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(t.surface)),
    ),
  );
}
