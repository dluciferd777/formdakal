// lib/widgets/activity_calendar.dart - MACROS MODUNDA STATS GİZLİ
import 'package:flutter/material.dart';
import 'package:formdakal/providers/exercise_provider.dart';
import 'package:formdakal/providers/food_provider.dart';
import 'package:formdakal/providers/user_provider.dart';
import 'package:formdakal/utils/colors.dart';
import 'package:formdakal/widgets/activity_ring_painter.dart';
import 'package:formdakal/providers/step_counter_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

enum CalendarMode { activity, macros }

class ActivityCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final CalendarMode mode;
  final bool showStats;

  const ActivityCalendar({
    super.key,
    required this.onDateSelected,
    this.mode = CalendarMode.activity,
    this.showStats = true,
  });

  @override
  State<ActivityCalendar> createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<ActivityCalendar> {
  late DateTime _selectedDate;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _currentWeekStart = _getWeekStart(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateSelected(_selectedDate);
    });
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _changeWeek(int weeks) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: weeks * 7));
      _selectedDate = _currentWeekStart;
      widget.onDateSelected(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          _buildHeader(theme),
          const SizedBox(height: 8),
          _buildWeekDays(theme),
          // DÜZELTME: Macros modunda stats gösterme
          if (widget.showStats && widget.mode != CalendarMode.macros) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            _buildStatsRow(),
          ]
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            DateFormat('MMMM yyyy', 'tr_TR').format(_currentWeekStart),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold, 
              fontSize: 16
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _changeWeek(-1), 
              icon: const Icon(Icons.chevron_left), 
              visualDensity: VisualDensity.compact
            ),
            IconButton(
              onPressed: () => _changeWeek(1), 
              icon: const Icon(Icons.chevron_right), 
              visualDensity: VisualDensity.compact
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeekDays(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final date = _currentWeekStart.add(Duration(days: index));
        return _buildDayItem(date, theme);
      }),
    );
  }

  Widget _buildDayItem(DateTime date, ThemeData theme) {
    final isSelected = DateUtils.isSameDay(date, _selectedDate);
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: () {
        setState(() => _selectedDate = date);
        widget.onDateSelected(date);
      },
      child: Column(
        children: [
          Text(
            DateFormat('E', 'tr_TR').format(date).substring(0, 1), 
            style: theme.textTheme.bodySmall?.copyWith(
              color: isToday ? AppColors.primaryGreen : null
            )
          ),
          const SizedBox(height: 6),
          _buildActivityRingForDay(date),
          const SizedBox(height: 6),
          Container(
            height: 24, 
            width: 24,
            decoration: isSelected 
                ? const BoxDecoration(
                    color: AppColors.primaryGreen, 
                    shape: BoxShape.circle
                  ) 
                : null,
            child: Center(
              child: Text(
                date.day.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                  color: isSelected ? Colors.white : null
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRingForDay(DateTime date) {
    return Consumer4<UserProvider, FoodProvider, ExerciseProvider, StepCounterProvider>(
      builder: (context, userProvider, foodProvider, exerciseProvider, stepProvider, child) {
        final user = userProvider.user;
        final bool isToday = DateUtils.isSameDay(date, DateTime.now());
        
        if (widget.mode == CalendarMode.macros) {
          // YEMEK SAYFASI İÇİN: Besin değerleri
          final allMeals = [
            ...foodProvider.getMealFoods(date, 'breakfast'),
            ...foodProvider.getMealFoods(date, 'lunch'),
            ...foodProvider.getMealFoods(date, 'dinner'),
            ...foodProvider.getMealFoods(date, 'snack'),
          ];
          
          final consumedCalories = allMeals.fold(0.0, (sum, food) => sum + food.totalCalories);
          final totalProtein = allMeals.fold(0.0, (sum, food) => sum + food.totalProtein);
          final totalCarbs = allMeals.fold(0.0, (sum, food) => sum + food.totalCarbs);
          // Yağ değişkeni kaldırıldı çünkü sadece 3 halka var
          
          // Hedefler
          final calorieGoal = user?.dailyCalorieNeeds ?? 2000;
          final proteinGoal = (user?.weight ?? 70) * 1.6; // 1.6g/kg
          final carbGoal = calorieGoal * 0.5 / 4; // Kalorinin %50'si
          
          final double calorieProgress = (consumedCalories / calorieGoal).clamp(0.0, 1.0);
          final double proteinProgress = (totalProtein / proteinGoal).clamp(0.0, 1.0);
          final double carbProgress = (totalCarbs / carbGoal).clamp(0.0, 1.0);

          return SizedBox(
            width: 45, 
            height: 45,
            child: CustomPaint(
              painter: ActivityRingPainter(
                outerProgress: calorieProgress,    // Dış halka: Kalori
                middleProgress: proteinProgress,   // Orta halka: Protein  
                innerProgress: carbProgress,       // İç halka: Karbonhidrat
                outerColor: Colors.red,            // Kalori → Kırmızı
                middleColor: Colors.green,         // Protein → Yeşil
                innerColor: Colors.blue,           // Karbonhidrat → Mavi
                showGlow: true, 
                customStrokeWidth: 3,
              ),
            ),
          );
        } else {
          // ANA SAYFA İÇİN: Adım, Yemek Kalori, Fitness
          final steps = isToday ? stepProvider.dailySteps : 0;
          final stepGoal = user?.dailyStepGoal ?? 6000;
          final consumedCalories = foodProvider.getDailyCalories(date);
          final calorieIntakeGoal = user?.dailyCalorieNeeds ?? 2000;
          final burnedCalories = exerciseProvider.getDailyBurnedCalories(date);
          final calorieBurnGoal = (user?.dailyCalorieNeeds ?? 2000) * 0.25;

          final double stepProgress = (steps / stepGoal).clamp(0.0, 1.0);
          final double foodProgress = (consumedCalories / calorieIntakeGoal).clamp(0.0, 1.0);
          final double fitnessProgress = (burnedCalories / calorieBurnGoal).clamp(0.0, 1.0);

          return SizedBox(
            width: 45, 
            height: 45,
            child: CustomPaint(
              painter: ActivityRingPainter(
                outerProgress: stepProgress,       // Dış halka: Adım
                middleProgress: foodProgress,      // Orta halka: Yemek Kalori
                innerProgress: fitnessProgress,    // İç halka: Fitness
                outerColor: Colors.green,          // Adım → Yeşil
                middleColor: Colors.red,           // Yemek Kalori → Kırmızı
                innerColor: Colors.purple,         // Fitness → Mor
                showGlow: true, 
                customStrokeWidth: 3,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildStatsRow() {
    return Consumer3<FoodProvider, ExerciseProvider, StepCounterProvider>(
      builder: (context, foodProvider, exerciseProvider, stepProvider, child) {
        final bool isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
        final consumed = foodProvider.getDailyCalories(_selectedDate);
        final burned = exerciseProvider.getDailyBurnedCalories(_selectedDate);
        final steps = isToday ? stepProvider.dailySteps : 0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(context, 'Alınan', '${consumed.toInt()} kal', AppColors.calorieColor),
            _buildStatItem(context, 'Yakılan', '${burned.toInt()} kal', Colors.orange),
            _buildStatItem(context, 'Adım', '$steps', AppColors.stepColor),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label, 
          style: Theme.of(context).textTheme.bodySmall
        ),
        const SizedBox(height: 4),
        Text(
          value, 
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color, 
            fontWeight: FontWeight.bold
          )
        ),
      ],
    );
  }
}