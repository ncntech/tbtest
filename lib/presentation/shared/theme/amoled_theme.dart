part of 'app_theme.dart';

ThemeData amoledTheme(ThemeColoration coloration) {
  return ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: const Color(0xFF000000),
    shadowColor: Colors.black,
    dividerColor: const Color(0xFF1A1A1A),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1A1A1A),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      background: const Color(0xFF000000),
      surface: const Color(0xFF0A0A0A),
      primary: coloration.primary,
      secondary: coloration.secondary,
      error: AppColors.lightRed,
      shadow: Colors.black,
      primaryContainer: const Color(0xFF111111),
      secondaryContainer: const Color(0xFF0D0D0D),
    ),
  );
}

ThemeData glassBluTheme(ThemeColoration coloration) {
  const bgColor = Color(0xFF0A0F1E);
  const surfaceColor = Color(0xFF111827);

  return ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: bgColor,
    shadowColor: const Color(0xFF00BFFF).withOpacity(0.15),
    dividerColor: const Color(0xFF1E2A40),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1E2A40),
    ),
    colorScheme: const ColorScheme.dark().copyWith(
      background: bgColor,
      surface: surfaceColor,
      primary: const Color(0xFF00BFFF),
      secondary: const Color(0xFF0080FF),
      error: AppColors.lightRed,
      shadow: const Color(0xFF00BFFF),
      primaryContainer: const Color(0xFF0D1829),
      secondaryContainer: const Color(0xFF0A1520),
    ),
  );
}
