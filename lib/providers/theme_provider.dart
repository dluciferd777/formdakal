// lib/providers/theme_provider.dart - Kişiselleştirilebilir Tema Provider
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/color_themes.dart';

class ThemeProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  AppColorTheme _colorTheme = AppColorTheme.green;
  
  ThemeProvider(this._prefs) {
    _loadTheme();
    _loadColorTheme();
  }
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  AppColorTheme get colorTheme => _colorTheme;
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  // Aktif renk paletini al
  ColorPalette get currentColorPalette => ColorThemes.getTheme(_colorTheme);
  
  // Theme Mode işlemleri
  void _loadTheme() {
    final themeString = _prefs.getString('theme_mode') ?? 'system';
    
    switch (themeString) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    
    notifyListeners();
  }
  
  void toggleTheme() {
    // Basit geçiş: sadece light ve dark arasında
    switch (_themeMode) {
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.system:
        // Sistem modundaysa, mevcut sistem durumuna göre tersini seç
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        if (brightness == Brightness.dark) {
          _themeMode = ThemeMode.light; // Sistem koyu ise açık yap
        } else {
          _themeMode = ThemeMode.dark; // Sistem açık ise koyu yap
        }
        break;
    }
    
    _saveTheme();
    notifyListeners();
  }
  
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    _saveTheme();
    notifyListeners();
  }
  
  void _saveTheme() {
    String themeString;
    switch (_themeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    
    _prefs.setString('theme_mode', themeString);
  }
  
  // Color Theme işlemleri
  void _loadColorTheme() {
    final colorThemeString = _prefs.getString('color_theme') ?? 'green';
    
    try {
      _colorTheme = AppColorTheme.values.firstWhere(
        (theme) => theme.toString().split('.').last == colorThemeString,
        orElse: () => AppColorTheme.green,
      );
    } catch (e) {
      _colorTheme = AppColorTheme.green;
    }
    
    // DynamicColors sınıfını güncelle
    DynamicColors.setTheme(_colorTheme);
    notifyListeners();
  }
  
  void setColorTheme(AppColorTheme colorTheme) {
    _colorTheme = colorTheme;
    DynamicColors.setTheme(_colorTheme);
    _saveColorTheme();
    notifyListeners();
  }
  
  void _saveColorTheme() {
    final colorThemeString = _colorTheme.toString().split('.').last;
    _prefs.setString('color_theme', colorThemeString);
  }
  
  // Tema durumu için getter'lar
  String get currentThemeText {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Açık';
      case ThemeMode.dark:
        return 'Koyu';
      case ThemeMode.system:
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark ? 'Sistem (Koyu)' : 'Sistem (Açık)';
    }
  }
  
  IconData get currentThemeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_brightness;
    }
  }
  
  String get currentColorThemeText {
    return ColorThemes.getThemeName(_colorTheme);
  }
  
  IconData get currentColorThemeIcon {
    return ColorThemes.getThemeIcon(_colorTheme);
  }
  
  // Tema preview için yardımcı method
  Color getPreviewColor(AppColorTheme theme) {
    return ColorThemes.getTheme(theme).primary;
  }
  
  // Tema istatistikleri
  Map<String, dynamic> get themeStats {
    return {
      'themeMode': _themeMode.toString().split('.').last,
      'colorTheme': _colorTheme.toString().split('.').last,
      'isDarkMode': isDarkMode,
      'primaryColor': currentColorPalette.primary.value.toRadixString(16),
    };
  }
}