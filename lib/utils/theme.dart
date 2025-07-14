// lib/utils/theme.dart - Dinamik Tema Sistemi
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_themes.dart';

class AppTheme {
  static final _baseTextTheme = ThemeData.dark().textTheme;

  // Dinamik Light Theme
  static ThemeData lightTheme(AppColorTheme colorTheme) {
    final palette = ColorThemes.getTheme(colorTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: palette.primary,
      scaffoldBackgroundColor: DynamicColors.lightSurface,
      
      // Renk scheme'i
      colorScheme: ColorScheme.light(
        primary: palette.primary,
        primaryContainer: palette.light,
        secondary: palette.dark,
        surface: DynamicColors.lightBackground,
        background: DynamicColors.lightSurface,
        onPrimary: Colors.white,
        onSurface: DynamicColors.textDark,
      ),
      
      // AppBar Teması
      appBarTheme: AppBarTheme(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: palette.primary,
        elevation: 2,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: _baseTextTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      
      // Kart Teması
      cardTheme: CardThemeData(
        color: DynamicColors.lightCard,
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      
      // Metin Teması
      textTheme: _baseTextTheme.copyWith(
        displayLarge: _baseTextTheme.displayLarge?.copyWith(color: DynamicColors.textDark),
        displayMedium: _baseTextTheme.displayMedium?.copyWith(color: DynamicColors.textDark),
        displaySmall: _baseTextTheme.displaySmall?.copyWith(color: DynamicColors.textDark),
        headlineLarge: _baseTextTheme.headlineLarge?.copyWith(color: DynamicColors.textDark),
        headlineMedium: _baseTextTheme.headlineMedium?.copyWith(color: DynamicColors.textDark),
        headlineSmall: _baseTextTheme.headlineSmall?.copyWith(color: DynamicColors.textDark),
        titleLarge: _baseTextTheme.titleLarge?.copyWith(color: DynamicColors.textDark),
        titleMedium: _baseTextTheme.titleMedium?.copyWith(color: DynamicColors.textDark),
        titleSmall: _baseTextTheme.titleSmall?.copyWith(color: DynamicColors.textDark),
        bodyLarge: _baseTextTheme.bodyLarge?.copyWith(color: DynamicColors.textDark),
        bodyMedium: _baseTextTheme.bodyMedium?.copyWith(color: DynamicColors.textDark),
        bodySmall: _baseTextTheme.bodySmall?.copyWith(color: DynamicColors.textGray),
        labelLarge: _baseTextTheme.labelLarge?.copyWith(color: Colors.white),
      ),
      
      // İkon Teması
      iconTheme: const IconThemeData(color: DynamicColors.textDark),
      
      // Buton Temaları
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      // FloatingActionButton Teması
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
      ),
      
      // Progress Indicator Teması
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
      ),
      
      // Switch ve Checkbox Temaları
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return palette.primary;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return palette.light;
          }
          return null;
        }),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return palette.primary;
          }
          return null;
        }),
      ),
      
      // Tab Bar Teması
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        unselectedLabelColor: DynamicColors.textGray,
        indicatorColor: palette.primary,
      ),
    );
  }

  // Dinamik Dark Theme
  static ThemeData darkTheme(AppColorTheme colorTheme) {
    final palette = ColorThemes.getTheme(colorTheme);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: palette.primary,
      scaffoldBackgroundColor: DynamicColors.darkBackground,
      
      // Renk scheme'i
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        primaryContainer: palette.dark,
        secondary: palette.light,
        surface: DynamicColors.darkSurface,
        background: DynamicColors.darkBackground,
        onPrimary: Colors.white,
        onSurface: DynamicColors.textPrimary,
      ),
      
      // AppBar Teması
      appBarTheme: AppBarTheme(
        backgroundColor: DynamicColors.darkSurface,
        foregroundColor: Colors.white,
        surfaceTintColor: DynamicColors.darkSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: _baseTextTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      
      // Kart Teması
      cardTheme: CardThemeData(
        color: DynamicColors.darkCard,
        elevation: 4,
        shadowColor: DynamicColors.shadowDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      
      // Metin Teması
      textTheme: _baseTextTheme.copyWith(
        displayLarge: _baseTextTheme.displayLarge?.copyWith(color: DynamicColors.textPrimary),
        displayMedium: _baseTextTheme.displayMedium?.copyWith(color: DynamicColors.textPrimary),
        displaySmall: _baseTextTheme.displaySmall?.copyWith(color: DynamicColors.textPrimary),
        headlineLarge: _baseTextTheme.headlineLarge?.copyWith(color: DynamicColors.textPrimary),
        headlineMedium: _baseTextTheme.headlineMedium?.copyWith(color: DynamicColors.textPrimary),
        headlineSmall: _baseTextTheme.headlineSmall?.copyWith(color: DynamicColors.textPrimary),
        titleLarge: _baseTextTheme.titleLarge?.copyWith(color: DynamicColors.textPrimary),
        titleMedium: _baseTextTheme.titleMedium?.copyWith(color: DynamicColors.textPrimary),
        titleSmall: _baseTextTheme.titleSmall?.copyWith(color: DynamicColors.textPrimary),
        bodyLarge: _baseTextTheme.bodyLarge?.copyWith(color: DynamicColors.textPrimary),
        bodyMedium: _baseTextTheme.bodyMedium?.copyWith(color: DynamicColors.textPrimary),
        bodySmall: _baseTextTheme.bodySmall?.copyWith(color: DynamicColors.textSecondary),
        labelLarge: _baseTextTheme.labelLarge?.copyWith(color: Colors.white),
      ),
      
      // İkon Teması
      iconTheme: const IconThemeData(color: DynamicColors.textPrimary),
      
      // Buton Temaları
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      // FloatingActionButton Teması
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: Colors.white,
      ),
      
      // Progress Indicator Teması
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
      ),
      
      // Switch ve Checkbox Temaları
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return palette.primary;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return palette.light;
          }
          return null;
        }),
      ),
      
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return palette.primary;
          }
          return null;
        }),
      ),
      
      // Tab Bar Teması
      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        unselectedLabelColor: DynamicColors.textSecondary,
        indicatorColor: palette.primary,
      ),
    );
  }

  // ÖZEL APPBAR WIDGET - TÜM SAYFALARDA KULLANILABİLİR
  static AppBar buildAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    PreferredSizeWidget? bottom,
    AppColorTheme? customColorTheme,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorTheme = customColorTheme ?? DynamicColors.currentTheme;
    final palette = ColorThemes.getTheme(colorTheme);
    
    return AppBar(
      title: Text(title),
      backgroundColor: isDarkMode ? DynamicColors.darkSurface : palette.primary,
      foregroundColor: Colors.white,
      elevation: isDarkMode ? 0 : 2,
      centerTitle: true,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }
}