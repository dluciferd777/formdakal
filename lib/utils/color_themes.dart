// lib/utils/color_themes.dart - Kişiselleştirilebilir Tema Renkleri
import 'package:flutter/material.dart';

enum AppColorTheme {
  green,    // Varsayılan
  red,      // Kırmızı
  purple,   // Mor
  orange,   // Turuncu
  pink,     // Pembe
  yellow,   // Sarı
  blue,     // Mavi
  teal,     // Deniz mavisi
  black,    // Siyah - YENİ
}

class ColorThemes {
  // Tema renk paletleri
  static const Map<AppColorTheme, ColorPalette> _themes = {
    AppColorTheme.green: ColorPalette(
      primary: Color(0xFF4CAF50),
      light: Color(0xFF81C784),
      dark: Color(0xFF388E3C),
      name: 'Yeşil',
      icon: Icons.eco,
    ),
    AppColorTheme.red: ColorPalette(
      primary: Color(0xFFF44336),
      light: Color(0xFFEF5350),
      dark: Color(0xFFD32F2F),
      name: 'Kırmızı',
      icon: Icons.favorite,
    ),
    AppColorTheme.purple: ColorPalette(
      primary: Color(0xFF9C27B0),
      light: Color(0xFFBA68C8),
      dark: Color(0xFF7B1FA2),
      name: 'Mor',
      icon: Icons.palette,
    ),
    AppColorTheme.orange: ColorPalette(
      primary: Color(0xFFFF9800),
      light: Color(0xFFFFB74D),
      dark: Color(0xFFF57C00),
      name: 'Turuncu',
      icon: Icons.wb_sunny,
    ),
    AppColorTheme.pink: ColorPalette(
      primary: Color(0xFFE91E63),
      light: Color(0xFFF06292),
      dark: Color(0xFFC2185B),
      name: 'Pembe',
      icon: Icons.favorite_border,
    ),
    AppColorTheme.yellow: ColorPalette(
      primary: Color(0xFFFFEB3B),
      light: Color(0xFFFFF176),
      dark: Color(0xFFFBC02D),
      name: 'Sarı',
      icon: Icons.star,
    ),
    AppColorTheme.blue: ColorPalette(
      primary: Color(0xFF2196F3),
      light: Color(0xFF64B5F6),
      dark: Color(0xFF1976D2),
      name: 'Mavi',
      icon: Icons.water_drop,
    ),
    AppColorTheme.teal: ColorPalette(
      primary: Color(0xFF009688),
      light: Color(0xFF4DB6AC),
      dark: Color(0xFF00695C),
      name: 'Deniz Mavisi',
      icon: Icons.waves,
    ),
    AppColorTheme.black: ColorPalette(
      primary: Color(0xFF1C1C1C),
      light: Color(0xFF424242),
      dark: Color(0xFF000000),
      name: 'Siyah',
      icon: Icons.dark_mode,
    ),
  };

  // Aktif tema rengini al
  static ColorPalette getTheme(AppColorTheme theme) {
    return _themes[theme] ?? _themes[AppColorTheme.green]!;
  }

  // Tüm tema listesini al
  static List<AppColorTheme> get allThemes => AppColorTheme.values;

  // Tema adını al
  static String getThemeName(AppColorTheme theme) {
    return _themes[theme]?.name ?? 'Bilinmiyor';
  }

  // Tema ikonu al
  static IconData getThemeIcon(AppColorTheme theme) {
    return _themes[theme]?.icon ?? Icons.color_lens;
  }
}

class ColorPalette {
  final Color primary;
  final Color light;
  final Color dark;
  final String name;
  final IconData icon;

  const ColorPalette({
    required this.primary,
    required this.light,
    required this.dark,
    required this.name,
    required this.icon,
  });
}

// Dinamik renk sınıfı - Seçilen temaya göre renkler döndürür
class DynamicColors {
  static AppColorTheme _currentTheme = AppColorTheme.green;

  static void setTheme(AppColorTheme theme) {
    _currentTheme = theme;
  }

  static AppColorTheme get currentTheme => _currentTheme;

  // Ana renk
  static Color get primary => ColorThemes.getTheme(_currentTheme).primary;
  static Color get primaryLight => ColorThemes.getTheme(_currentTheme).light;
  static Color get primaryDark => ColorThemes.getTheme(_currentTheme).dark;

  // AppBar için özel renkler - TÜM SAYFALARDA KULLANILACAK
  static Color get appBarColor => _currentTheme == AppColorTheme.black 
      ? const Color(0xFF1C1C1C) // Siyah tema için koyu gri
      : primary;
  static Color get appBarTextColor => Colors.white;

  // Floating Action Button
  static Color get fabColor => primary;
  static Color get fabTextColor => Colors.white;

  // Progress Ring renkleri (seçilen tema bazında)
  static Color get ringPrimary => primary;
  static Color get ringSecondary => primaryLight;
  static Color get ringAccent => primaryDark;

  // Buton renkleri
  static Color get buttonPrimary => primary;
  static Color get buttonText => Colors.white;

  // Başlık harfleri için özel renkler
  static Color get titleAccentColor => primary; // F ve K harfleri için

  // DARK TEMA - Sabit renkler (değişmez)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1C1C1C);
  static const Color darkCardBorder = Color(0xFF2C2C2C);
  
  // LIGHT TEMA - Sabit renkler (değişmez)
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8F9FA);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardShadowColor = Color(0xFFE5E7EB);
  static const Color lightCardBorderColor = Color(0xFFF1F3F4);
  
  // Metin Renkleri - Sabit
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  
  // Durum Renkleri - Sabit
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Gölge Renkleri - Sabit
  static const Color shadowLight = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x4D000000);
  static const Color shadowVeryLight = Color(0x08000000);
  
  // Kart gölge definisyonları
  static List<BoxShadow> get lightCardShadow => [
    BoxShadow(
      color: shadowLight,
      offset: const Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: shadowVeryLight,
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(
      color: const Color(0xFF000000).withOpacity(0.3),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}