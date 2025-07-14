import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/color_themes.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Temel Bilgiler Controller'ları
  late TextEditingController _nameController;
  late TextEditingController _userTagController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bioController;

  // Sosyal Medya Controller'ları
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _favoriteTeamController;
  late TextEditingController _countryController;

  // Aktivite Seviyesi ve Hedef
  String _selectedActivityLevel = 'moderately_active';
  String _selectedGoal = 'maintain';
  String _selectedGender = 'male';

  final List<Map<String, String>> _activityLevels = [
    {'value': 'sedentary', 'label': 'Hareketsiz (Ofis işi)'},
    {'value': 'lightly_active', 'label': 'Hafif Aktif (Hafta 1-3 gün)'},
    {'value': 'moderately_active', 'label': 'Orta Aktif (Hafta 3-5 gün)'},
    {'value': 'very_active', 'label': 'Çok Aktif (Hafta 6-7 gün)'},
    {'value': 'extremely_active', 'label': 'Aşırı Aktif (Günde 2x)'},
  ];

  final List<Map<String, String>> _goals = [
    {'value': 'lose', 'label': 'Kilo Vermek'},
    {'value': 'maintain', 'label': 'Kiloyu Korumak'},
    {'value': 'gain', 'label': 'Kilo Almak'},
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user != null) {
      // Temel Bilgiler
      _nameController = TextEditingController(text: user.name);
      _userTagController = TextEditingController(text: user.userTag);
      _ageController = TextEditingController(text: user.age.toString());
      _heightController = TextEditingController(text: user.height.toString());
      _weightController = TextEditingController(text: user.weight.toString());
      _bioController = TextEditingController(text: user.bio ?? '');

      // Sosyal Medya ve Diğer Bilgiler
      _instagramController = TextEditingController(text: user.instagram ?? '');
      _twitterController = TextEditingController(text: user.twitter ?? '');
      _favoriteTeamController = TextEditingController(text: user.favoriteTeam ?? '');
      _countryController = TextEditingController(text: user.country ?? '');

      // Seçili değerler
      _selectedActivityLevel = user.activityLevel;
      _selectedGoal = user.goal;
      _selectedGender = user.gender;
    } else {
      // Boş controller'lar
      _nameController = TextEditingController();
      _userTagController = TextEditingController();
      _ageController = TextEditingController();
      _heightController = TextEditingController();
      _weightController = TextEditingController();
      _bioController = TextEditingController();
      _instagramController = TextEditingController();
      _twitterController = TextEditingController();
      _favoriteTeamController = TextEditingController();
      _countryController = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Tüm controller'ları temizle
    _nameController.dispose();
    _userTagController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _favoriteTeamController.dispose();
    _countryController.dispose();
    super.dispose();
  }
  
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;
      
      if (currentUser != null) {
        // Mevcut kullanıcıyı güncelle
        final updatedUser = currentUser.copyWith(
          name: _nameController.text.trim(),
          userTag: _userTagController.text.trim(),
          age: int.tryParse(_ageController.text) ?? currentUser.age,
          height: double.tryParse(_heightController.text) ?? currentUser.height,
          weight: double.tryParse(_weightController.text) ?? currentUser.weight,
          gender: _selectedGender,
          activityLevel: _selectedActivityLevel,
          goal: _selectedGoal,
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
          instagram: _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
          twitter: _twitterController.text.trim().isNotEmpty ? _twitterController.text.trim() : null,
          favoriteTeam: _favoriteTeamController.text.trim().isNotEmpty ? _favoriteTeamController.text.trim() : null,
          country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
        );
        
        // UserProvider'ı güncelle
        await userProvider.updateUser(updatedUser);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil başarıyla güncellendi!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profili Düzenle'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: primaryColor),
            onPressed: _saveProfile,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle('Temel Bilgiler'),
            _buildTextFormField(
              controller: _nameController, 
              label: 'İsim', 
              icon: Icons.person,
              isRequired: true
            ),
            _buildTextFormField(
              controller: _userTagController, 
              label: 'Kullanıcı Tag', 
              icon: Icons.alternate_email, 
              hint: 'user123',
              isRequired: true
            ),
            _buildTextFormField(
              controller: _bioController, 
              label: 'Bio', 
              icon: Icons.info_outline, 
              hint: 'Kendin hakkında birkaç kelime...',
              maxLines: 3,
              isRequired: false
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Vücut Değerleri'),
            Row(
              children: [
                Expanded(child: _buildTextFormField(
                  controller: _ageController, 
                  label: 'Yaş', 
                  icon: Icons.cake, 
                  keyboardType: TextInputType.number, 
                  isRequired: true
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextFormField(
                  controller: _heightController, 
                  label: 'Boy (cm)', 
                  icon: Icons.height, 
                  keyboardType: TextInputType.number, 
                  isRequired: true
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextFormField(
                  controller: _weightController, 
                  label: 'Kilo (kg)', 
                  icon: Icons.scale, 
                  keyboardType: TextInputType.number, 
                  isRequired: true
                )),
              ],
            ),
            const SizedBox(height: 16),

            // Cinsiyet Seçimi
            _buildDropdown(
              label: 'Cinsiyet',
              icon: Icons.person_outline,
              value: _selectedGender,
              items: const [
                {'value': 'male', 'label': 'Erkek'},
                {'value': 'female', 'label': 'Kadın'},
              ],
              onChanged: (value) => setState(() => _selectedGender = value!),
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Fitness Bilgileri'),
            // Aktivite Seviyesi
            _buildDropdown(
              label: 'Aktivite Seviyesi',
              icon: Icons.fitness_center,
              value: _selectedActivityLevel,
              items: _activityLevels,
              onChanged: (value) => setState(() => _selectedActivityLevel = value!),
            ),
            const SizedBox(height: 16),

            // Hedef
            _buildDropdown(
              label: 'Hedefiniz',
              icon: Icons.flag,
              value: _selectedGoal,
              items: _goals,
              onChanged: (value) => setState(() => _selectedGoal = value!),
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Kişisel Bilgiler'),
            _buildTextFormField(
              controller: _favoriteTeamController, 
              label: 'Favori Takım', 
              icon: Icons.sports_soccer,
              isRequired: false
            ),
            _buildTextFormField(
              controller: _countryController, 
              label: 'Ülke/Şehir', 
              icon: Icons.location_city,
              isRequired: false
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Sosyal Medya'),
            _buildTextFormField(
              controller: _instagramController, 
              label: 'Instagram Kullanıcı Adı', 
              icon: FontAwesomeIcons.instagram, 
              hint: 'username',
              isRequired: false
            ),
            _buildTextFormField(
              controller: _twitterController, 
              label: 'Twitter/X Kullanıcı Adı', 
              icon: FontAwesomeIcons.twitter, 
              hint: 'username',
              isRequired: false
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
    int maxLines = 1,
  }) {
    final primaryColor = DynamicColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryColor, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return '$label alanı boş bırakılamaz';
          }
          if (label.contains('Yaş') && value != null && value.isNotEmpty) {
            final age = int.tryParse(value);
            if (age == null || age < 1 || age > 120) {
              return 'Geçerli bir yaş girin (1-120)';
            }
          }
          if (label.contains('Boy') && value != null && value.isNotEmpty) {
            final height = double.tryParse(value);
            if (height == null || height < 50 || height > 250) {
              return 'Geçerli bir boy girin (50-250 cm)';
            }
          }
          if (label.contains('Kilo') && value != null && value.isNotEmpty) {
            final weight = double.tryParse(value);
            if (weight == null || weight < 20 || weight > 300) {
              return 'Geçerli bir kilo girin (20-300 kg)';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    final primaryColor = DynamicColors.primary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['label']!),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label seçilmelidir';
          }
          return null;
        },
      ),
    );
  }
}