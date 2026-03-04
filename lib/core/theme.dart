import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraTheme {
  // --- Premium Color Palette (deep space / neon aura vibe) ---
  static const Color backgroundPrimary = Color(0xFF1A1B2E);
  static const Color backgroundSecondary = Color(0xFF16213E);
  static const Color backgroundTertiary = Color(0xFF0F3460);
  static const Color backgroundModifierHover = Color(0xFF252644);
  static const Color backgroundModifierActive = Color(0xFF2E2F4A);
  static const Color backgroundInput = Color(0xFF0D0E23);
  static const Color backgroundCard = Color(0xFF1E1F35);

  // Text
  static const Color textNormal = Color(0xFFE0E0FF);
  static const Color textMuted = Color(0xFF8085A7);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Brand / accent
  static const Color brandColor = Color(0xFF7C5CBF);
  static const Color brandLight = Color(0xFF9B79E0);
  static const Color brandDark = Color(0xFF5A3E9E);
  static const Color accentCyan = Color(0xFF00D4FF);
  static const Color accentPink = Color(0xFFFF6B9D);

  // Status
  static const Color onlineColor = Color(0xFF23C55E);
  static const Color idleColor = Color(0xFFF59E0B);
  static const Color dndColor = Color(0xFFEF4444);
  static const Color dangerColor = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandDark, brandColor, brandLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1B2E), Color(0xFF12131F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient loginGradient = LinearGradient(
    colors: [Color(0xFF1A1B2E), Color(0xFF0F1020), Color(0xFF1A0E2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundPrimary,
      primaryColor: brandColor,
      colorScheme: const ColorScheme.dark(
        primary: brandColor,
        secondary: brandLight,
        surface: backgroundSecondary,
        error: dangerColor,
        onPrimary: Colors.white,
        onSurface: textNormal,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            bodyLarge: GoogleFonts.inter(color: textNormal, fontSize: 16),
            bodyMedium: GoogleFonts.inter(color: textNormal, fontSize: 14),
            bodySmall: GoogleFonts.inter(color: textMuted, fontSize: 12),
            labelLarge: GoogleFonts.inter(
              color: textNormal,
              fontWeight: FontWeight.w600,
            ),
            headlineMedium: GoogleFonts.inter(
              color: textWhite,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
            titleLarge: GoogleFonts.inter(
              color: textWhite,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundSecondary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: textNormal),
        titleTextStyle: GoogleFonts.inter(
          color: textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        shadowColor: Colors.black26,
      ),
      dividerTheme: const DividerThemeData(
        color: backgroundModifierActive,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: textMuted),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: brandColor, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          elevation: 0,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: backgroundCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundModifierActive,
        contentTextStyle: GoogleFonts.inter(color: textNormal),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
