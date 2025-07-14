// lib/screens/onboarding_screen.dart - TAG SİSTEMİ İLE GÜNCELLENMİŞ - DÜZELTİLMİŞ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/friend_service.dart';
import '../utils/colors.dart';
import '../services/calorie_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _tagController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedGender;
  String _selectedActivityLevel = 'moderately_active';
  String _selectedGoal = 'maintain';
  int _selectedWeeklyWorkoutDays = 3;
  
  bool _isLoading = false;
  bool _isCheckingTag = false;
  bool _isTagAvailable = true;
  String? _tagError;
  List<String> _tagSuggestions = [];

  @override
  void initState() {
    super.initState();
    _tagController.addListener(_onTagChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tagController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onTagChanged() {
    final tag = _tagController.text.trim().toUpperCase();
    if (tag.isNotEmpty) {
      _checkTagAvailability(tag);
    } else {
      setState(() {
        _isTagAvailable = true;
        _tagError = null;
        _tagSuggestions = [];
      });
    }
  }

  Future<void> _checkTagAvailability(String tag) async {
    if (!FriendService.isValidTag(tag)) {
      setState(() {
        _isTagAvailable = false;
        _tagError = 'Tag 3-20 karakter arası olmalı ve sadece harf-rakam içermeli';
        _tagSuggestions = [];
      });
      return;
    }

    setState(() {
      _isCheckingTag = true;
      _tagError = null;
    });

    try {
      final isAvailable = await FriendService.isTagAvailable(tag);
      if (mounted) {
        setState(() {
          _isTagAvailable = isAvailable;
          _isCheckingTag = false;
          if (!isAvailable) {
            _tagError = 'Bu tag kullanımda. Başka bir tag deneyin.';
            _generateTagSuggestions();
          } else {
            _tagError = null;
            _tagSuggestions = [];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingTag = false;
          _tagError = 'Tag kontrolünde hata oluştu';
        });
      }
    }
  }

  Future<void> _generateTagSuggestions() async {
    final baseName = _nameController.text.trim();
    if (baseName.isNotEmpty) {
      try {
        final suggestions = await FriendService.generateTagSuggestions(baseName);
        if (mounted) {
          setState(() {
            _tagSuggestions = suggestions.take(5).toList();
          });
        }
      } catch (e) {
        // Hata durumunda boş liste
        if (mounted) {
          setState(() {
            _tagSuggestions = [];
          });
        }
      }
    }
  }

  void _selectSuggestion(String suggestion) {
    _tagController.text = suggestion;
  }

  Future<void> _generateInitialTag(String name) async {
    if (name.isNotEmpty && _tagController.text.isEmpty) {
      try {
        final suggestions = await FriendService.generateTagSuggestions(name);
        if (mounted && suggestions.isNotEmpty) {
          _tagController.text = suggestions.first;
        }
      } catch (e) {
        // Hata durumunda hiçbir şey yapma
      }
    }
  }
  
  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final tag = _tagController.text.trim().toUpperCase();
    if (!_isTagAvailable || tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli ve kullanılabilir bir sosyal kod girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = UserModel(
        name: _nameController.text.trim(),
        userTag: tag,
        age: int.parse(_ageController.text.trim()),
        height: double.parse(_heightController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        gender: _selectedGender!,
        activityLevel: _selectedActivityLevel,
        goal: _selectedGoal,
        weeklyWorkoutDays: _selectedWeeklyWorkoutDays,
      );
      
      // Kullanıcıyı friend service'e kaydet
      final registrationSuccess = await FriendService.registerUser(user);
      if (!registrationSuccess) {
        throw Exception('Bu tag başka birisi tarafından alınmış. Lütfen farklı bir tag deneyin.');
      }
      
      // UserProvider'a kaydet
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.saveUser(user);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hoş geldin ${user.name}! Profilin oluşturuldu 🎉'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 24),
                Text('Hoş Geldiniz!', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Başlamak için birkaç bilgiye ihtiyacımız var.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                
                // UYARI METNİ
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.info.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Doğru ve kişiselleştirilmiş kalori hesaplamaları, MET değerleri ve fitness takibi için lütfen bilgilerinizi eksiksiz ve doğru girdiğinizden emin olun. Sağlıklı hedeflerinize ulaşmanızda bu veriler kritik öneme sahiptir. 🎯',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.info, 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // İSİM ALANI
                _buildTextField(
                  controller: _nameController, 
                  label: 'Ad Soyad', 
                  icon: Icons.person, 
                  validator: (v) => v!.isEmpty ? 'Bu alan gerekli' : null,
                  onChanged: (value) => _generateInitialTag(value),
                ),
                const SizedBox(height: 16),
                
                // SOSYAL KOD (TAG) ALANI
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        labelText: 'Sosyal Kodunuz',
                        hintText: 'Örnek: LUCCI#OREORE',
                        prefixIcon: Icon(
                          _isCheckingTag 
                              ? Icons.hourglass_empty 
                              : _isTagAvailable 
                                  ? Icons.tag 
                                  : Icons.error,
                          color: _isCheckingTag 
                              ? Colors.orange 
                              : _isTagAvailable 
                                  ? AppColors.primaryGreen 
                                  : Colors.red,
                        ),
                        suffixIcon: _isCheckingTag 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : _isTagAvailable && _tagController.text.isNotEmpty
                                ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
                                : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), 
                          borderSide: BorderSide(
                            color: _isTagAvailable ? AppColors.primaryGreen : Colors.red, 
                            width: 2
                          )
                        ),
                        errorText: _tagError,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Sosyal kod gerekli';
                        if (!_isTagAvailable) return 'Bu kod kullanımda';
                        return null;
                      },
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 8),
                    
                    // AÇIKLAMA METNİ
                    Text(
                      'Arkadaşlarınız sizi bu kodla bulabilir. Kod benzersiz olmalı ve 3-20 karakter arası olmalı.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    
                    // TAG ÖNERİLERİ
                    if (_tagSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Önerilen kodlar:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _tagSuggestions.map((suggestion) => 
                          GestureDetector(
                            onTap: () => _selectSuggestion(suggestion),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                              ),
                              child: Text(
                                suggestion,
                                style: const TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                
                // DİĞER ALANLAR
                Row(
                  children: [
                    Expanded(child: _buildTextField(
                      controller: _ageController, 
                      label: 'Yaş', 
                      icon: Icons.cake, 
                      keyboardType: TextInputType.number, 
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null
                    )),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField<String>(
                        value: _selectedGender,
                        label: 'Cinsiyet',
                        icon: Icons.wc,
                        items: const [ 
                          DropdownMenuItem(value: 'male', child: Text('Erkek')), 
                          DropdownMenuItem(value: 'female', child: Text('Kadın'))
                        ],
                        onChanged: (value) => setState(() => _selectedGender = value),
                        validator: (value) => value == null ? 'Cinsiyet seçin' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(
                      controller: _heightController, 
                      label: 'Boy (cm)', 
                      icon: Icons.height, 
                      keyboardType: TextInputType.number, 
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null
                    )),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField(
                      controller: _weightController, 
                      label: 'Kilo (kg)', 
                      icon: Icons.monitor_weight, 
                      keyboardType: TextInputType.number, 
                      validator: (v) => v!.isEmpty ? 'Gerekli' : null
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDropdownField<String>(
                  value: _selectedActivityLevel,
                  label: 'Aktivite Seviyesi',
                  icon: Icons.directions_run,
                  items: CalorieService.activityFactors.keys.map((key) => 
                    DropdownMenuItem<String>(
                      value: key, 
                      child: Text(_getActivityLevelDisplayName(key))
                    )
                  ).toList(),
                  onChanged: (value) => setState(() => _selectedActivityLevel = value!),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                  child: Text(
                    _getActivityLevelDescription(_selectedActivityLevel),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDropdownField<int>(
                  value: _selectedWeeklyWorkoutDays,
                  label: 'Haftalık Antrenman Günü',
                  icon: Icons.calendar_today,
                  items: List.generate(8, (i) => DropdownMenuItem<int>(value: i, child: Text('$i gün'))),
                  onChanged: (value) => setState(() => _selectedWeeklyWorkoutDays = value!),
                ),
                const SizedBox(height: 16),
                _buildDropdownField<String>(
                  value: _selectedGoal,
                  label: 'Hedef',
                  icon: Icons.flag,
                  items: const [
                    DropdownMenuItem(value: 'maintain', child: Text('Kilo Korumak')),
                    DropdownMenuItem(value: 'lose_weight', child: Text('Kilo Vermek')),
                    DropdownMenuItem(value: 'gain_muscle', child: Text('Kas Yapmak')),
                    DropdownMenuItem(value: 'lose_weight_gain_muscle', child: Text('Kilo Ver & Kas Yap')),
                  ],
                  onChanged: (value) => setState(() => _selectedGoal = value!),
                ),
                const SizedBox(height: 32),
                
                // BAŞLA BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: (_isLoading || _isCheckingTag || !_isTagAvailable) ? null : _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen, 
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    ),
                    icon: _isLoading ? Container() : const Icon(Icons.check_circle_outline),
                    label: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Başla', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                
                // TAG AÇIKLAMA NOTU
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sosyal kodunuz arkadaşlarınızın sizi bulması için kullanılır. Daha sonra değiştiremezsiniz.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryGreen,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({ 
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    TextInputType? keyboardType, 
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), 
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2)
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({ 
    required T? value,
    required String label, 
    required IconData icon, 
    required List<DropdownMenuItem<T>> items, 
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label, 
        prefixIcon: Icon(icon), 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  String _getActivityLevelDisplayName(String key) {
    switch (key) {
      case 'sedentary': return 'Hareketsiz';
      case 'lightly_active': return 'Hafif Aktif';
      case 'moderately_active': return 'Orta Aktif';
      case 'very_active': return 'Çok Aktif';
      case 'extremely_active': return 'Aşırı Aktif';
      default: return 'Bilinmiyor';
    }
  }

  String _getActivityLevelDescription(String key) {
    switch (key) {
      case 'sedentary': return 'Çok az egzersiz veya hiç egzersiz yapmıyorsunuz.';
      case 'lightly_active': return 'Haftada 1-3 gün hafif egzersiz veya spor yapıyorsunuz.';
      case 'moderately_active': return 'Haftada 3-5 gün orta derecede egzersiz veya spor yapıyorsunuz.';
      case 'very_active': return 'Haftada 6-7 gün yoğun egzersiz veya spor yapıyorsunuz.';
      case 'extremely_active': return 'Günde 2 kez veya çok ağır fiziksel işler yapıyorsunuz.';
      default: return '';
    }
  }
}