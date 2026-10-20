import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colori fissi del gestionale: toni caldi e chiari, sempre uguali anche
/// quando il sito pubblico cambia tema.
class Palette {
  static const ink = Color(0xFF2B2119);
  static const paper = Color(0xFFF7F2EA);
  static const ivory = Color(0xFFFFFDF8);
  static const linen = Color(0xFFEFE7DB);
  static const stone = Color(0xFF6B5A4B); // testo secondario
  static const ash = Color(0xFF958676); // etichette
  static const line = Color(0x242B2119);
  static const lineStrong = Color(0x592B2119);
  static const error = Color(0xFFB3261E);
}

extension AccentX on BuildContext {
  /// Colore del brand (l'accento del tema predefinito del sito).
  Color get brand => Theme.of(this).colorScheme.tertiary;
}

/// Titoli del gestionale.
TextStyle display(
  double size, {
  Color color = Palette.ink,
  bool italic = false,
  FontWeight weight = FontWeight.w500,
  double height = 1.1,
}) => GoogleFonts.cormorantGaramond(
  fontSize: size,
  fontWeight: weight,
  color: color,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  height: height,
);

/// Etichette maiuscole spaziate.
TextStyle label(
  double size, {
  Color color = Palette.ink,
  FontWeight weight = FontWeight.w600,
  double spacing = 0.2,
}) => GoogleFonts.manrope(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: 1.3,
  letterSpacing: size * spacing,
);

/// Testo corrente.
TextStyle body(
  double size, {
  Color color = Palette.ink,
  FontWeight weight = FontWeight.w400,
  double height = 1.6,
}) => GoogleFonts.manrope(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

class AppTheme {
  /// Tema chiaro e "gestionale" per l'area riservata.
  static ThemeData admin(Color accent) {
    const strong = Palette.ink;
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: strong,
        onPrimary: Palette.paper,
        secondary: accent,
        tertiary: accent,
        onTertiary: Colors.white,
        secondaryContainer: strong,
        onSecondaryContainer: Palette.paper,
        surface: Colors.white,
        onSurface: Palette.ink,
      ),
      scaffoldBackgroundColor: Palette.paper,
    );
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide(color: c, width: w),
    );
    return base.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(base.textTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: b(const Color(0xFFD9D0C3)),
        enabledBorder: b(const Color(0xFFD9D0C3)),
        focusedBorder: b(strong, 1.4),
        errorBorder: b(Palette.error),
        focusedErrorBorder: b(Palette.error, 1.4),
        labelStyle: GoogleFonts.manrope(color: const Color(0xFF6E6257)),
        floatingLabelStyle: GoogleFonts.manrope(color: strong),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFD9D0C3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE6DDD0)),
        ),
      ),
      dividerColor: const Color(0xFFE6DDD0),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Larghezza "di progetto" oltre la quale l'intero sito viene ingrandito
/// in proporzione (TV e monitor molto grandi): vedi [ScreenScale].
const designMaxWidth = 1600.0;

/// Breakpoint e misure fluide.
extension Responsive on BuildContext {
  double get w => MediaQuery.sizeOf(this).width;
  double get h => MediaQuery.sizeOf(this).height;
  bool get isPhone => w < 600;
  bool get isMobile => w < 720;
  bool get isTablet => w < 1024;

  /// Valore che cresce linearmente con la larghezza tra telefono (360) e
  /// desktop ampio (1600).
  double fluid(double min, double max) {
    final t = ((w - 360) / (designMaxWidth - 360)).clamp(0.0, 1.0);
    return min + (max - min) * t;
  }

  /// Margine laterale delle sezioni.
  double get gutter => fluid(20, 80);

  /// Altezza della barra di navigazione.
  double get navH => fluid(70, 96);

  /// Altezza utile per sezioni "a schermo intero" (mai troppo bassa né
  /// troppo alta, anche su telefoni in orizzontale).
  double get screenH => math.max(h, w < 600 ? 560 : 620);
}

/// Sui display più larghi di [designMaxWidth] (TV, monitor 4K) ingrandisce
/// tutto il sito in modo uniforme, così le proporzioni restano quelle
/// progettate invece di lasciare enormi spazi vuoti.
class ScreenScale extends StatelessWidget {
  const ScreenScale({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    if (width <= designMaxWidth + 120) return child;
    final s = (width / designMaxWidth).clamp(1.0, 3.0);
    final logical = Size(width / s, mq.size.height / s);
    return MediaQuery(
      data: mq.copyWith(
        size: logical,
        padding: mq.padding / s,
        viewPadding: mq.viewPadding / s,
        viewInsets: mq.viewInsets / s,
      ),
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: logical.width,
          height: logical.height,
          child: child,
        ),
      ),
    );
  }
}
