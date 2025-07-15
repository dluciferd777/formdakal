// lib/main.dart (PROVIDER DÜZELTİLMİŞ VERSİYON + FitProfileProvider)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formdakal/models/workout_plan_model.dart';
import 'package:formdakal/providers/achievement_provider.dart';
import 'package:formdakal/providers/exercise_provider.dart';
import 'package:formdakal/providers/food_provider.dart';
import 'package:formdakal/providers/measurement_provider.dart';
import 'package:formdakal/providers/progress_photo_provider.dart';
import 'package:formdakal/providers/reminder_provider.dart';
import 'package:formdakal/providers/step_counter_provider.dart';
import 'package:formdakal/providers/theme_provider.dart';
import 'package:formdakal/providers/user_provider.dart';
import 'package:formdakal/providers/workout_plan_provider.dart';
import 'package:formdakal/providers/social_provider.dart'; // YENİ: Sosyal provider eklendi
import 'package:formdakal/services/notification_service.dart';
import 'package:formdakal/screens/achievements_screen.dart';
import 'package:formdakal/screens/calorie_tracking_screen.dart';
import 'package:formdakal/screens/daily_summary_screen.dart';
import 'package:formdakal/screens/fitness_screen.dart';
import 'package:formdakal/screens/food_calories_screen.dart';
import 'package:formdakal/screens/home_screen.dart';
import 'package:formdakal/screens/measurement_screen.dart';
import 'package:formdakal/screens/onboarding_screen.dart';
import 'package:formdakal/screens/profile_screen.dart';
import 'package:formdakal/screens/progress_photos_screen.dart';
import 'package:formdakal/screens/reminder_screen.dart';
import 'package:formdakal/screens/reports_screen.dart';
import 'package:formdakal/screens/select_exercise_screen.dart';
import 'package:formdakal/screens/splash_screen.dart';
import 'package:formdakal/screens/step_details_screen.dart';
import 'package:formdakal/screens/workout_plan_details_screen.dart';
import 'package:formdakal/screens/workout_plans_list_screen.dart';
import 'package:formdakal/screens/fit_profile_screen.dart'; // YENİ: Fit profile screen eklendi
import 'package:formdakal/utils/color_themes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/fitness_bilgilerim_page.dart';

Future<void> requestEssentialPermissions() async {
  var activityStatus = await Permission.activityRecognition.status;
  if (!activityStatus.isGranted) {
    activityStatus = await Permission.activityRecognition.request();
  }

  var notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    notificationStatus = await Permission.notification.request();
  }

  if (activityStatus.isGranted) {
    print("✅ Fiziksel Aktivite izni alındı.");
  } else {
    print("❌ Fiziksel Aktivite izni reddedildi.");
  }
  
  if (notificationStatus.isGranted) {
    print("✅ Bildirim izni alındı.");
  } else {
    print("❌ Bildirim izni reddedildi.");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await requestEssentialPermissions();
  
  await NotificationService().init(); 

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );
  
  await initializeDateFormatting('tr_TR', null);
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPreferences prefs;
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Temel provider'lar
        ChangeNotifierProvider(create: (_) => ThemeProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => ReminderProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => MeasurementProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => ProgressPhotoProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => AchievementProvider(widget.prefs)),
        ChangeNotifierProvider(create: (_) => StepCounterProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()), // YENİ: Sosyal provider eklendi
        
        // Bağımlılığı olan provider'lar
        ChangeNotifierProxyProvider<AchievementProvider, UserProvider>(
          create: (context) => UserProvider(widget.prefs, Provider.of<AchievementProvider>(context, listen: false)),
          update: (_, achievement, previous) => previous!..updateDependencies(achievement),
        ),
        
        ChangeNotifierProxyProvider3<AchievementProvider, UserProvider, StepCounterProvider, ExerciseProvider>(
          create: (context) => ExerciseProvider(widget.prefs,
            Provider.of<AchievementProvider>(context, listen: false),
            Provider.of<UserProvider>(context, listen: false),
            Provider.of<StepCounterProvider>(context, listen: false),
          ),
          update: (_, achievement, user, stepCounter, previous) => previous!..updateDependencies(achievement, user, stepCounter),
        ),
        
        ChangeNotifierProxyProvider<AchievementProvider, FoodProvider>(
          create: (context) => FoodProvider(widget.prefs, Provider.of<AchievementProvider>(context, listen: false)),
          update: (_, achievement, previous) => previous!..updateDependencies(achievement),
        ),
        
        ChangeNotifierProxyProvider3<AchievementProvider, UserProvider, ExerciseProvider, WorkoutPlanProvider>(
          create: (context) => WorkoutPlanProvider(widget.prefs,
            Provider.of<AchievementProvider>(context, listen: false),
            Provider.of<UserProvider>(context, listen: false),
            Provider.of<ExerciseProvider>(context, listen: false),
          ),
          update: (_, achievement, user, exercise, previous) => previous!..updateDependencies(achievement, user, exercise),
        ),

        ChangeNotifierProxyProvider<UserProvider, StepCounterProvider>(
          create: (_) => StepCounterProvider(),
          update: (_, userProvider, stepProvider) {
            stepProvider?.setUserProvider(userProvider);
            return stepProvider!;
          },
         ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'FormdaKal',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light().copyWith(primaryColor: DynamicColors.primary),
            darkTheme: ThemeData.dark().copyWith(primaryColor: DynamicColors.primary),
            home: const SplashScreen(),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/home': (context) => const HomeScreen(),
              '/fitness': (context) => const FitnessScreen(),
              '/food_calories': (context) => const FoodCaloriesScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/fit_profile': (context) => const FitProfileScreen(), // YENİ: Fit profile route eklendi
              '/calorie_tracking': (context) => const CalorieTrackingScreen(),
              '/reminders': (context) => const ReminderScreen(),
              '/measurements': (context) => const MeasurementScreen(),
              '/progress_photos': (context) => const ProgressPhotosScreen(),
              '/reports': (context) => const ReportsScreen(),
              '/workout_plans': (context) => const WorkoutPlansListScreen(),
              '/workout_plan_details': (context) => WorkoutPlanDetailsScreen(plan: ModalRoute.of(context)!.settings.arguments as WorkoutPlanModel),
              '/select_exercise': (context) => const SelectExerciseScreen(),
              '/achievements': (context) => const AchievementsScreen(),
              '/step_details': (context) => const StepDetailsScreen(),
              '/daily_summary': (context) => const DailySummaryScreen(),
              '/fitness_bilgilerim': (context) => const FitnessBilgilerimPage(),

            },
          );
        },
      ),
    );
  }
}