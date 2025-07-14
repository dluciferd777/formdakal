// lib/screens/home_screen.dart - HATALAR DÜZELTİLDİ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/achievement_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/food_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../services/calorie_service.dart';
import '../utils/color_themes.dart';
import '../widgets/activity_calendar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/expandable_activity_card.dart';
import '../widgets/advanced_step_counter_card.dart'; // Import kullanılıyor
import '../widgets/branded_app_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime _selectedDate = DateTime.now();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      extendBody: true,
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: Consumer6<UserProvider, FoodProvider, ExerciseProvider, AchievementProvider, ThemeProvider, ThemeProvider>(
                  builder: (context, userProvider, foodProvider, exerciseProvider, achievementProvider, themeProvider, _, child) {
                    final user = userProvider.user;
                    final dailyIntakeCalories = foodProvider.getDailyCalories(_selectedDate);
                    final dailyBurnedCalories = exerciseProvider.getDailyBurnedCalories(_selectedDate);
                    final dailyWaterIntake = userProvider.getDailyWaterIntake(_selectedDate);
                    final unlockedAchievements = achievementProvider.achievements.where((a) => a.isUnlocked).length;
                    
                    // Dinamik renkler
                    final palette = themeProvider.currentColorPalette;
                    
                    final dailyWaterTarget = user != null
                        ? CalorieService.calculateDailyWaterNeeds(weight: user.weight, activityLevel: user.activityLevel)
                        : 2.0;

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.menu, 
                                    size: 28, 
                                    color: palette.primary,
                                  ),
                                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                                ),
                                // FormdaKal başlığı - F ve K harfleri dinamik renkli
                                MediumTitle(
                                  textColor: isDarkMode ? Colors.white : Colors.black,
                                ),
                                IconButton(
                                  icon: Icon(
                                    themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode, 
                                    size: 28, 
                                    color: palette.primary,
                                  ),
                                  onPressed: () => themeProvider.toggleTheme(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Boşluk
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 40),
                        ),

                        // Calendar
                        SliverToBoxAdapter(
                          child: ActivityCalendar(
                            mode: CalendarMode.activity,
                            showStats: false, 
                            onDateSelected: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                          ),
                        ),
                        
                        // Activities Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Aktivitelerim', 
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600, 
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.share, 
                                    size: 28, 
                                    color: palette.primary,
                                  ),
                                  onPressed: () => Navigator.pushNamed(context, '/daily_summary'),
                                  tooltip: 'Günlük Özetimi Paylaş',
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Activity Cards
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              // Adım Sayar Kartı
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: AdvancedStepCounterCard(),
                              ),
                              const SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ExpandableActivityCard(
                                  title: 'Başarımlar',
                                  subtitle: 'Kazanılan rozet ve madalyalar',
                                  value: unlockedAchievements.toString(),
                                  unit: 'adet',
                                  icon: Icons.emoji_events,
                                  color: Colors.amber,
                                  type: ActivityCardType.achievements,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ExpandableActivityCard(
                                  title: 'Fitness Kalori',
                                  subtitle: 'Bugün yakılan kalori',
                                  value: dailyBurnedCalories.toInt().toString(),
                                  unit: 'kal',
                                  icon: Icons.fitness_center,
                                  color: palette.primary, // Dinamik renk
                                  type: ActivityCardType.fitness,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ExpandableActivityCard(
                                  title: 'Yemek Kalori',
                                  subtitle: 'Bugün alınan kalori',
                                  value: dailyIntakeCalories.toStringAsFixed(0),
                                  unit: 'kal',
                                  icon: Icons.restaurant,
                                  color: DynamicColors.error, // Sabit kırmızı kalori rengi
                                  type: ActivityCardType.food,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ExpandableActivityCard(
                                  title: 'Kalori Takip',
                                  subtitle: 'Net kalori dengesi',
                                  value: (dailyIntakeCalories - dailyBurnedCalories).toStringAsFixed(0),
                                  unit: 'kal',
                                  icon: Icons.track_changes,
                                  color: Colors.blueAccent,
                                  type: ActivityCardType.calorieTracking,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ExpandableActivityCard(
                                  title: 'Su Tüketimi',
                                  subtitle: '${(dailyWaterTarget * 1000).toInt()} ml hedef',
                                  value: (dailyWaterIntake * 1000).toInt().toString(),
                                  unit: 'ml',
                                  icon: Icons.water_drop,
                                  color: DynamicColors.info, // Sabit mavi su rengi
                                  type: ActivityCardType.water,
                                ),
                              ),
                              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    try {
      await Future.wait([
        Provider.of<UserProvider>(context, listen: false).loadUser(),
        Provider.of<FoodProvider>(context, listen: false).loadData(),
        Provider.of<ExerciseProvider>(context, listen: false).loadData(),
      ]);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veriler güncellendi'),
            backgroundColor: DynamicColors.success,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Güncelleme hatası: $e'),
            backgroundColor: DynamicColors.error,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }
}