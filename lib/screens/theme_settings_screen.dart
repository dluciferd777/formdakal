// lib/screens/theme_settings_screen.dart - Tema Kişiselleştirme Ekranı
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/color_themes.dart';
import '../widgets/dynamic_app_bar.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: SimpleDynamicAppBar(
            title: 'Tema Ayarları',
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık Kartı
                    _buildHeaderCard(themeProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Tema Modu Seçimi
                    _buildThemeModeSection(themeProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Renk Teması Seçimi
                    _buildColorThemeSection(themeProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Önizleme Kartı
                    _buildPreviewCard(themeProvider),
                    
                    const SizedBox(height: 32),
                    
                    // Tema İstatistikleri
                    _buildThemeStats(themeProvider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(ThemeProvider themeProvider) {
    final palette = themeProvider.currentColorPalette;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.primary, palette.light],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.palette,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            'Tema Kişiselleştirme',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Uygulamanızı istediğiniz gibi renklendirin',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeSection(ThemeProvider themeProvider) {
    return _buildSection(
      title: 'Tema Modu',
      icon: themeProvider.currentThemeIcon,
      child: Column(
        children: [
          _buildThemeModeOption(
            themeProvider,
            ThemeMode.system,
            'Sistem Ayarı',
            'Cihazınızın ayarını takip eder',
            Icons.settings_brightness,
          ),
          const SizedBox(height: 8),
          _buildThemeModeOption(
            themeProvider,
            ThemeMode.light,
            'Açık Tema',
            'Her zaman açık tema kullanır',
            Icons.light_mode,
          ),
          const SizedBox(height: 8),
          _buildThemeModeOption(
            themeProvider,
            ThemeMode.dark,
            'Koyu Tema',
            'Her zaman koyu tema kullanır',
            Icons.dark_mode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeOption(
    ThemeProvider themeProvider,
    ThemeMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    final palette = themeProvider.currentColorPalette;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected 
            ? palette.primary.withOpacity(0.1)
            : Theme.of(context).cardColor,
        border: Border.all(
          color: isSelected 
              ? palette.primary
              : Colors.grey.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? palette.primary : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? palette.primary : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: palette.primary)
            : null,
        onTap: () => themeProvider.setTheme(mode),
      ),
    );
  }

  Widget _buildColorThemeSection(ThemeProvider themeProvider) {
    return _buildSection(
      title: 'Renk Teması',
      icon: themeProvider.currentColorThemeIcon,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: ColorThemes.allThemes.length,
        itemBuilder: (context, index) {
          final theme = ColorThemes.allThemes[index];
          return _buildColorThemeOption(themeProvider, theme);
        },
      ),
    );
  }

  Widget _buildColorThemeOption(ThemeProvider themeProvider, AppColorTheme theme) {
    final isSelected = themeProvider.colorTheme == theme;
    final palette = ColorThemes.getTheme(theme);
    
    return GestureDetector(
      onTap: () {
        themeProvider.setColorTheme(theme);
        _showColorChangeSnackBar(palette.name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: palette.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: palette.primary.withOpacity(0.3),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              palette.icon,
              color: Colors.white,
              size: isSelected ? 28 : 24,
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeProvider themeProvider) {
    final palette = themeProvider.currentColorPalette;
    
    return _buildSection(
      title: 'Önizleme',
      icon: Icons.preview,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Örnek AppBar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: themeProvider.colorTheme == AppColorTheme.black
                    ? const Color(0xFF1C1C1C) // Siyah tema için
                    : themeProvider.isDarkMode 
                        ? DynamicColors.darkSurface 
                        : palette.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  // FormdaKal başlığı - F ve K harfleri vurgulanmış
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: 'F',
                          style: TextStyle(color: palette.light),
                        ),
                        const TextSpan(text: 'ormda'),
                        TextSpan(
                          text: 'K',
                          style: TextStyle(color: palette.light),
                        ),
                        const TextSpan(text: 'al'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.notifications, color: Colors.white, size: 20),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Örnek butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ana Buton'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.primary,
                      side: BorderSide(color: palette.primary),
                    ),
                    child: const Text('İkinci Buton'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Örnek progress indicator
            Row(
              children: [
                Text('İlerleme: '),
                Expanded(
                  child: LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(palette.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Text('70%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeStats(ThemeProvider themeProvider) {
    final stats = themeProvider.themeStats;
    
    return _buildSection(
      title: 'Tema Bilgileri',
      icon: Icons.info_outline,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            _buildStatRow('Tema Modu', stats['themeMode']),
            _buildStatRow('Renk Teması', stats['colorTheme']),
            _buildStatRow('Karanlık Mod', stats['isDarkMode'] ? 'Aktif' : 'Pasif'),
            _buildStatRow('Ana Renk', '#${stats['primaryColor']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  void _showColorChangeSnackBar(String colorName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$colorName tema seçildi! 🎨'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}