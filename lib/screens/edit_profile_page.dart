// lib/screens/edit_profile_page.dart - YENİ PROFİL ALANLARI EKLENMİŞ
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/user_provider.dart';
import '../utils/color_themes.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Temel Bilgiler Controller'ları
  late TextEditingController _nameController;
  late TextEditingController _userTagController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _bioController;
  late TextEditingController _countryController;

  // Favori Bilgiler Controller'ları
  late TextEditingController _favoriteMealController;
  late TextEditingController _favoriteSportController;
  late TextEditingController _favoriteTeamController;

  // Sosyal Medya Controller'ları (9 platform)
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _facebookController;
  late TextEditingController _tiktokController;
  late TextEditingController _kickController;
  late TextEditingController _twitchController;
  late TextEditingController _discordController;
  late TextEditingController _whatsappController;
  late TextEditingController _spotifyController;

  // Aktivite Seviyesi ve Hedef
  String _selectedActivityLevel = 'moderately_active';
  String _selectedGoal = 'maintain';
  String _selectedGender = 'male';
  int _selectedWeeklyWorkoutDays = 3;

  // Profil resmi
  String? _profileImagePath;

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
    {'value': 'lose_weight_gain_muscle', 'label': 'Kilo Ver & Kas Yap'},
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
      _countryController = TextEditingController(text: user.country ?? '');

      // Favori Bilgiler
      _favoriteMealController = TextEditingController(text: user.favoriteMeal ?? '');
      _favoriteSportController = TextEditingController(text: user.favoriteSport ?? '');
      _favoriteTeamController = TextEditingController(text: user.favoriteTeam ?? '');

      // Sosyal Medya (9 platform)
      _instagramController = TextEditingController(text: user.instagram ?? '');
      _twitterController = TextEditingController(text: user.twitter ?? '');
      _facebookController = TextEditingController(text: user.facebook ?? '');
      _tiktokController = TextEditingController(text: user.tiktok ?? '');
      _kickController = TextEditingController(text: user.kick ?? '');
      _twitchController = TextEditingController(text: user.twitch ?? '');
      _discordController = TextEditingController(text: user.discord ?? '');
      _whatsappController = TextEditingController(text: user.whatsapp ?? '');
      _spotifyController = TextEditingController(text: user.spotify ?? '');

      // Seçili değerler
      _selectedActivityLevel = user.activityLevel;
      _selectedGoal = user.goal;
      _selectedGender = user.gender;
      _selectedWeeklyWorkoutDays = user.weeklyWorkoutDays;
      _profileImagePath = user.profileImagePath;
    } else {
      // Boş controller'lar
      _nameController = TextEditingController();
      _userTagController = TextEditingController();
      _ageController = TextEditingController();
      _heightController = TextEditingController();
      _weightController = TextEditingController();
      _bioController = TextEditingController();
      _countryController = TextEditingController();
      
      // Boş favori bilgiler
      _favoriteMealController = TextEditingController();
      _favoriteSportController = TextEditingController();
      _favoriteTeamController = TextEditingController();
      
      // Boş sosyal medya
      _instagramController = TextEditingController();
      _twitterController = TextEditingController();
      _facebookController = TextEditingController();
      _tiktokController = TextEditingController();
      _kickController = TextEditingController();
      _twitchController = TextEditingController();
      _discordController = TextEditingController();
      _whatsappController = TextEditingController();
      _spotifyController = TextEditingController();
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
    _countryController.dispose();
    _favoriteMealController.dispose();
    _favoriteSportController.dispose();
    _favoriteTeamController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _kickController.dispose();
    _twitchController.dispose();
    _discordController.dispose();
    _whatsappController.dispose();
    _spotifyController.dispose();
    super.dispose();
  }

  // Profil resmi seçme
  Future<void> _pickProfileImage() async {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Wrap(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Profil Fotoğrafını Değiştir',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galeriden Seç'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final XFile? pickedFile = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                        imageQuality: 85,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          _profileImagePath = pickedFile.path;
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Kamera ile Çek'),
                    onTap: () async {
                      Navigator.of(context).pop();
                      final XFile? pickedFile = await _picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 512,
                        maxHeight: 512,
                        imageQuality: 85,
                      );
                      if (pickedFile != null) {
                        setState(() {
                          _profileImagePath = pickedFile.path;
                        });
                      }
                    },
                  ),
                  if (_profileImagePath != null)
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Profil Fotoğrafını Kaldır', style: TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _profileImagePath = null;
                        });
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resim seçilirken hata oluştu: $e')),
      );
    }
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
          weeklyWorkoutDays: _selectedWeeklyWorkoutDays,
          profileImagePath: _profileImagePath,
          bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
          country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
          
          // Favori bilgiler
          favoriteMeal: _favoriteMealController.text.trim().isNotEmpty ? _favoriteMealController.text.trim() : null,
          favoriteSport: _favoriteSportController.text.trim().isNotEmpty ? _favoriteSportController.text.trim() : null,
          favoriteTeam: _favoriteTeamController.text.trim().isNotEmpty ? _favoriteTeamController.text.trim() : null,
          
          // Sosyal medya (9 platform)
          instagram: _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
          twitter: _twitterController.text.trim().isNotEmpty ? _twitterController.text.trim() : null,
          facebook: _facebookController.text.trim().isNotEmpty ? _facebookController.text.trim() : null,
          tiktok: _tiktokController.text.trim().isNotEmpty ? _tiktokController.text.trim() : null,
          kick: _kickController.text.trim().isNotEmpty ? _kickController.text.trim() : null,
          twitch: _twitchController.text.trim().isNotEmpty ? _twitchController.text.trim() : null,
          discord: _discordController.text.trim().isNotEmpty ? _discordController.text.trim() : null,
          whatsapp: _whatsappController.text.trim().isNotEmpty ? _whatsappController.text.trim() : null,
          spotify: _spotifyController.text.trim().isNotEmpty ? _spotifyController.text.trim() : null,
        );
        
        // UserProvider'ı güncelle
        await userProvider.updateUser(updatedUser);
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profil başarıyla güncellendi!'),
              backgroundColor: DynamicColors.primary,
            ),
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
            // Profil Resmi Bölümü
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 3),
                    color: Colors.grey[200],
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: _profileImagePath != null
                      ? ClipOval(
                          child: Image.file(
                            File(_profileImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                                Icon(Icons.person, size: 60, color: Colors.grey[400]),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.person, size: 60, color: Colors.grey[400]),
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Profil fotoğrafını değiştirmek için dokunun',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Kişisel Bilgiler'),
            _buildTextFormField(
              controller: _nameController, 
              label: 'Ad Soyad', 
              icon: Icons.person,
              isRequired: true
            ),
            _buildTextFormField(
              controller: _userTagController, 
              label: 'Kullanıcı Tag', 
              icon: Icons.alternate_email, 
              hint: 'user123',
              isRequired: true,
            ),
            _buildTextFormField(
              controller: _bioController, 
              label: 'Bio', 
              icon: Icons.info_outline, 
              hint: 'Kendin hakkında birkaç kelime...',
              maxLines: 3,
              isRequired: false
            ),
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
              ],
            ),
            _buildTextFormField(
              controller: _countryController, 
              label: 'Ülke/Şehir', 
              icon: Icons.location_on,
              hint: 'Türkiye, İstanbul',
              isRequired: false
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Favorilerim'),
            _buildTextFormField(
              controller: _favoriteMealController, 
              label: 'Favori Yemek', 
              icon: Icons.restaurant,
              hint: 'Pizza, Makarna, Kebap...',
              isRequired: false
            ),
            _buildTextFormField(
              controller: _favoriteSportController, 
              label: 'Favori Spor', 
              icon: Icons.sports_gymnastics,
              hint: 'Fitness, Futbol, Basketbol...',
              isRequired: false
            ),
            _buildTextFormField(
              controller: _favoriteTeamController, 
              label: 'Favori Takım', 
              icon: Icons.sports_soccer,
              hint: 'Galatasaray, Barcelona...',
              isRequired: false
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Fitness Bilgileri'),
            _buildTextFormField(
              controller: _weightController, 
              label: 'Kilo (kg)', 
              icon: Icons.scale, 
              keyboardType: TextInputType.number, 
              isRequired: true
            ),

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

            // Aktivite Seviyesi
            _buildDropdown(
              label: 'Aktivite Seviyesi',
              icon: Icons.fitness_center,
              value: _selectedActivityLevel,
              items: _activityLevels,
              onChanged: (value) => setState(() => _selectedActivityLevel = value!),
            ),

            // Haftalık Antrenman Günü
            _buildDropdown(
              label: 'Haftalık Antrenman Günü',
              icon: Icons.calendar_today,
              value: _selectedWeeklyWorkoutDays.toString(),
              items: List.generate(8, (i) => {'value': i.toString(), 'label': '$i gün'}),
              onChanged: (value) => setState(() => _selectedWeeklyWorkoutDays = int.parse(value!)),
            ),

            // Hedef
            _buildDropdown(
              label: 'Hedefiniz',
              icon: Icons.flag,
              value: _selectedGoal,
              items: _goals,
              onChanged: (value) => setState(() => _selectedGoal = value!),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Sosyal Medya Hesapları'),
            _buildSocialMediaField(
              controller: _instagramController,
              label: 'Instagram',
              icon: FontAwesomeIcons.instagram,
              hint: 'kullaniciadi',
              platform: 'instagram'
            ),
            _buildSocialMediaField(
              controller: _twitterController,
              label: 'Twitter/X',
              icon: FontAwesomeIcons.twitter,
              hint: 'kullaniciadi',
              platform: 'twitter'
            ),
            _buildSocialMediaField(
              controller: _facebookController,
              label: 'Facebook',
              icon: FontAwesomeIcons.facebook,
              hint: 'kullaniciadi veya URL',
              platform: 'facebook'
            ),
            _buildSocialMediaField(
              controller: _tiktokController,
              label: 'TikTok',
              icon: FontAwesomeIcons.tiktok,
              hint: 'kullaniciadi',
              platform: 'tiktok'
            ),
            _buildSocialMediaField(
              controller: _kickController,
              label: 'Kick',
              icon: FontAwesomeIcons.play,
              hint: 'kullaniciadi',
              platform: 'kick'
            ),
            _buildSocialMediaField(
              controller: _twitchController,
              label: 'Twitch',
              icon: FontAwesomeIcons.twitch,
              hint: 'kullaniciadi',
              platform: 'twitch'
            ),
            _buildSocialMediaField(
              controller: _discordController,
              label: 'Discord',
              icon: FontAwesomeIcons.discord,
              hint: 'kullaniciadi#1234',
              platform: 'discord'
            ),
            _buildSocialMediaField(
              controller: _whatsappController,
              label: 'WhatsApp',
              icon: FontAwesomeIcons.whatsapp,
              hint: 'telefon numarası',
              platform: 'whatsapp'
            ),
            _buildSocialMediaField(
              controller: _spotifyController,
              label: 'Spotify',
              icon: FontAwesomeIcons.spotify,
              hint: 'kullaniciadi veya URL',
              platform: 'spotify'
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: DynamicColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DynamicColors.primary,
            ),
          ),
        ],
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
    bool isEnabled = true,
    int maxLines = 1,
  }) {
    final primaryColor = DynamicColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: isEnabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: isEnabled ? primaryColor : Colors.grey, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          ),
          fillColor: isEnabled ? null : Colors.grey.withOpacity(0.1),
          filled: !isEnabled,
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

  Widget _buildSocialMediaField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required String platform,
  }) {
    final primaryColor = DynamicColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: FaIcon(icon, color: primaryColor, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      controller.clear();
                    });
                  },
                )
              : null,
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
        onChanged: (value) {
          setState(() {}); // Suffix icon'u güncellemek için
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