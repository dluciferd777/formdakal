// lib/widgets/advanced_step_counter_card.dart - KALORI DÜZELTMESİ
import 'package:flutter/material.dart';
import 'package:formdakal/widgets/activity_ring_painter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/food_provider.dart';
import '../providers/step_counter_provider.dart';
import '../utils/colors.dart';

class AdvancedStepCounterCard extends StatelessWidget {
  const AdvancedStepCounterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final stepProvider = context.watch<StepCounterProvider>();
    final foodProvider = context.watch<FoodProvider>();
    final user = context.watch<UserProvider>().user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // ADIM SAYAR VERİLERİ
    final int stepGoal = user?.dailyStepGoal ?? 8000;
    final int steps = stepProvider.dailySteps;
    final double stepProgress = (steps / stepGoal).clamp(0.0, 1.0);

    // YEMEKTEKİ KALORİ VERİLERİ (Alınan kalori)
    final double dailyCalorieNeeds = user?.dailyCalorieNeeds ?? 2000;
    final double consumedCalories = foodProvider.getDailyCalories(DateTime.now());
    final double foodCalorieProgress = (consumedCalories / dailyCalorieNeeds).clamp(0.0, 1.0);

    // SADECE ADIMLARDAN YAKILAN KALORİ (Egzersiz kalori dahil değil!)
    final double burnedCalories = steps * 0.045; // DEĞİŞTİRİLDİ: Sadece adımlardan kalori
    final double fitnessCalorieGoal = dailyCalorieNeeds * 0.25; // %25'i fitness hedefi
    final double fitnessCalorieProgress = (burnedCalories / fitnessCalorieGoal).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/step_details'),
      child: Card(
        elevation: isDarkMode ? 8 : 6,
        shadowColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Sol Taraf: Yazılar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      context,
                      icon: Icons.directions_walk,
                      color: AppColors.stepColor,
                      label: 'Adım',
                      value: '$steps',
                      target: '',
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      icon: Icons.restaurant_menu,
                      color: AppColors.calorieColor,
                      label: 'Alınan',
                      value: '${consumedCalories.toInt()}',
                      target: '',
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                      label: 'Yakılan', // Bu artık sadece adımlardan yakılan kalori
                      value: '${burnedCalories.toInt()}',
                      target: '',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Sağ Taraf: Halkalar
              SizedBox(
                width: 80,
                height: 80,
                child: CustomPaint(
                  painter: ActivityRingPainter(
                    outerProgress: stepProgress,
                    middleProgress: foodCalorieProgress,
                    innerProgress: fitnessCalorieProgress,
                    outerColor: AppColors.stepColor,
                    middleColor: AppColors.calorieColor,
                    innerColor: Colors.orange,
                    showGlow: true,
                    customStrokeWidth: 8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String target,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label $value',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}