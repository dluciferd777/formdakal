// lib/providers/step_counter_provider.dart - HATASIZ VERSİYON
import 'dart:async';
import 'dart:typed_data'; // Int64List için eklendi
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterProvider with ChangeNotifier {
  StreamSubscription<StepCount>? _stepCountSubscription;

  int _dailySteps = 0;
  String _permissionStatus = 'Başlatılıyor...';
  
  final int _goal = 8000;
  bool _goalReachedNotified = false;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  int get dailySteps => _dailySteps;
  String get permissionStatus => _permissionStatus;
  int get goal => _goal;

  StepCounterProvider() {
    _initialize();
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
    // Sürekli bildirim kanalı
    const AndroidNotificationChannel persistentChannel = AndroidNotificationChannel(
      'formdakal_step_channel',
      'FormdaKal Adım Sayar',
      description: 'Anlık adım sayısını gösterir',
      importance: Importance.low,
      enableVibration: false,
      playSound: false,
    );

    // Hedef bildirimi kanalı - ses ve titreşim aktif
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

    print('✅ Bildirim kanalları oluşturuldu');
  }

  Future<void> _requestPermissions() async {
    var activityStatus = await Permission.activityRecognition.request();
    await Permission.notification.request(); // Kullanılmayan değişken kaldırıldı
    
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
    if (_dailySteps >= _goal && !_goalReachedNotified) {
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
      'Hedef: $_goal adım',
      const NotificationDetails(android: details),
    );
  }

  Future<void> _showGoalReachedNotification() async {
    // Haptic feedback ekle
    await HapticFeedback.heavyImpact();
    
    // Titreşim pattern - Int64List yerine List<int> kullan
    final vibrationPattern = <int>[0, 1000, 500, 1000];
    
    final AndroidNotificationDetails details = AndroidNotificationDetails(
      'formdakal_goal_channel',
      'FormdaKal Hedef Bildirimleri',
      channelDescription: 'Adım hedefi tamamlandığında bildirir',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList(vibrationPattern), // Doğru kullanım
      autoCancel: false,
      ongoing: false,
      ticker: 'Hedef Tamamlandı!',
      fullScreenIntent: true,
    );

    await _notificationsPlugin.show(
      1,
      '🎉 TEBRİKLER!',
      'Harika! $_goal adım hedefini tamamladın! 🚀',
      NotificationDetails(android: details), // const kaldırıldı
      payload: 'goal_reached',
    );

    print('🎯 Hedef bildirimi gönderildi: $_dailySteps adım');
  }

  // Test bildirimi fonksiyonu
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
      NotificationDetails(android: details), // const kaldırıldı
    );
  }

  double getCaloriesFromSteps() {
    return _dailySteps * 0.04;
  }
  
  double getDistanceFromSteps() {
    return _dailySteps * 0.000762;
  }
  
  int getActiveMinutes() {
    return (_dailySteps / 100).round();
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    super.dispose();
  }
}