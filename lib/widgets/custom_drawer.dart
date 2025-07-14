// lib/widgets/custom_drawer.dart - DİNAMİK RENKLER İLE GÜNCELLENDİ
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/color_themes.dart';
import '../widgets/activity_ring_painter.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  ImageProvider? _buildProfileImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    
    if (kIsWeb) {
      return NetworkImage(imagePath);
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return SizedBox(
      width: 240,
      child: Drawer(
        child: Column(
          children: [
            Consumer3<UserProvider, ExerciseProvider, ThemeProvider>(
              builder: (context, userProvider, exerciseProvider, themeProvider, child) {
                final user = userProvider.user;
                final imageProvider = _buildProfileImage(user?.profileImagePath);
                final palette = themeProvider.currentColorPalette;
                
                // Dinamik renk animasyonu
                _colorAnimation = ColorTween(
                  begin: palette.primary.withOpacity(0.2),
                  end: palette.primary.withOpacity(0.5),
                ).animate(_animationController);
                
                final double dailyBurnedCalories = exerciseProvider.getDailyBurnedCalories(DateTime.now());
                final double calorieGoal = user?.dailyCalorieNeeds != null ? user!.dailyCalorieNeeds * 0.25 : 500;
                final double progress = (dailyBurnedCalories / calorieGoal).clamp(0.0, 1.0);

                return Container(
                  height: 140 + statusBarHeight, 
                  padding: EdgeInsets.fromLTRB(12, 24 + statusBarHeight, 8, 12),
                  decoration: BoxDecoration(
                    color: palette.primary, // Dinamik tema rengi
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Profil resmi alanı
                          AnimatedBuilder(
                            animation: _colorAnimation,
                            builder: (context, child) {
                              return SizedBox(
                                width: 60,
                                height: 60,
                                child: CustomPaint(
                                  painter: ActivityRingPainter(
                                    outerProgress: progress,
                                    middleProgress: progress,
                                    innerProgress: progress,
                                    outerColor: Colors.white,
                                    middleColor: Colors.white.withOpacity(0.7),
                                    innerColor: Colors.white.withOpacity(0.4),
                                    showGlow: true,
                                  ),
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: _colorAnimation.value,
                                      backgroundImage: imageProvider,
                                      child: imageProvider == null 
                                          ? Icon(Icons.person, size: 25, color: palette.primary)
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          // İsim ve bilgiler
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user?.name ?? 'Kullanıcı Adı',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(context, '/profile');
                                      },
                                      tooltip: 'Profili Düzenle',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 24,
                                        minHeight: 24,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    user != null
                                        ? '${user.age} yaş • ${user.height.toInt()} cm • ${user.weight.toInt()} kg'
                                        : 'Profil bilgileri eksik',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  final palette = themeProvider.currentColorPalette;
                  
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 4),
                      
                      // GRUP 1: ANA SAYFALAR
                      _buildMenuItem(context, palette, icon: Icons.home_outlined, title: 'Ana Ekran', route: '/home', isHome: true),
                      _buildMenuItem(context, palette, icon: Icons.fitness_center, title: 'Fit Profil', route: '/fit_profile'),
                      _buildMenuItem(context, palette, icon: Icons.person_outline, title: 'Bilgilerim', route: '/profile'),
                      _buildMenuItem(context, palette, icon: Icons.emoji_events_outlined, title: 'Başarımlarım', route: '/achievements'),
                      
                      const Divider(height: 16, thickness: 0.5, indent: 12, endIndent: 12),
                      
                      // GRUP 2: ANTRENMAN VE KALORİ
                      _buildMenuItem(context, palette, icon: Icons.assignment_outlined, title: 'Antrenman Planları', route: '/workout_plans'),
                      _buildMenuItem(context, palette, icon: Icons.monitor_heart_outlined, title: 'Kalori Takibi', route: '/calorie_tracking'),
                      _buildMenuItem(context, palette, icon: Icons.fitness_center_outlined, title: 'Fitness Kalori', route: '/fitness'),
                      _buildMenuItem(context, palette, icon: Icons.restaurant_menu_outlined, title: 'Yemek Kalori', route: '/food_calories'),
                      
                      const Divider(height: 16, thickness: 0.5, indent: 12, endIndent: 12),
                      
                      // GRUP 3: RAPORLAR VE TAKİP
                      _buildMenuItem(context, palette, icon: Icons.bar_chart_outlined, title: 'Raporlar', route: '/reports'),
                      _buildMenuItem(context, palette, icon: Icons.straighten_outlined, title: 'Ölçümlerim', route: '/measurements'),
                      _buildMenuItem(context, palette, icon: Icons.photo_camera_outlined, title: 'Fotoğraflarım', route: '/progress_photos'),
                      _buildMenuItem(context, palette, icon: Icons.notifications_outlined, title: 'Hatırlatıcılar', route: '/reminders'),
                      
                      const Divider(height: 16, thickness: 0.5, indent: 12, endIndent: 12),
                      
      
                    ],
                  );
                },
              ),
            ),
            // İmza alanı
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
              child: Text(
                'Powered by Lucci FormdaKal 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, 
    ColorPalette palette, {
    required IconData icon, 
    required String title, 
    required String route, 
    bool isHome = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      minLeadingWidth: 24,
      leading: Icon(
        icon, 
        color: palette.primary, // Dinamik tema rengi
        size: 18,
      ),
      title: Text(
        title, 
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 13,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (isHome) {
          Navigator.pushNamedAndRemoveUntil(context, route, (route) => false);
        } else {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}