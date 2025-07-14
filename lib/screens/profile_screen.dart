// lib/screens/profile_screen.dart - Tema Ayarları Menüsü Eklenmiş
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../utils/color_themes.dart';
import '../widgets/branded_app_title.dart';
import '../widgets/dynamic_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, UserProvider>(
      builder: (context, themeProvider, userProvider, child) {
        final user = userProvider.user;
        final palette = themeProvider.currentColorPalette;

        return Scaffold(
          appBar: const SimpleDynamicAppBar(
            title: 'Profil',
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profil Kartı
                _buildProfileHeader(context, user, palette),
                
                const SizedBox(height: 24),
                
                // Tema Ayarları Kartı - YENİ!
                _buildThemeCard(context, themeProvider),
                
                const SizedBox(height: 16),
                
                // Hesap Ayarları
                _buildAccountSection(context),
                
                const SizedBox(height: 16),
                
                // Uygulama Ayarları
                _buildAppSection(context),
                
                const SizedBox(height: 16),
                
                // Destek ve Hakkında
                _buildSupportSection(context),
                
                const SizedBox(height: 32),
                
                // Çıkış Yap Butonu
                _buildSignOutButton(context, palette),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, user, palette) {
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
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: user?.profileImagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      user!.profileImagePath!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, size: 40, color: Colors.white);
                      },
                    ),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            user?.name ?? 'Kullanıcı',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user != null 
                ? '${user.age} yaş • ${user.height.toInt()} cm • ${user.weight.toInt()} kg'
                : 'Profil bilgileri yüklenemedi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, ThemeProvider themeProvider) {
    final palette = themeProvider.currentColorPalette;
    
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: palette.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.palette,
                color: palette.primary,
              ),
            ),
            title: const Text(
              'Tema Kişiselleştirme',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${themeProvider.currentColorThemeText} • ${themeProvider.currentThemeText}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tema rengi önizlemesi
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: palette.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/theme_settings');
            },
          ),
          
          // Hızlı tema değiştirme butonları
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => themeProvider.toggleTheme(),
                    icon: Icon(themeProvider.currentThemeIcon, size: 18),
                    label: Text(themeProvider.currentThemeText),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.primary,
                      side: BorderSide(color: palette.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Hızlı renk değiştirme butonu
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: palette.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _showQuickColorPicker(context, themeProvider),
                    icon: Icon(Icons.color_lens, color: palette.primary),
                    tooltip: 'Hızlı Renk Değiştir',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Hesap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _buildListTile(
            icon: Icons.edit,
            title: 'Profili Düzenle',
            subtitle: 'Kişisel bilgilerinizi güncelleyin',
            onTap: () {
              // Profil düzenleme sayfasına git
            },
          ),
          _buildListTile(
            icon: Icons.fitness_center,
            title: 'Fit Profil',
            subtitle: 'Sosyal fitness profilinizi görüntüleyin',
            onTap: () {
              Navigator.pushNamed(context, '/fit_profile');
            },
          ),
          _buildListTile(
            icon: Icons.security,
            title: 'Gizlilik',
            subtitle: 'Gizlilik ayarlarınızı yönetin',
            onTap: () {
              // Gizlilik ayarları
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Uygulama',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _buildListTile(
            icon: Icons.notifications,
            title: 'Bildirimler',
            subtitle: 'Bildirim tercihlerinizi ayarlayın',
            onTap: () {
              Navigator.pushNamed(context, '/reminders');
            },
          ),
          _buildListTile(
            icon: Icons.cloud_upload,
            title: 'Yedekleme',
            subtitle: 'Verilerinizi yedekleyin',
            onTap: () {
              Navigator.pushNamed(context, '/backup_screen');
            },
          ),
          _buildListTile(
            icon: Icons.download,
            title: 'Verilerimi İndir',
            subtitle: 'Tüm verilerinizi indirin',
            onTap: () {
              // Veri indirme
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Destek',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          _buildListTile(
            icon: Icons.help,
            title: 'Yardım',
            subtitle: 'SSS ve yardım konuları',
            onTap: () {
              // Yardım sayfası
            },
          ),
          _buildListTile(
            icon: Icons.feedback,
            title: 'Geri Bildirim',
            subtitle: 'Görüşlerinizi bizimle paylaşın',
            onTap: () {
              // Geri bildirim formu
            },
          ),
          _buildListTile(
            icon: Icons.star_rate,
            title: 'Uygulamayı Değerlendir',
            subtitle: 'Play Store\'da değerlendirin',
            onTap: () {
              // App Store/Play Store yönlendirme
            },
          ),
          _buildListTile(
            icon: Icons.info,
            title: 'Hakkında',
            subtitle: 'Sürüm 1.0.0',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSignOutButton(BuildContext context, palette) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          _showSignOutDialog(context);
        },
        icon: const Icon(Icons.logout),
        label: const Text('Çıkış Yap'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _showQuickColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hızlı Renk Seçimi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ColorThemes.allThemes.map((theme) {
                final palette = ColorThemes.getTheme(theme);
                final isSelected = themeProvider.colorTheme == theme;
                
                return GestureDetector(
                  onTap: () {
                    themeProvider.setColorTheme(theme);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: palette.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Çıkış işlemi
            },
            child: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FormdaKal',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: const Center(
          child: MediumTitle(textColor: Colors.white),
        ),
      ),
      children: const [
        Text('FormdaKal, sağlıklı yaşam tarzınızı destekleyen kapsamlı bir fitness uygulamasıdır.'),
        SizedBox(height: 16),
        Text('© 2024 FormdaKal. Tüm hakları saklıdır.'),
      ],
    );
  }
}