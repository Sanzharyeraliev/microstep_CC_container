import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System "The Quiet Pulse" - The Digital Breath
/// Цветовая палитра и токены из DESIGN.md

class AppColors {
  AppColors._();

  // Основные цвета
  static const Color background = Color(0xFFF9F9FB);
  static const Color surface = Color(0xFFF9F9FB);
  static const Color surfaceDim = Color(0xFFD3DBE2);
  static const Color surfaceBright = Color(0xFFF9F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFEBEEF2);
  static const Color surfaceContainerHigh = Color(0xFFE4E9EE);
  static const Color surfaceContainerHighest = Color(0xFFDDE3E9);
  static const Color surfaceVariant = Color(0xFFDDE3E9);
  static const Color inverseSurface = Color(0xFF0C0E10);

  // Primary (Success/Progress)
  static const Color primary = Color(0xFF006D42);
  static const Color primaryDim = Color(0xFF005F39);
  static const Color primaryContainer = Color(0xFF93F7BC);
  static const Color primaryFixed = Color(0xFF93F7BC);
  static const Color primaryFixedDim = Color(0xFF85E8AE);
  static const Color onPrimary = Color(0xFFE2FFE9);
  static const Color onPrimaryContainer = Color(0xFF005E39);
  static const Color onPrimaryFixed = Color(0xFF00492B);
  static const Color onPrimaryFixedVariant = Color(0xFF006940);
  static const Color inversePrimary = Color(0xFF99FDC1);

  // Emerald variants (Tailwind mapping for active states)
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald900 = Color(0xFF064E3B);

  // Slate variants (Tailwind mapping)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // Secondary
  static const Color secondary = Color(0xFF5F5F5F);
  static const Color secondaryContainer = Color(0xFFE4E2E2);
  static const Color secondaryFixed = Color(0xFFE4E2E2);
  static const Color secondaryFixedDim = Color(0xFFD5D4D4);
  static const Color secondaryDim = Color(0xFF535353);
  static const Color onSecondary = Color(0xFFFAF8F8);
  static const Color onSecondaryContainer = Color(0xFF515252);
  static const Color onSecondaryFixed = Color(0xFF3F3F3F);
  static const Color onSecondaryFixedVariant = Color(0xFF5B5B5B);

  // Tertiary
  static const Color tertiary = Color(0xFF466658);
  static const Color tertiaryContainer = Color(0xFFD8FCEA);
  static const Color tertiaryFixed = Color(0xFFD8FCEA);
  static const Color tertiaryFixedDim = Color(0xFFCAEDDC);
  static const Color tertiaryDim = Color(0xFF3A594C);
  static const Color onTertiary = Color(0xFFE5FFF1);
  static const Color onTertiaryContainer = Color(0xFF436255);
  static const Color onTertiaryFixed = Color(0xFF315043);
  static const Color onTertiaryFixedVariant = Color(0xFF4D6D5F);

  // Text & Icons
  static const Color onBackground = Color(0xFF2D3338);
  static const Color onSurface = Color(0xFF2D3338);
  static const Color onSurfaceVariant = Color(0xFF596065);
  static const Color outline = Color(0xFF757C81);
  static const Color outlineVariant = Color(0xFFACB3B8);

  // Error
  static const Color error = Color(0xFF9F403D);
  static const Color errorContainer = Color(0xFFFE8983);
  static const Color errorDim = Color(0xFF4E0309);
  static const Color onError = Color(0xFFFFF7F6);
  static const Color onErrorContainer = Color(0xFF752121);
  static const Color inverseOnSurface = Color(0xFF9C9D9F);
}

/// Градиент для основных кнопок (Signature Gradient)
LinearGradient signatureGradient = const LinearGradient(
  colors: [AppColors.primary, AppColors.primaryFixedDim],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Амбиентная тень (Ambient Shadows)
BoxShadow ambientShadow = BoxShadow(
  color: AppColors.onSurface.withAlpha(13),
  blurRadius: 24,
  offset: const Offset(0, 4),
);

class AppTextTheme {
  AppTextTheme._();

  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme()
        .copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 56,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.25,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 45,
            fontWeight: FontWeight.w400,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 36,
            fontWeight: FontWeight.w400,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
            height: 1.5,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
            height: 1.6,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        )
        .apply(
          fontFamilyFallback: const [
            'sans-serif',
            'system-ui',
            '-apple-system',
          ],
        );
  }
}

/// Расширения для радиусов (согласно HTML дизайну)
class AppRadius {
  AppRadius._();

  // Base radius matching Tailwind config
  static const double defaultRadius = 16.0; // 1rem
  static const double lg = 32.0; // 2rem
  static const double xl = 48.0; // 3rem
  static const double full = 9999.0;

  // Existing compatibility layer
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double huge = 40;
  static const double massive = 48;
}

/// Отступы (Spacing) - соответствует Tailwind конфигурации
/// Основная шкала: xxs=4 (space-1), xs=8 (space-2), sm=12 (space-3), md=16 (space-4),
/// lg=20 (space-5), xl=24 (space-6), xxl=28 (space-7), xxxl=32 (space-8),
/// huge=40 (space-10), massive=48 (space-12)
class AppSpacing {
  AppSpacing._();

  // Core spacing scale (preserving original mapping for compatibility)
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;

  // Additional precise values from new design
  static const double profileAvatar = 64.0; // w-16 h-16
  static const double iconCircle = 48.0; // w-12 h-12
  static const double badgeSize = 40.0; // w-10 h-10
}
