import 'package:flutter/material.dart';

/// Colors with a chemical meaning, used consistently across the app:
/// ¹H data in one color, ¹³C data in another.
@immutable
class NmrColors extends ThemeExtension<NmrColors> {
  const NmrColors({
    required this.proton,
    required this.carbon,
    required this.residual,
  });

  final Color proton;
  final Color carbon;
  final Color residual;

  static NmrColors of(BuildContext context) =>
      Theme.of(context).extension<NmrColors>()!;

  @override
  NmrColors copyWith({Color? proton, Color? carbon, Color? residual}) =>
      NmrColors(
        proton: proton ?? this.proton,
        carbon: carbon ?? this.carbon,
        residual: residual ?? this.residual,
      );

  @override
  NmrColors lerp(NmrColors? other, double t) {
    if (other == null) return this;
    return NmrColors(
      proton: Color.lerp(proton, other.proton, t)!,
      carbon: Color.lerp(carbon, other.carbon, t)!,
      residual: Color.lerp(residual, other.residual, t)!,
    );
  }
}

/// A selectable color theme. Each palette has a light and a dark variant,
/// except [darkOnly] palettes which always render dark.
class AppPalette {
  const AppPalette({
    required this.id,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.protonLight,
    required this.protonDark,
    required this.carbonLight,
    required this.carbonDark,
    this.surfaceLight = const Color(0xFFFFFFFF),
    this.surfaceDark = const Color(0xFF121212),
    this.darkOnly = false,
  });

  final String id;
  final Color primaryLight, primaryDark;
  final Color secondaryLight, secondaryDark;
  final Color protonLight, protonDark;
  final Color carbonLight, carbonDark;
  final Color surfaceLight, surfaceDark;
  final bool darkOnly;
}

const _red = Color(0xFFC62828);
const _redDark = Color(0xFFEF5350);
const _blue = Color(0xFF1565C0);
const _blueDark = Color(0xFF64B5F6);

/// All themes the user can choose from. The first one is the default.
const appPalettes = <AppPalette>[
  // Red / blue / black — the app's signature look.
  AppPalette(
    id: 'classic',
    primaryLight: _blue,
    primaryDark: _blueDark,
    secondaryLight: _red,
    secondaryDark: _redDark,
    protonLight: _blue,
    protonDark: _blueDark,
    carbonLight: _red,
    carbonDark: _redDark,
  ),
  // Pure black background with red and blue accents.
  AppPalette(
    id: 'midnight',
    primaryLight: _redDark,
    primaryDark: _redDark,
    secondaryLight: _blueDark,
    secondaryDark: _blueDark,
    protonLight: _blueDark,
    protonDark: _blueDark,
    carbonLight: _redDark,
    carbonDark: _redDark,
    surfaceDark: Color(0xFF000000),
    darkOnly: true,
  ),
  // Red-led variant.
  AppPalette(
    id: 'crimson',
    primaryLight: _red,
    primaryDark: _redDark,
    secondaryLight: _blue,
    secondaryDark: _blueDark,
    protonLight: _blue,
    protonDark: _blueDark,
    carbonLight: _red,
    carbonDark: _redDark,
  ),
  AppPalette(
    id: 'ocean',
    primaryLight: Color(0xFF00838F),
    primaryDark: Color(0xFF4DD0E1),
    secondaryLight: Color(0xFF283593),
    secondaryDark: Color(0xFF9FA8DA),
    protonLight: Color(0xFF00838F),
    protonDark: Color(0xFF4DD0E1),
    carbonLight: Color(0xFFD84315),
    carbonDark: Color(0xFFFF8A65),
  ),
  AppPalette(
    id: 'emerald',
    primaryLight: Color(0xFF2E7D32),
    primaryDark: Color(0xFF81C784),
    secondaryLight: Color(0xFF6A1B9A),
    secondaryDark: Color(0xFFCE93D8),
    protonLight: Color(0xFF2E7D32),
    protonDark: Color(0xFF81C784),
    carbonLight: Color(0xFF6A1B9A),
    carbonDark: Color(0xFFCE93D8),
  ),
  // Mostly black and grey, red only as accent.
  AppPalette(
    id: 'graphite',
    primaryLight: Color(0xFF212121),
    primaryDark: Color(0xFFE0E0E0),
    secondaryLight: _red,
    secondaryDark: _redDark,
    protonLight: Color(0xFF424242),
    protonDark: Color(0xFFBDBDBD),
    carbonLight: _red,
    carbonDark: _redDark,
  ),
];

AppPalette paletteById(String id) =>
    appPalettes.firstWhere((p) => p.id == id, orElse: () => appPalettes.first);

ThemeData buildTheme(AppPalette palette, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final primary = dark ? palette.primaryDark : palette.primaryLight;
  final secondary = dark ? palette.secondaryDark : palette.secondaryLight;
  final surface = dark ? palette.surfaceDark : palette.surfaceLight;
  final onSurface = dark ? const Color(0xFFEDEDED) : const Color(0xFF111111);

  final scheme =
      ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      ).copyWith(
        primary: primary,
        onPrimary: _onColor(primary),
        secondary: secondary,
        onSecondary: _onColor(secondary),
        surface: surface,
        onSurface: onSurface,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? surface : const Color(0xFF111111),
      foregroundColor: dark ? onSurface : Colors.white,
      centerTitle: false,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: primary.withValues(alpha: 0.18),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      isDense: true,
    ),
    extensions: [
      NmrColors(
        proton: dark ? palette.protonDark : palette.protonLight,
        carbon: dark ? palette.carbonDark : palette.carbonLight,
        residual: secondary,
      ),
    ],
  );
}

Color _onColor(Color c) =>
    ThemeData.estimateBrightnessForColor(c) == Brightness.dark
    ? Colors.white
    : Colors.black;
