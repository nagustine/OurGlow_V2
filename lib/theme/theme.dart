import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF8B1538);
  static const Color accent = Color(0xFFE8B84B);
  static const Color background = Color(0xFFFDEDEC);
  static const Color sectionBg = Color(0xFFFBD9D3);
  static const Color cream = Color(0xFFFFF6EF);
  static const Color textDark = Color(0xFF2A2A2A);
  static const Color statusSafe = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFE8B84B);
  static const Color statusDanger = Color(0xFFC62828);
  static const Color neutral = Color(0xFFBDBDBD);
  static const Color neutralBg = Color(0xFFEEEEEE);
}

class SkinCondition {
  final String key;
  final String label;
  final Color color;
  final String emoji;

  const SkinCondition({
    required this.key,
    required this.label,
    required this.color,
    required this.emoji,
  });
}

class SkinConditionStyles {
  SkinConditionStyles._();

  static const SkinCondition glowing = SkinCondition(
    key: 'glowing',
    label: 'Glowing / Sehat',
    color: Color(0xFFE8B84B),
    emoji: '✨',
  );
  static const SkinCondition normal = SkinCondition(
    key: 'normal',
    label: 'Normal',
    color: Color(0xFFFBD9D3),
    emoji: '🙂',
  );
  static const SkinCondition oily = SkinCondition(
    key: 'berminyak',
    label: 'Berminyak',
    color: Color(0xFFF5C99B),
    emoji: '😅',
  );
  static const SkinCondition dry = SkinCondition(
    key: 'kering',
    label: 'Kering',
    color: Color(0xFFBFD9EC),
    emoji: '🥺',
  );
  static const SkinCondition acne = SkinCondition(
    key: 'berjerawat',
    label: 'Berjerawat / Breakout',
    color: Color(0xFFE89AA6),
    emoji: '😣',
  );
  static const SkinCondition irritation = SkinCondition(
    key: 'iritasi',
    label: 'Iritasi / Kemerahan',
    color: Color(0xFFC62828),
    emoji: '🔴',
  );

  static const SkinCondition fallback = SkinCondition(
    key: 'unknown',
    label: 'Tidak Diketahui',
    color: Color(0xFFEEEEEE),
    emoji: '❔',
  );

  static const List<SkinCondition> all = [
    glowing,
    normal,
    oily,
    dry,
    acne,
    irritation,
  ];

  static SkinCondition byKey(String? key) {
    if (key == null || key.isEmpty) return fallback;
    final k = key.toLowerCase().trim();

    for (final c in all) {
      if (c.key == k) return c;
    }

    if (k.contains('acne') || k.contains('jerawat')) return acne;
    if (k.contains('oil') || k.contains('minyak')) return oily;
    if (k.contains('dry') || k.contains('kering')) return dry;
    if (k.contains('irit') || k.contains('red') || k.contains('kemerah')) {
      return irritation;
    }
    if (k.contains('glow') || k.contains('sehat')) return glowing;
    if (k.contains('normal')) return normal;

    return fallback;
  }
}

class AppRadius {
  AppRadius._();
  static const double card = 20;
  static const double small = 16;
  static const double pill = 24;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppText {
  AppText._();

  static TextStyle heroTitle = GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
    height: 1.1,
  );

  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.45,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.4,
  );

  static TextStyle buttonLabel = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static TextStyle badge = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark.withValues(alpha: 0.7),
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.cream,
        error: AppColors.statusDanger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          textStyle: AppText.buttonLabel,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        hintStyle: AppText.body.copyWith(
          color: AppColors.textDark.withValues(alpha: 0.4),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cream,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.primary.withValues(alpha: 0.1),
        thickness: 1,
      ),
      splashColor: AppColors.accent.withValues(alpha: 0.15),
      highlightColor: AppColors.accent.withValues(alpha: 0.08),
    );
  }
}

class AppAssets {
  AppAssets._();

  static const String banner = 'assets/images/banner.png';
  static const String diary = 'assets/images/diary.png';
  static const String girlScan = 'assets/images/girl_scan.png';
  static const String kameraScan = 'assets/images/kamera_scan.png';
  static const String loveEmoji = 'assets/images/love_emoji.png';
  static const String logo = 'assets/images/our_glow.png';
  static const String patternSparkle = 'assets/images/pattern_sparkle.png';
  static const String routine = 'assets/images/routine.png';
  static const String scanEmoji = 'assets/images/scan_emoji.png';
  static const String warningEmoji = 'assets/images/warning_emoji.png';

  static const String produkCleanser = 'assets/images/produk_cleanser.png';
  static const String produkMoisturizer = 'assets/images/produk_moisturizer.png';
  static const String produkRetinol = 'assets/images/produk_retinol.png';
  static const String produkSerumVitC = 'assets/images/produk_serum_vitc.png';
  static const String produkSunscreen = 'assets/images/produk_sunscreen.png';
  static const String produkTonerBha = 'assets/images/produk_toner_bha.png';
}