import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/social_post_model.dart';
import '../models/social_user_model.dart';
import '../providers/social_provider.dart';
import '../providers/user_provider.dart';
import '../providers/food_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/step_counter_provider.dart';
import '../utils/color_themes.dart';
import '../widgets/fitness_stats_card.dart';

class FitnessShareSheet extends StatefulWidget {
  final SocialUser currentUser;
  const FitnessShareSheet({super.key, required this.currentUser});

  @override
  State<FitnessShareSheet> createState() => _FitnessShareSheetState();
}

class _FitnessShareSheetState extends State<FitnessShareSheet> {
  List<String> _selectedAudience = [];

  void _shareFitnessStats() {
    final userProvider = context.read<UserProvider>();
    final foodProvider = context.read<FoodProvider>();
    final exerciseProvider = context.read<ExerciseProvider>();
    final stepProvider = context.read<StepCounterProvider>();
    final socialProvider = context.read<SocialProvider>();

    final today = DateTime.now();
    final user = userProvider.user;
    
    // Fitness verilerini al
    final steps = stepProvider.dailySteps;
    final consumedCalories = foodProvider.getDailyCalories(today);
    final burnedCalories = exerciseProvider.getDailyBurnedCalories(today);
    final waterIntake = userProvider.getDailyWaterIntake(today);

    // Progress hesapla
    final stepGoal = user?.dailyStepGoal ?? 8000;
    final calorieNeeds = user?.dailyCalorieNeeds ?? 2000;
    final waterNeeds = 2.0;

    final fitnessData = FitnessStatsData(
      steps: steps,
      consumedCalories: consumedCalories,
      burnedCalories: burnedCalories,
      waterIntake: waterIntake,
      stepProgress: steps / stepGoal,
      consumedCalorieProgress: consumedCalories / calorieNeeds,
      burnedCalorieProgress: burnedCalories / (calorieNeeds * 0.2),
      waterProgress: waterIntake / waterNeeds,
    );

    final newPost = SocialPost(
      id: DateTime.now().toIso8601String(),
      userId: widget.currentUser.userTag,
      userName: widget.currentUser.userName,
      userProfileImageUrl: widget.currentUser.profileImageUrl,
      type: PostType.fitnessStats,
      timestamp: DateTime.now(),
      fitnessData: fitnessData,
      allowedUserTags: _selectedAudience.isNotEmpty ? _selectedAudience : null,
    );

    socialProvider.addPost(newPost);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitness verileriniz başarıyla paylaşıldı!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary;
    final bool isPrivate = _selectedAudience.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, 
              height: 5, 
              decoration: BoxDecoration(
                color: Colors.grey[600], 
                borderRadius: BorderRadius.circular(10)
              )
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Fitness Verilerini Paylaş', 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: primaryColor
            )
          ),
          const SizedBox(height: 24),
          
          _buildOptionTile(
            context, 
            icon: Icons.article, 
            title: 'Yazı Paylaş', 
            onTap: () => Navigator.pop(context),
          ),
          _buildOptionTile(
            context, 
            icon: FontAwesomeIcons.youtube, 
            title: 'YouTube Videosu Paylaş', 
            onTap: () => Navigator.pop(context),
          ),
          _buildOptionTile(
            context, 
            icon: Icons.photo_camera, 
            title: 'Fotoğraf Paylaş', 
            onTap: () => Navigator.pop(context),
          ),
          const Divider(height: 32),

          const Text(
            'Günlük Fitness İstatistikleri', 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
          ),
          const SizedBox(height: 12),
          
          Consumer4<UserProvider, FoodProvider, ExerciseProvider, StepCounterProvider>(
            builder: (context, userProvider, foodProvider, exerciseProvider, stepProvider, child) {
              final today = DateTime.now();
              final user = userProvider.user;
              final steps = stepProvider.dailySteps;
              final consumedCalories = foodProvider.getDailyCalories(today);
              final burnedCalories = exerciseProvider.getDailyBurnedCalories(today);
              final waterIntake = userProvider.getDailyWaterIntake(today);

              final stepGoal = user?.dailyStepGoal ?? 8000;
              final calorieNeeds = user?.dailyCalorieNeeds ?? 2000;
              final waterNeeds = 2.0;

              final previewData = FitnessStatsData(
                steps: steps,
                consumedCalories: consumedCalories,
                burnedCalories: burnedCalories,
                waterIntake: waterIntake,
                stepProgress: steps / stepGoal,
                consumedCalorieProgress: consumedCalories / calorieNeeds,
                burnedCalorieProgress: burnedCalories / (calorieNeeds * 0.2),
                waterProgress: waterIntake / waterNeeds,
              );

              return FitnessStatsCard(fitnessData: previewData);
            },
          ),
          
          const SizedBox(height: 16),
          
          OutlinedButton.icon(
            icon: Icon(isPrivate ? Icons.people : Icons.public, color: primaryColor),
            label: Text(
              isPrivate ? '${_selectedAudience.length} Kişi Görebilir' : 'Görünürlük: Herkes',
              style: TextStyle(color: primaryColor),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kitle seçimi yakında eklenecek!')),
              );
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor.withOpacity(0.5))
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _shareFitnessStats,
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text('Fitness Verilerini Paylaş', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {
    required IconData icon, 
    required String title, 
    required VoidCallback onTap
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}