// lib/screens/step_details_screen.dart - DÜZELTİLMİŞ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/user_provider.dart';
import '../providers/step_counter_provider.dart'; // ÇALIŞAN PROVİDER
import '../utils/colors.dart';
import '../widgets/activity_ring_painter.dart';

class StepDetailsScreen extends StatelessWidget {
  const StepDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stepProvider = context.watch<StepCounterProvider>(); // ÇALIŞAN PROVİDER
    final exerciseProvider = context.watch<ExerciseProvider>();
    final user = context.watch<UserProvider>().user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Veri hesaplamaları
    final int steps = stepProvider.dailySteps; // ÇALIŞAN VERİ
    final int stepGoal = user?.dailyStepGoal ?? 8000;
    final double stepProgress = (steps / stepGoal).clamp(0.0, 1.0);

    // Yakılan kalori (adımlardan + egzersizden)
    final double burnedFromSteps = (steps * 0.04); // Çalışan formül
    final double burnedFromExercise = exerciseProvider.getDailyBurnedCalories(DateTime.now());
    final double totalBurnedCalories = burnedFromSteps + burnedFromExercise;
    final double calorieGoal = (user?.dailyCalorieNeeds ?? 2000) * 0.25;
    final double calorieProgress = (totalBurnedCalories / calorieGoal).clamp(0.0, 1.0);

    // Mesafe (KM)
    final double distanceKm = (steps * 0.762) / 1000;
    final double distanceGoal = 5.0;
    final double distanceProgress = (distanceKm / distanceGoal).clamp(0.0, 1.0);
    
    final int activeMinutes = (steps / 100).round(); // Basit hesaplama
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
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Aktivite Detayları')),
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
                  outerProgress: stepProgress,           // Dış halka - Adım
                  middleProgress: calorieProgress,       // Orta halka - Kalori
                  innerProgress: distanceProgress,       // İç halka - KM
                  outerColor: AppColors.stepColor,       // Adım rengi
                  middleColor: AppColors.calorieColor,   // Kalori rengi
                  innerColor: Colors.purple,             // KM rengi
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
                    _buildDetailRow(context, Icons.directions_walk, 'Adım', '${steps} adım', AppColors.stepColor),
                    const Divider(height: 24),
                    _buildDetailRow(context, Icons.map_outlined, 'Mesafe', '${distanceKm.toStringAsFixed(2)} km', Colors.purple),
                    const Divider(height: 24),
                    _buildDetailRow(context, Icons.local_fire_department, 'Yakılan Kalori', '${totalBurnedCalories.toInt()} kal', AppColors.calorieColor),
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
}