// lib/screens/privacy_settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/color_themes.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  late Map<String, bool> _currentSettings;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    // Mevcut gizlilik ayarlarını yükle
    _currentSettings = {
      'infoVisible': true, // Bilgilerim sekmesi
      'followVisible': true, // Takip sekmesi
      'photosVisible': true, // Fotoğraflar sekmesi
      'profilePublic': user?.isProfilePublic ?? true, // Profil genel görünürlüğü
    };
  }

  void _saveSettings() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    
    if (currentUser != null) {
      // Profil görünürlüğünü güncelle
      final updatedUser = currentUser.copyWith(
        isProfilePublic: _currentSettings['profilePublic'],
      );
      
      await userProvider.updateUser(updatedUser);
      
      if (mounted) {
        // Gizlilik ayarlarını geri döndür
        Navigator.pop(context, _currentSettings);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gizlilik ayarları güncellendi!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik ve Görünürlük'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: primaryColor),
            onPressed: _saveSettings,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Profil Görünürlüğü'),
          _buildPrivacySwitch(
            title: 'Profil Herkese Açık',
            subtitle: 'Profilinizi herkes görüntüleyebilir.',
            key: 'profilePublic',
            icon: Icons.public,
          ),
          
          const SizedBox(height: 24),
          
          _buildSectionHeader('Sekme Gizliliği'),
          _buildPrivacySwitch(
            title: 'Bilgilerim Sekmesi',
            subtitle: 'Yaş, boy, kilo gibi kişisel bilgilerinizi gösterir.',
            key: 'infoVisible',
            icon: Icons.info_outline,
          ),
          _buildPrivacySwitch(
            title: 'Takip Sekmesi',
            subtitle: 'Takipçi ve takip edilen listelerinizi gösterir.',
            key: 'followVisible',
            icon: Icons.people_outline,
          ),
          _buildPrivacySwitch(
            title: 'Fotoğraflarım Sekmesi',
            subtitle: 'Paylaştığınız fotoğrafları galeride gösterir.',
            key: 'photosVisible',
            icon: Icons.photo_library_outlined,
          ),
          
          const SizedBox(height: 24),
          
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: DynamicColors.primary,
        ),
      ),
    );
  }

  Widget _buildPrivacySwitch({
    required String title,
    required String subtitle,
    required String key,
    required IconData icon,
  }) {
    final primaryColor = DynamicColors.primary;
    final isEnabled = _currentSettings[key] ?? true;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        secondary: Icon(
          icon, 
          color: isEnabled ? primaryColor : Colors.grey[400],
          size: 28,
        ),
        title: Text(
          title, 
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          )
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle, 
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            )
          ),
        ),
        value: isEnabled,
        onChanged: (bool value) {
          setState(() {
            _currentSettings[key] = value;
          });
        },
        activeColor: primaryColor,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: DynamicColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Gizlilik Bilgisi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: DynamicColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Gizli sekmeler sadece size görünür\n'
              '• Diğer kullanıcılar kilit simgesi görür\n'
              '• İstediğiniz zaman açıp kapatabilirsiniz\n'
              '• Profil sahibi olarak her zaman görebilirsiniz',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}