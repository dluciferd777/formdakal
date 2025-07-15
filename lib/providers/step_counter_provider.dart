// lib/providers/step_counter_provider.dart - USER VERİLERİNİ KULLANIYOR
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/calorie_service.dart';
import '../providers/user_provider.dart';

class StepCounterProvider with ChangeNotifier {
  StreamSubscription<StepCount>? _stepCountSubscription;
  UserProvider? _userProvider; // UserProvider referansı

  int _dailySteps = 0;
  String _permissionStatus = 'Başlatılıyor...';
  bool _goalReachedNotified = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  int get dailySteps => _dailySteps;
  String get permissionStatus => _permissionStatus;
  
  // Dinamik hedef - kullanıcının aktivite seviyesine göre
  int get goal {
    if (_userProvider?.user != null) {
      return _userProvider!.user!.dailyStepGoal;
    }
    return 6000; // Varsayılan
  }

  StepCounterProvider() {
    _initialize();
  }

  // UserProvider bağlantısı
  void setUserProvider(UserProvider userProvider) {
    _userProvider = userProvider;
    notifyListeners();
  }

  Future<void> _initialize() async {
    await _initializeNotifications();
    await _requestPermissions();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('🔔 Bildirime tıklandı: ${response.payload}');
      },
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel persistentChannel = AndroidNotificationChannel(
      'formdakal_step_channel',
      'FormdaKal Adım Sayar',
      description: 'Anlık adım sayısını gösterir',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    const AndroidNotificationChannel goalChannel = AndroidNotificationChannel(
      'formdakal_goal_channel',
      'FormdaKal Hedef Bildirimleri',
      description: 'Adım hedefi tamamlandığında ses ve titreşimle bildirir',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(persistentChannel);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(goalChannel);
  }

  Future<void> _requestPermissions() async {
    var activityStatus = await Permission.activityRecognition.request();
    await Permission.notification.request();
    
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    if (activityStatus.isGranted) {
      _permissionStatus = 'İzin verildi.';
      _startPedometer();
    } else {
      _permissionStatus = 'Fiziksel aktivite izni gerekli.';
    }
    notifyListeners();
  }

  Future<void> _startPedometer() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      StepCount event = await Pedometer.stepCountStream.first;
      int currentTotalSteps = event.steps;
      String lastSavedDate = prefs.getString('formdakal_step_last_saved_date') ?? '';
      String today = DateTime.now().toIso8601String().substring(0, 10);

      if (lastSavedDate != today) {
        await prefs.setInt('formdakal_step_initial_count', currentTotalSteps);
        await prefs.setString('formdakal_step_last_saved_date', today);
        _goalReachedNotified = false;
        await prefs.setBool('goal_reached_today', false);
      } else {
        _goalReachedNotified = prefs.getBool('goal_reached_today') ?? false;
      }
      
      int storedInitialSteps = prefs.getInt('formdakal_step_initial_count') ?? currentTotalSteps;

      _stepCountSubscription = Pedometer.stepCountStream.listen((StepCount event) {
        _onStepCount(event, storedInitialSteps);
      })..onError((error) {
        _permissionStatus = 'Sensör hatası: $error';
        notifyListeners();
      });
    } catch (e) {
      _permissionStatus = 'Pedometer başlatılamadı: $e';
      notifyListeners();
    }
  }

  void _onStepCount(StepCount event, int initialSteps) {
    _dailySteps = event.steps - initialSteps;
    if (_dailySteps < 0) _dailySteps = 0;
    
    _showPersistentNotification();
    _checkGoal();
    notifyListeners();
  }

  void _checkGoal() async {
    if (_dailySteps >= goal && !_goalReachedNotified) {
      await _showGoalReachedNotification();
      _goalReachedNotified = true;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('goal_reached_today', true);
    }
  }

  Future<void> _showPersistentNotification() async {
    const AndroidNotificationDetails details = AndroidNotificationDetails(
      'formdakal_step_channel',
      'FormdaKal Adım Sayar',
      channelDescription: 'Anlık adım sayısını gösterir.',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      enableVibration: false,
      playSound: false,
    );

    await _notificationsPlugin.show(
      0,
      'FormdaKal: $_dailySteps adım',
      'Hedef: $goal adım',
      const NotificationDetails(android: details),
    );
  }

  Future<void> _showGoalReachedNotification() async {
    await HapticFeedback.heavyImpact();
    
    final vibrationPattern = <int>[0, 1000, 500, 1000];
    
    final AndroidNotificationDetails details = AndroidNotificationDetails(
      'formdakal_goal_channel',
      'FormdaKal Hedef Bildirimleri',
      channelDescription: 'Adım hedefi tamamlandığında bildirir',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList(vibrationPattern),
      autoCancel: false,
      ongoing: false,
      ticker: 'Hedef Tamamlandı!',
      fullScreenIntent: true,
    );

    await _notificationsPlugin.show(
      1,
      '🎉 TEBRİKLER!',
      'Harika! $goal adım hedefini tamamladın! 🚀',
      NotificationDetails(android: details),
      payload: 'goal_reached',
    );
  }

  Future<void> sendTestNotification() async {
    await HapticFeedback.heavyImpact();
    
    final vibrationPattern = <int>[0, 1000, 500, 1000];
    
    final AndroidNotificationDetails details = AndroidNotificationDetails(
      'formdakal_goal_channel',
      'FormdaKal Hedef Bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList(vibrationPattern),
    );

    await _notificationsPlugin.show(
      999,
      '🧪 Test Bildirimi',
      'Bu bir test bildirimidir. Ses ve titreşim çalışıyor mu?',
      NotificationDetails(android: details),
    );
  }

  // GELİŞTİRİLMİŞ KALORİ HESAPLAMASI - UserProvider verilerini kullanıyor
  double getCaloriesFromSteps() {
    if (_userProvider?.user != null && _dailySteps > 0) {
      final user = _userProvider!.user!;
      return CalorieService.calculateAdvancedStepCalories(
        steps: _dailySteps,
        weight: user.weight,
        height: user.height,
        age: user.age,
        gender: user.gender,
        activityLevel: user.activityLevel,
      );
    }
    // Varsayılan hesaplama
    return _dailySteps * 0.04;
  }
  
  double getDistanceFromSteps() {
    if (_userProvider?.user != null) {
      final user = _userProvider!.user!;
      // Cinsiyet bazlı adım uzunluğu
      double strideLength;
      if (user.gender == 'male') {
        strideLength = user.height * 0.415; // cm
      } else {
        strideLength = user.height * 0.413; // cm
      }
      return (_dailySteps * strideLength / 100) / 1000; // km
    }
    // Varsayılan hesaplama
    return _dailySteps * 0.000762;
  }
  
  int getActiveMinutes() {
    // Daha gerçekçi hesaplama - 100 adım = 1 dakika yerine 120 adım = 1 dakika
    return (_dailySteps / 120).round();
  }

  // Adım detaylarını alma
  Map<String, dynamic> getStepDetails() {
    if (_userProvider?.user != null && _dailySteps > 0) {
      final user = _userProvider!.user!;
      return CalorieService.getStepCalorieDetails(
        steps: _dailySteps,
        weight: user.weight,
        height: user.height,
        age: user.age,
        gender: user.gender,
        activityLevel: user.activityLevel,
      );
    }
    return {};
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    super.dispose();
  }
}