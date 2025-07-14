// lib/widgets/profile_progress_card.dart - GELİŞTİRİLMİŞ VERSİYON
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/step_counter_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/food_provider.dart';
import '../providers/theme_provider.dart';

class ProfileProgressCard extends StatefulWidget {
  const ProfileProgressCard({super.key});

  @override
  State<ProfileProgressCard> createState() => _ProfileProgressCardState();
}

class _ProfileProgressCardState extends State<ProfileProgressCard>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.currentColorPalette.primary;

    return Consumer4<UserProvider, StepCounterProvider, ExerciseProvider, FoodProvider>(
      builder: (context, userProvider, stepProvider, exerciseProvider, foodProvider, child) {
        final user = userProvider.user;
        if (user == null) return const SizedBox.shrink();

        // Gerçek veriler
        final steps = stepProvider.dailySteps;
        final stepGoal = user.dailyStepGoal;
        final consumedCalories = foodProvider.getDailyCalories(DateTime.now());
        final burnedCalories = exerciseProvider.getDailyBurnedCalories(DateTime.now());
        final calorieGoal = user.dailyCalorieNeeds;

        // Hesaplamalar
        final stepCalories = _calculateStepCalories(steps, user.weight);
        final stepDistance = _calculateStepDistance(steps);
        final stepProgress = (steps / stepGoal).clamp(0.0, 1.0);
        final consumedProgress = (consumedCalories / calorieGoal).clamp(0.0, 1.0);
        final burnedProgress = (burnedCalories / 500).clamp(0.0, 1.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Ana Container - GENİŞLETİLDİ
            SizedBox(
              width: 120, // 80'den 120'ye artırıldı
              child: Column(
                children: [
                  // Ana Progress Card - BÜYÜTÜLDÜ
                  GestureDetector(
                    onTap: _toggleExpansion,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 100, // 80'den 100'e artırıldı
                      height: 100, // 80'den 100'e artırıldı
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? Colors.grey[900]?.withOpacity(0.8)
                            : Colors.grey[800]?.withOpacity(0.7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _isExpanded 
                                ? primaryColor.withOpacity(0.4)
                                : (isDarkMode ? Colors.black54 : Colors.black26),
                            blurRadius: _isExpanded ? 16 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress Rings - BÜYÜTÜLDÜ
                          SizedBox(
                            width: 90, // 70'den 90'a artırıldı
                            height: 90,
                            child: CustomPaint(
                              painter: ProgressRingPainter(
                                stepProgress: stepProgress,
                                consumedProgress: consumedProgress,
                                burnedProgress: burnedProgress,
                                isDarkMode: isDarkMode,
                              ),
                            ),
                          ),
                          
                          // Merkez İkon
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.fitness_center,
                            color: Colors.white,
                            size: 24, // 20'den 24'e artırıldı
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Özet Bilgi - GENİŞLETİLDİ
                  _buildSummaryInfo(steps, consumedCalories.toInt(), burnedCalories.toInt(), isDarkMode),
                ],
              ),
            ),
            
            // Detaylı Kart - OVERLAY OLARAK - MENÜNÜN ÜZERİNDE
            if (_isExpanded)
              AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: 120, // Card'ın altından başlasın
                    left: -100, // Sola kaydır
                    child: Transform.scale(
                      scale: _expandAnimation.value,
                      child: Opacity(
                        opacity: _expandAnimation.value,
                        child: _buildExpandedDetailCard(
                          steps, stepGoal, stepCalories, stepDistance,
                          consumedCalories, calorieGoal,
                          burnedCalories, isDarkMode, theme,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryInfo(int steps, int consumed, int burned, bool isDarkMode) {
    return Container(
      width: 120, // Genişletildi
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Adım: $steps',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Kal: $consumed/$burned',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetailCard(
    int steps, int stepGoal, double stepCalories, double stepDistance,
    double consumedCalories, double calorieGoal,
    double burnedCalories, bool isDarkMode, ThemeData theme,
  ) {
    final double netCalories = consumedCalories - (burnedCalories + stepCalories);
    
    return Container(
      width: 300, // Daha geniş
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? theme.cardColor.withOpacity(0.95)
            : Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withOpacity(0.2)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black87 : Colors.black26,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: isDarkMode ? Colors.white : Colors.black,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Günlük Detaylar',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Adım Detayları
          _buildDetailSection('🟢 Adım Sayar', [
            _buildDetailRow('Güncel', '$steps adım', isDarkMode),
            _buildDetailRow('Hedef', '$stepGoal adım', isDarkMode),
            _buildDetailRow('Mesafe', '${stepDistance.toStringAsFixed(2)} km', isDarkMode),
            _buildDetailRow('Kalori', '${stepCalories.toStringAsFixed(0)} kal', isDarkMode),
          ], steps / stepGoal, Colors.green, isDarkMode),
          
          const SizedBox(height: 16),
          
          // Kalori Detayları
          _buildDetailSection('🔴 Alınan Kalori', [
            _buildDetailRow('Güncel', '${consumedCalories.toStringAsFixed(0)} kal', isDarkMode),
            _buildDetailRow('Hedef', '${calorieGoal.toStringAsFixed(0)} kal', isDarkMode),
            _buildDetailRow('Kalan', '${(calorieGoal - consumedCalories).toStringAsFixed(0)} kal', isDarkMode),
          ], consumedCalories / calorieGoal, Colors.red, isDarkMode),
          
          const SizedBox(height: 16),
          
          // Yakılan Kalori
          _buildDetailSection('🟣 Yakılan Kalori', [
            _buildDetailRow('Egzersiz', '${burnedCalories.toStringAsFixed(0)} kal', isDarkMode),
            _buildDetailRow('Adım', '${stepCalories.toStringAsFixed(0)} kal', isDarkMode),
            _buildDetailRow('Toplam', '${(burnedCalories + stepCalories).toStringAsFixed(0)} kal', isDarkMode),
          ], burnedCalories / 500, Colors.purple, isDarkMode),
          
          const SizedBox(height: 16),
          
          // Net Kalori Özeti
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: netCalories > 0 
                  ? Colors.orange.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  netCalories > 0 ? Icons.trending_up : Icons.trending_down,
                  color: netCalories > 0 ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Kalori: ${netCalories.toStringAsFixed(0)} kal',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        netCalories > 0 ? 'Fazla kalori alımı' : 'Kalori açığı',
                        style: TextStyle(
                          color: netCalories > 0 ? Colors.orange : Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> rows, double progress, Color color, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...rows,
        const SizedBox(height: 8),
        _buildProgress(progress, color, isDarkMode),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(double progress, Color color, bool isDarkMode) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.grey[700]?.withOpacity(0.5)
            : Colors.grey[300]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  double _calculateStepCalories(int steps, double weight) {
    return steps * 0.04 * (weight / 70.0);
  }

  double _calculateStepDistance(int steps) {
    return (steps * 0.75) / 1000;
  }
}

// Progress Ring Painter - BÜYÜTÜLMÜŞ
class ProgressRingPainter extends CustomPainter {
  final double stepProgress;
  final double consumedProgress;
  final double burnedProgress;
  final bool isDarkMode;

  ProgressRingPainter({
    required this.stepProgress,
    required this.consumedProgress,
    required this.burnedProgress,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    
    // Ring kalınlığı artırıldı
    const strokeWidth = 4.0;
    
    // Adım Progress (Yeşil - Dış)
    _drawProgressRing(
      canvas, center, radius, 
      stepProgress, Colors.green, strokeWidth
    );
    
    // Kalori Alınan (Kırmızı - Orta)
    _drawProgressRing(
      canvas, center, radius - 8, 
      consumedProgress, Colors.red, strokeWidth
    );
    
    // Kalori Yakılan (Mor - İç)
    _drawProgressRing(
      canvas, center, radius - 16, 
      burnedProgress, Colors.purple, strokeWidth
    );
  }

  void _drawProgressRing(Canvas canvas, Offset center, double radius, 
                        double progress, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color.withOpacity(isDarkMode ? 0.2 : 0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Arkaplan çember
    canvas.drawCircle(center, radius, paint);
    
    // Progress çember
    paint.color = color;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}