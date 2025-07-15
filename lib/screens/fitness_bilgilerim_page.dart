// lib/screens/fitness_bilgilerim_page.dart - DROPDOWN HATASI DÜZELTİLDİ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/color_themes.dart';
import '../services/calorie_service.dart';

class FitnessBilgilerimPage extends StatefulWidget {
  const FitnessBilgilerimPage({super.key});

  @override
  State<FitnessBilgilerimPage> createState() => _FitnessBilgilerimPageState();
}

class _FitnessBilgilerimPageState extends State<FitnessBilgilerimPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Temel Fitness Bilgileri
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _weeklyWorkoutController;
  
  // Vücut Kompozisyonu
  late TextEditingController _bodyFatController;
  late TextEditingController _visceralFatController;
  late TextEditingController _muscleController;
  late TextEditingController _waterController;
  late TextEditingController _boneController;
  late TextEditingController _metabolicAgeController;
  
  // Seçili değerler
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'moderately_active';
  String _selectedGoal = 'maintain';

  // HATA DÜZELTİLDİ: Tüm dropdown listelerinde unique değerler kullanıldı
  final List<Map<String, String>> _activityLevels = [
    {'value': 'sedentary', 'label': 'Hareketsiz (Ofis işi)'},
    {'value': 'lightly_active', 'label': 'Hafif Aktif (Hafta 1-3 gün)'},
    {'value': 'moderately_active', 'label': 'Orta Aktif (Hafta 3-5 gün)'},
    {'value': 'very_active', 'label': 'Çok Aktif (Hafta 6-7 gün)'},
    {'value': 'extremely_active', 'label': 'Aşırı Aktif (Günde 2x)'},
  ];

  // DÜZELTME: `_goals` listesindeki `value` değerleri benzersiz hale getirildi.
  final List<Map<String, String>> _goals = [
    {'value': 'lose_weight', 'label': 'Kilo Vermek'}, // 'lose' yerine 'lose_weight'
    {'value': 'maintain', 'label': 'Kiloyu Korumak'}, 
    {'value': 'gain_weight', 'label': 'Kilo Almak'}, // 'gain' yerine 'gain_weight'
    {'value': 'muscle_gain', 'label': 'Kas Yapmak'}, 
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    if (user != null) {
      // Temel bilgiler
      _ageController = TextEditingController(text: user.age.toString());
      _heightController = TextEditingController(text: user.height.toString());
      _weightController = TextEditingController(text: user.weight.toString());
      _weeklyWorkoutController = TextEditingController(text: user.weeklyWorkoutDays.toString());
      
      // Vücut kompozisyonu
      _bodyFatController = TextEditingController(text: user.bodyFatPercentage?.toString() ?? '');
      _visceralFatController = TextEditingController();
      _muscleController = TextEditingController(text: user.musclePercentage?.toString() ?? '');
      _waterController = TextEditingController(text: user.waterPercentage?.toString() ?? '');
      _boneController = TextEditingController();
      _metabolicAgeController = TextEditingController(text: user.metabolicAge?.toString() ?? '');
      
      // Seçili değerler - HATA DÜZELTİLDİ: Eski değer varsa kontrol et
      _selectedGender = user.gender;
      _selectedActivityLevel = user.activityLevel;
      
      // Eski goal değerini yeni sisteme çevir
      // DÜZELTME: 'lose_weight_gain_muscle' artık 'muscle_gain' olarak eşleştirildi.
      if (user.goal == 'lose_weight_gain_muscle') {
        _selectedGoal = 'muscle_gain';
      } else if (user.goal == 'lose') { // 'lose' değeri varsa 'lose_weight'e çevir
        _selectedGoal = 'lose_weight';
      } else if (user.goal == 'gain') { // 'gain' değeri varsa 'gain_weight'e çevir
        _selectedGoal = 'gain_weight';
      } else {
        _selectedGoal = user.goal;
      }
    } else {
      // Boş controller'lar
      _ageController = TextEditingController();
      _heightController = TextEditingController();
      _weightController = TextEditingController();
      _weeklyWorkoutController = TextEditingController();
      _bodyFatController = TextEditingController();
      _visceralFatController = TextEditingController();
      _muscleController = TextEditingController();
      _waterController = TextEditingController();
      _boneController = TextEditingController();
      _metabolicAgeController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _weeklyWorkoutController.dispose();
    _bodyFatController.dispose();
    _visceralFatController.dispose();
    _muscleController.dispose();
    _waterController.dispose();
    _boneController.dispose();
    _metabolicAgeController.dispose();
    super.dispose();
  }

  // BMI hesaplama
  double _calculateBMI() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    if (weight > 0 && height > 0) {
      return weight / ((height / 100) * (height / 100));
    }
    return 0;
  }

  // BMR hesaplama
  double _calculateBMR() {
    final age = int.tryParse(_ageController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;
    
    if (age > 0 && weight > 0 && height > 0) {
      if (_selectedGender == 'male') {
        return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
      } else {
        return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
      }
    }
    return 0;
  }

  // MET değeri hesaplama
  double _calculateMET() {
    final bmr = _calculateBMR();
    if (bmr > 0) {
      double activityFactor;
      switch (_selectedActivityLevel) {
        case 'sedentary': activityFactor = 1.2; break;
        case 'lightly_active': activityFactor = 1.375; break;
        case 'moderately_active': activityFactor = 1.55; break;
        case 'very_active': activityFactor = 1.725; break;
        case 'extremely_active': activityFactor = 1.9; break;
        default: activityFactor = 1.55;
      }
      return (bmr * activityFactor) / (24 * 3.5);
    }
    return 0;
  }

  // Günlük kalori ihtiyacı
  double _calculateDailyCalories() {
    final bmr = _calculateBMR();
    if (bmr > 0) {
      double activityFactor;
      switch (_selectedActivityLevel) {
        case 'sedentary': activityFactor = 1.2; break;
        case 'lightly_active': activityFactor = 1.375; break;
        case 'moderately_active': activityFactor = 1.55; break;
        case 'very_active': activityFactor = 1.725; break;
        case 'extremely_active': activityFactor = 1.9; break;
        default: activityFactor = 1.55;
      }
      
      double calories = bmr * activityFactor;
      
      // Hedefe göre ayarlama - HATA DÜZELTİLDİ: Yeni goal değerleri
      switch (_selectedGoal) {
        case 'lose_weight': calories -= 500; break; // 'lose' yerine 'lose_weight'
        case 'gain_weight': calories += 500; break; // 'gain' yerine 'gain_weight'
        case 'muscle_gain': calories -= 200; break; // Hafif kalori açığı
      }
      
      return calories;
    }
    return 0;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Kilolu';
    return 'Obez';
  }

  void _saveFitnessData() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;
      
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          age: int.tryParse(_ageController.text) ?? currentUser.age,
          height: double.tryParse(_heightController.text) ?? currentUser.height,
          weight: double.tryParse(_weightController.text) ?? currentUser.weight,
          gender: _selectedGender,
          activityLevel: _selectedActivityLevel,
          goal: _selectedGoal,
          weeklyWorkoutDays: int.tryParse(_weeklyWorkoutController.text) ?? currentUser.weeklyWorkoutDays,
          bodyFatPercentage: double.tryParse(_bodyFatController.text),
          musclePercentage: double.tryParse(_muscleController.text),
          waterPercentage: double.tryParse(_waterController.text),
          metabolicAge: int.tryParse(_metabolicAgeController.text),
        );
        
        await userProvider.updateUser(updatedUser);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Fitness bilgileriniz başarıyla güncellendi!'),
              backgroundColor: DynamicColors.primary,
            ),
          );
          Navigator.pop(context); // Sayfayı kapat
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Bilgilerim'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: primaryColor),
            onPressed: _saveFitnessData,
            tooltip: 'Kaydet',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Hesaplanan Değerler Kartı
            _buildCalculatedValuesCard(),
            
            const SizedBox(height: 24),
            
            // Temel Fitness Bilgileri
            _buildSectionTitle('Temel Fitness Bilgileri'),
            _buildBasicFitnessSection(),
            
            const SizedBox(height: 24),
            
            // Vücut Kompozisyonu
            _buildSectionTitle('Vücut Kompozisyonu'),
            _buildBodyCompositionSection(),
            
            const SizedBox(height: 24),
            
            // Aktivite ve Hedef
            _buildSectionTitle('Aktivite ve Hedef'),
            _buildActivitySection(),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatedValuesCard() {
    final bmi = _calculateBMI();
    final bmr = _calculateBMR();
    final met = _calculateMET();
    final dailyCalories = _calculateDailyCalories();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [DynamicColors.primary, DynamicColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Hesaplanan Değerleriniz',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // BMI
            _buildCalculationRow('BMI', bmi > 0 ? bmi.toStringAsFixed(1) : '--', 
              bmi > 0 ? _getBMICategory(bmi) : 'Bilgi eksik'),
            
            const SizedBox(height: 12),
            
            // BMR
            _buildCalculationRow('BMR', bmr > 0 ? '${bmr.toStringAsFixed(0)} kcal' : '--', 
              'Bazal Metabolizma Hızı'),
            
            const SizedBox(height: 12),
            
            // MET
            _buildCalculationRow('MET Değeri', met > 0 ? met.toStringAsFixed(2) : '--', 
              'Metabolik Eşdeğer'),
            
            const SizedBox(height: 12),
            
            // Günlük Kalori
            _buildCalculationRow('Günlük Kalori', dailyCalories > 0 ? '${dailyCalories.toStringAsFixed(0)} kcal' : '--', 
              'Hedefinize uygun kalori'),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String title, String value, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicFitnessSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextFormField(
                  controller: _ageController, 
                  label: 'Yaş', 
                  icon: Icons.cake, 
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildDropdown(
                  label: 'Cinsiyet',
                  icon: Icons.person_outline,
                  value: _selectedGender,
                  items: const [
                    {'value': 'male', 'label': 'Erkek'},
                    {'value': 'female', 'label': 'Kadın'},
                  ],
                  onChanged: (value) => setState(() => _selectedGender = value!),
                )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextFormField(
                  controller: _heightController, 
                  label: 'Boy (cm)', 
                  icon: Icons.height, 
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextFormField(
                  controller: _weightController, 
                  label: 'Kilo (kg)', 
                  icon: Icons.scale, 
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                )),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _weeklyWorkoutController, 
              label: 'Haftalık Antrenman Günü', 
              icon: Icons.fitness_center, 
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyCompositionSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildTextFormField(
                  controller: _bodyFatController, 
                  label: 'Yağ Oranı (%)', 
                  icon: Icons.analytics, 
                  keyboardType: TextInputType.number,
                  hint: '10-30',
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextFormField(
                  controller: _visceralFatController, 
                  label: 'İç Yağ Oranı (%)', 
                  icon: Icons.health_and_safety, 
                  keyboardType: TextInputType.number,
                  hint: '1-15',
                )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextFormField(
                  controller: _muscleController, 
                  label: 'Kas Oranı (%)', 
                  icon: Icons.sports_gymnastics, 
                  keyboardType: TextInputType.number,
                  hint: '30-60',
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextFormField(
                  controller: _waterController, 
                  label: 'Su Oranı (%)', 
                  icon: Icons.water_drop, 
                  keyboardType: TextInputType.number,
                  hint: '45-75',
                )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextFormField(
                  controller: _boneController, 
                  label: 'Kemik Oranı (%)', 
                  icon: Icons.accessibility_new, 
                  keyboardType: TextInputType.number,
                  hint: '2-6',
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextFormField(
                  controller: _metabolicAgeController, 
                  label: 'Metabolik Yaş', 
                  icon: Icons.biotech, 
                  keyboardType: TextInputType.number,
                  hint: 'Vücut yaşı',
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdown(
              label: 'Aktivite Seviyesi',
              icon: Icons.directions_run,
              value: _selectedActivityLevel,
              items: _activityLevels,
              onChanged: (value) => setState(() => _selectedActivityLevel = value!),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Hedefiniz',
              icon: Icons.flag,
              value: _selectedGoal,
              items: _goals,
              onChanged: (value) => setState(() => _selectedGoal = value!),
            ),
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
            height: 24,
            decoration: BoxDecoration(
              color: DynamicColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
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
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: DynamicColors.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DynamicColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
        ),
      ),
      validator: (value) {
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
    );
  }

  // HATA DÜZELTİLDİ: Daha güvenli dropdown widget
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    // Eğer mevcut value items listesinde yoksa, ilk item'ı seç
    String safeValue = value;
    if (!items.any((item) => item['value'] == value)) {
      safeValue = items.first['value']!;
    }

    return DropdownButtonFormField<String>(
      value: safeValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: DynamicColors.primary, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DynamicColors.primary, width: 2),
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
    );
  }
}
