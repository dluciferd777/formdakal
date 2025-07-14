import 'package:flutter/material.dart';
import '../models/social_post_model.dart';
import '../utils/color_themes.dart'; // FITNESS UYGULAMASI İÇİN

class FitnessStatsCard extends StatelessWidget {
  final FitnessStatsData fitnessData;

  const FitnessStatsCard({super.key, required this.fitnessData});

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary; // FITNESS RENK SİSTEMİ

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.4)),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          if (fitnessData.steps != null)
            _buildStatRow(
              icon: Icons.directions_walk,
              color: primaryColor,
              label: 'Adım',
              value: fitnessData.steps.toString(),
              progress: fitnessData.stepProgress ?? 0.0,
            ),
          if (fitnessData.steps != null && 
              (fitnessData.consumedCalories != null || fitnessData.burnedCalories != null || fitnessData.waterIntake != null))
            const SizedBox(height: 12),
          if (fitnessData.consumedCalories != null)
            _buildStatRow(
              icon: Icons.restaurant,
              color: Colors.green,
              label: 'Alınan Kalori',
              value: fitnessData.consumedCalories!.toInt().toString(),
              progress: fitnessData.consumedCalorieProgress ?? 0.0,
            ),
          if (fitnessData.consumedCalories != null && 
              (fitnessData.burnedCalories != null || fitnessData.waterIntake != null))
            const SizedBox(height: 12),
          if (fitnessData.burnedCalories != null)
            _buildStatRow(
              icon: Icons.local_fire_department,
              color: Colors.orange,
              label: 'Yakılan Kalori',
              value: fitnessData.burnedCalories!.toInt().toString(),
              progress: fitnessData.burnedCalorieProgress ?? 0.0,
            ),
          if (fitnessData.burnedCalories != null && fitnessData.waterIntake != null)
            const SizedBox(height: 12),
          if (fitnessData.waterIntake != null)
            _buildStatRow(
              icon: Icons.water_drop,
              color: Colors.blue,
              label: 'Su Tüketimi',
              value: '${(fitnessData.waterIntake! * 1000).toInt()} ml',
              progress: fitnessData.waterProgress ?? 0.0,
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}