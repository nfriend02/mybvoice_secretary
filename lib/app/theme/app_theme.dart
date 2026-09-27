import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Deep blue and neon purple secretary theme.
class AppTheme {
  static const Color onAccent = Color(0xFF07111F);
  static const Color deepBlue = Color(0xFF2563EB);
  static const Color neon = Color(0xFFC084FC);
  static const Color neonDeep = Color(0xFF7C3AED);
  static const Color coral = neon;
  static const Color peach = Color(0xFF93C5FD);
  static const Color mint = Color(0xFF67E8F9);
  static const Color lavender = Color(0xFFA78BFA);
  static const Color butter = Color(0xFF818CF8);
  static const Color sky = Color(0xFF60A5FA);
  static const Color lilac = neon;

  static bool dark = true;

  static Color get bg =>
      dark ? const Color(0xFF070B18) : const Color(0xFFF5F7FF);
  static Color get surface =>
      dark ? const Color(0xFF141A2E) : const Color(0xFFFFFFFF);
  static Color get ink =>
      dark ? const Color(0xFFF4F7FF) : const Color(0xFF241C3A);
  static Color get muted =>
      dark ? const Color(0xFFA9B4D0) : const Color(0xFF6E6884);
  static Color get border =>
      dark ? const Color(0x66C084FC) : const Color(0x337C3AED);
  static Color get sidebar =>
      dark ? const Color(0xCC0C1224) : const Color(0xF4FFFFFF);
  static Color get menuFill =>
      dark ? const Color(0xCC141A2E) : const Color(0xFFFFFFFF);

  static Color chipFill(bool selected) {
    if (dark) {
      return selected ? const Color(0xFF3A3268) : const Color(0xFF17142A);
    }
    return selected ? const Color(0xFFE4DCFF) : const Color(0xFFF7F4FF);
  }

  static Color chipBorder(bool selected) {
    if (selected) {
      return dark ? const Color(0xFFE8E4FF) : const Color(0xFF7C3AED);
    }
    return border;
  }

  static ThemeData themeData() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: neon,
        onPrimary: onAccent,
        secondary: deepBlue,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: ink,
        error: const Color(0xFFB00020),
        onError: Colors.white,
      ),
    );

    final text = GoogleFonts.notoSansKrTextTheme(base.textTheme)
        .apply(bodyColor: ink, displayColor: ink);

    return base.copyWith(
      textTheme: text,
      iconTheme: IconThemeData(color: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ink,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xCC12182B) : const Color(0xFFFFFFFF),
        hintStyle: TextStyle(color: muted),
        labelStyle: TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: neon, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: neon,
          foregroundColor: onAccent,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: GoogleFonts.notoSansKr(fontWeight: FontWeight.w800),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: dark ? neon : neonDeep),
      ),
    );
  }

  static BoxDecoration pageBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? const [Color(0xFF070B18), Color(0xFF16103A), Color(0xFF0A1C3A)]
            : const [Color(0xFFF7F4FF), Color(0xFFEEF3FF), Color(0xFFFFF6FB)],
      ),
    );
  }

  static BoxDecoration card({Color? tint}) {
    final glow = tint ?? neon;
    return BoxDecoration(
      color: dark ? const Color(0xC0141A2E) : const Color(0xF2FFFFFF),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: glow.withValues(alpha: dark ? 0.55 : 0.35)),
      boxShadow: [
        BoxShadow(
          color: glow.withValues(alpha: dark ? 0.16 : 0.12),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
