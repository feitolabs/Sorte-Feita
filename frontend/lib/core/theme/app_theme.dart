import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.areia,
      colorScheme: const ColorScheme.light(
        primary: AppColors.petroleo,
        secondary: AppColors.azulRio,
        tertiary: AppColors.brasa,
        surface: AppColors.surfaceLight,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.bricolageGrotesque(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.petroleo,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.bricolageGrotesque(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.petroleo,
        ),
        displaySmall: GoogleFonts.bricolageGrotesque(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.petroleo,
        ),
        headlineMedium: GoogleFonts.bricolageGrotesque(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.petroleo,
        ),
        bodyLarge: GoogleFonts.hankenGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryLight,
        ),
        labelLarge: GoogleFonts.hankenGrotesk(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.areia,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.petroleo),
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.petroleo,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.nevoa, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.azulRio, width: 2),
        ),
        hintStyle: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.petroleo,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.azulRioClaro,
        secondary: AppColors.nevoaClaro,
        tertiary: AppColors.brasaClaro,
        surface: AppColors.surfaceDarkCard,
        error: Colors.redAccent,
        onPrimary: AppColors.petroleo,
        onSecondary: AppColors.petroleo,
        onSurface: AppColors.textPrimaryDark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.bricolageGrotesque(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.areia,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.bricolageGrotesque(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.areia,
        ),
        displaySmall: GoogleFonts.bricolageGrotesque(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.areia,
        ),
        headlineMedium: GoogleFonts.bricolageGrotesque(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.areia,
        ),
        bodyLarge: GoogleFonts.hankenGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondaryDark,
        ),
        labelLarge: GoogleFonts.hankenGrotesk(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.petroleo,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.petroleo,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.areia),
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.areia,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDarkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.azulRioClaro, width: 2),
        ),
        hintStyle: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          color: AppColors.nevoaClaro,
        ),
      ),
    );
  }
}
