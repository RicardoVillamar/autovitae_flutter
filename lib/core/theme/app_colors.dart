import 'package:flutter/material.dart';

/// Light [ColorScheme]
const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFBB1614),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFDAD5),
  onPrimaryContainer: Color(0xFF000000),
  primaryFixed: Color(0xFFF7C6C5),
  primaryFixedDim: Color(0xFFE99796),
  onPrimaryFixed: Color(0xFF450808),
  onPrimaryFixedVariant: Color(0xFF550A09),
  secondary: Color(0xFF96482B),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFDBCF),
  onSecondaryContainer: Color(0xFF000000),
  secondaryFixed: Color(0xFFEDD5CC),
  secondaryFixedDim: Color(0xFFD8B0A2),
  onSecondaryFixed: Color(0xFF35190F),
  onSecondaryFixedVariant: Color(0xFF432013),
  tertiary: Color(0xFF286294),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFD0E4FF),
  onTertiaryContainer: Color(0xFF000000),
  tertiaryFixed: Color(0xFFCCDDED),
  tertiaryFixedDim: Color(0xFFA1BFD8),
  onTertiaryFixed: Color(0xFF0D2132),
  onTertiaryFixedVariant: Color(0xFF112B40),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFCFCFC),
  onSurface: Color(0xFF111111),
  surfaceDim: Color(0xFFE0E0E0),
  surfaceBright: Color(0xFFFDFDFD),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF8F8F8),
  surfaceContainer: Color(0xFFF3F3F3),
  surfaceContainerHigh: Color(0xFFEDEDED),
  surfaceContainerHighest: Color(0xFFE7E7E7),
  onSurfaceVariant: Color(0xFF393939),
  outline: Color(0xFF919191),
  outlineVariant: Color(0xFFD1D1D1),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2A2A2A),
  onInverseSurface: Color(0xFFF1F1F1),
  inversePrimary: Color(0xFFFFAEAD),
  surfaceTint: Color(0xFFBB1614),
);

/// Dark [ColorScheme]
const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFDED9),
  onPrimary: Color(0xFF000000),
  primaryContainer: Color(0xFFC22D2C),
  onPrimaryContainer: Color(0xFFFFFFFF),
  primaryFixed: Color(0xFFF7C6C5),
  primaryFixedDim: Color(0xFFE99796),
  onPrimaryFixed: Color(0xFF450808),
  onPrimaryFixedVariant: Color(0xFF550A09),
  secondary: Color(0xFFFFDFD4),
  onSecondary: Color(0xFF000000),
  secondaryContainer: Color(0xFFA15A40),
  onSecondaryContainer: Color(0xFFFFFFFF),
  secondaryFixed: Color(0xFFEDD5CC),
  secondaryFixedDim: Color(0xFFD8B0A2),
  onSecondaryFixed: Color(0xFF35190F),
  onSecondaryFixedVariant: Color(0xFF432013),
  tertiary: Color(0xFFD5E7FF),
  onTertiary: Color(0xFF000000),
  tertiaryContainer: Color(0xFF3E729F),
  onTertiaryContainer: Color(0xFFFFFFFF),
  tertiaryFixed: Color(0xFFCCDDED),
  tertiaryFixedDim: Color(0xFFA1BFD8),
  onTertiaryFixed: Color(0xFF0D2132),
  onTertiaryFixedVariant: Color(0xFF112B40),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF080808),
  onSurface: Color(0xFFF1F1F1),
  surfaceDim: Color(0xFF060606),
  surfaceBright: Color(0xFF2C2C2C),
  surfaceContainerLowest: Color(0xFF010101),
  surfaceContainerLow: Color(0xFF0E0E0E),
  surfaceContainer: Color(0xFF151515),
  surfaceContainerHigh: Color(0xFF1D1D1D),
  surfaceContainerHighest: Color(0xFF282828),
  onSurfaceVariant: Color(0xFFCACACA),
  outline: Color(0xFF777777),
  outlineVariant: Color(0xFF414141),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE8E8E8),
  onInverseSurface: Color(0xFF2A2A2A),
  inversePrimary: Color(0xFF6B6361),
  surfaceTint: Color(0xFFFFDED9),
);

/// Colores estáticos para uso directo
class AppColors {
  // Colores que no cambian con el tema
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF808080);
}

/// Extension para acceder a colores del tema fácilmente
extension AppColorsExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Colores primarios
  Color get primaryColor => colorScheme.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;
  Color get primaryContainer => colorScheme.primaryContainer;

  // Colores secundarios
  Color get secondaryColor => colorScheme.secondary;
  Color get onSecondaryColor => colorScheme.onSecondary;
  Color get secondaryContainer => colorScheme.secondaryContainer;

  // Colores terciarios
  Color get tertiaryColor => colorScheme.tertiary;
  Color get onTertiaryColor => colorScheme.onTertiary;
  Color get tertiaryContainer => colorScheme.tertiaryContainer;

  // Superficies
  Color get backgroundColor => colorScheme.surface;
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get surfaceContainerColor => colorScheme.surfaceContainer;
  Color get surfaceContainerHighColor => colorScheme.surfaceContainerHigh;

  // Errores
  Color get errorColor => colorScheme.error;
  Color get onErrorColor => colorScheme.onError;

  // Bordes y variantes
  Color get outlineColor => colorScheme.outline;
  Color get outlineVariantColor => colorScheme.outlineVariant;

  // Texto
  Color get textColor => colorScheme.onSurface;
  Color get textSecondaryColor => colorScheme.onSurfaceVariant;

  // Utilidades
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
