// lib/screens/step_details_screen.dart - DÜZELTİLMİŞ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/user_provider.dart';
import '../providers/step_counter_provider.dart';
import '../services/calorie_service.dart';
import '../utils/colors.dart';
import '../widgets/activity_ring_painter.dart';

class StepDetailsScreen extends StatelessWidget {
  const StepDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stepProvider = context.watch<StepCounterProvider>();
    final exerciseProvider = context.watch<ExerciseProvider>();
    final user = context.watch<UserProvider>().user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Veri hesaplamaları
    final int steps = stepProvider.dailySteps;
    final int stepGoal = user?.dailyStepGoal ?? 8000;
    final double stepProgress = (steps / stepGoal).clamp(0.0, 1.0);

    // GELİŞMİŞ KALORİ HESAPLAMASI
    double burnedFromSteps = 0.0;
    Map<String, dynamic>? calculationDetails;
    
    if (user != null) {
      // Yeni gelişmiş hesaplama fonksiyonunu kullan
      burnedFromSteps = CalorieService.calculateAdvancedStepCalories(
        steps: steps,
        weight: user.weight,
        height: user.height,
        age: user.age,
        gender: user.gender,
        activityLevel: user.activityLevel,
      );
      
      // Hesaplama detaylarını al
      calculationDetails = CalorieService.getStepCalorieDetails(
        steps: steps,
        weight: user.weight,
        height: user.height,
        age: user.age,
        gender: user.gender,
        activityLevel: user.activityLevel,
      );
    } else {
      // Fallback hesaplama
      burnedFromSteps = CalorieService.calculateStepCalories(steps, 70.0);
    }

    final double burnedFromExercise = exerciseProvider.getDailyBurnedCalories(DateTime.now());
    final double totalBurnedCalories = burnedFromSteps + burnedFromExercise;
    final double calorieGoal = (user?.dailyCalorieNeeds ?? 2000) * 0.25;
    final double calorieProgress = (totalBurnedCalories / calorieGoal).clamp(0.0, 1.0);

    // Mesafe (KM) - Bilimsel hesaplama
    final double strideLength = user != null 
        ? (user.gender == 'male' ? user.height * 0.415 : user.height * 0.413) / 100
        : 0.762;
    final double distanceKm = (steps * strideLength) / 1000;
    final double distanceGoal = 5.0;
    final double distanceProgress = (distanceKm / distanceGoal).clamp(0.0, 1.0);
    
    final int activeMinutes = ((steps / 1000.0) * 10).round();
    final Color defaultTextColor = isDarkMode ? Colors.white : Colors.black;

    // İzin kontrolü
    if (stepProvider.permissionStatus != 'İzin verildi.') {
      return Scaffold(
        appBar: AppBar(title: const Text('Aktivite Detayları')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 64),
              SizedBox(height: 16),
              Text('Adım Sayar Çalışmıyor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(stepProvider.permissionStatus, textAlign: TextAlign.center),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
                icon: Icon(Icons.edit),
                label: Text('Profili Düzenle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktivite Detayları'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
            icon: Icon(Icons.edit),
            tooltip: 'Profili Düzenle',
          ),
          IconButton(
            onPressed: () => stepProvider.sendTestNotification(),
            icon: Icon(Icons.notifications_active),
            tooltip: 'Test Bildirimi',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Büyük Üçlü Halka
            SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: ActivityRingPainter(
                  outerProgress: stepProgress,
                  middleProgress: calorieProgress,
                  innerProgress: distanceProgress,
                  outerColor: AppColors.stepColor,
                  middleColor: AppColors.calorieColor,
                  innerColor: Colors.purple,
                  showGlow: true,
                  customStrokeWidth: 10,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        steps.toString(),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.stepColor,
                          fontSize: 48,
                        ),
                      ),
                      Text(
                        'Adım',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Detaylı İstatistik Kartı
            Card(
              elevation: isDarkMode ? 8 : 6,
              shadowColor: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildDetailRow(context, Icons.directions_walk, 'Adım', '$steps adım', AppColors.stepColor),
                    const Divider(height: 24),
                    _buildDetailRow(context, Icons.map_outlined, 'Mesafe', '${distanceKm.toStringAsFixed(2)} km', Colors.purple),
                    const Divider(height: 24),
                    _buildDetailRow(context, Icons.local_fire_department, 'Yakılan Kalori (Yürüyüş)', '${burnedFromSteps.toInt()} kal', AppColors.calorieColor),
                    if (burnedFromExercise > 0) ...[
                      const Divider(height: 24),
                      _buildDetailRow(context, Icons.fitness_center, 'Yakılan Kalori (Egzersiz)', '${burnedFromExercise.toInt()} kal', Colors.orange),
                      const Divider(height: 24),
                      _buildDetailRow(context, Icons.whatshot, 'Toplam Yakılan', '${totalBurnedCalories.toInt()} kal', Colors.red),
                    ],
                    const Divider(height: 24),
                    _buildDetailRow(context, Icons.timer_outlined, 'Aktif Süre', '$activeMinutes dakika', defaultTextColor),
                    const Divider(height: 24),
                    _buildDetailRow(context, Icons.straighten, 'Hedef Mesafe', '${distanceGoal.toInt()} km', defaultTextColor),
                    const Divider(height: 24),
                    _buildDetailRow(context, Icons.run_circle_outlined, 'Hedef Adım', '${stepGoal.toInt()} adım', defaultTextColor),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Hesaplama Detayları Kartı
            if (calculationDetails != null) Card(
              elevation: isDarkMode ? 6 : 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kişiselleştirilmiş Hesaplama Detayları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCalculationRow('Adım Uzunluğu', calculationDetails['strideLength']),
                    _buildCalculationRow('Mesafe', calculationDetails['distance']),
                    _buildCalculationRow('Süre', calculationDetails['time']),
                    _buildCalculationRow('Ortalama Hız', calculationDetails['speed']),
                    _buildCalculationRow('BMI', calculationDetails['bmi']),
                    _buildCalculationRow('Temel MET', calculationDetails['baseMET']),
                    _buildCalculationRow('Yaş Düzeltmesi', calculationDetails['ageAdjustment']),
                    _buildCalculationRow('BMI Düzeltmesi', calculationDetails['bmiAdjustment']),
                    _buildCalculationRow('Cinsiyet Düzeltmesi', calculationDetails['genderAdjustment']),
                    _buildCalculationRow('Aktivite Düzeltmesi', calculationDetails['activityAdjustment']),
                    const Divider(height: 16),
                    _buildCalculationRow('Final MET Değeri', calculationDetails['finalMET']),
                    _buildCalculationRow('Yakılan Kalori', '${calculationDetails['calories']} kal'),
                    const Divider(height: 16),
                    Text(
                      'Bilimsel MET formülü ile 7 farklı faktör hesaba katılarak doğru kalori hesaplaması yapılır',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Profil eksikse uyarı
            if (user == null) Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Daha Doğru Hesaplama İçin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Profilinizi tamamlayın. Boy, kilo ve yaş bilgileriniz kalori hesaplamalarını daha doğru yapar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange[600]),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/edit_profile'),
                      icon: Icon(Icons.edit),
                      label: Text('Profili Tamamla'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black)),
      ],
    );
  }
  
  Widget _buildCalculationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}