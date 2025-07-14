// lib/services/notification_service.dart - REMİNDER PROVIDER ENTEGRASYONU
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'dart:typed_data';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  
  // Bildirim ID'leri
  static const int _stepReminderID = 1000;
  static const int _workoutReminderID = 1001;
  static const int _waterReminderBaseID = 1002; // Su hatırlatması için base ID

  Future<void> init() async {
    try {
      if (_isInitialized) {
        print('✅ Bildirim servisi zaten başlatılmış');
        return;
      }

      _prefs = await SharedPreferences.getInstance();
      
      // Timezone başlatma
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      final bool? initialized = await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          print('🔔 Bildirime tıklandı: ${response.payload}');
          await _handleNotificationTap(response);
        },
      );

      if (initialized == true) {
        await _requestPermissions();
        await _createNotificationChannels();
        
        _isInitialized = true;
        print('✅ Bildirim servisi başarıyla başlatıldı');
      } else {
        print('⚠️ Bildirim servisi başlatılamadı');
      }
      
    } catch (e, stackTrace) {
      print('❌ Bildirim servisi başlatma hatası: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _createNotificationChannels() async {
    // Hatırlatıcı kanalı - SES VE TİTREŞİM AKTİF
    const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      'formdakal_reminders',
      'FormdaKal Hatırlatıcılar',
      description: 'Spor, su içme ve adım hatırlatıcıları - Sesli ve titreşimli',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    // Anında bildirim kanalı
    const AndroidNotificationChannel instantChannel = AndroidNotificationChannel(
      'formdakal_instant',
      'FormdaKal Anında Bildirimler',
      description: 'Motivasyon ve başarı bildirimleri',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(instantChannel);

    print('✅ Bildirim kanalları oluşturuldu');
  }

  Future<void> _requestPermissions() async {
    try {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        print('📱 Bildirim izni durumu: $status');
      }
      
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        print('⏰ Alarm izni durumu: $status');
      }
    } catch (e) {
      print('⚠️ İzin isteme hatası: $e');
    }
  }

  Future<void> _handleNotificationTap(NotificationResponse response) async {
    final payload = response.payload;
    
    if (payload != null) {
      switch (payload) {
        case 'step_reminder':
          print('🦶 Adım hatırlatması tıklandı');
          break;
        case 'workout_reminder':
          print('💪 Egzersiz hatırlatması tıklandı');
          break;
        case 'water_reminder':
          print('💧 Su içme hatırlatması tıklandı');
          break;
      }
    }
  }

  // GENEL BİLDİRİM PLANLAMA FONKSİYONU
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isInitialized) {
      print('⚠️ Bildirim servisi henüz başlatılmamış');
      return;
    }

    final vibrationPattern = <int>[0, 1000, 500, 1000];

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'formdakal_reminders',
      'FormdaKal Hatırlatıcılar',
      channelDescription: 'Sistem hatırlatıcıları',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList(vibrationPattern),
      icon: '@mipmap/ic_launcher',
      autoCancel: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails,
        payload: payload,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Bildirim zamanlandı: $title - $scheduledTime');
    } catch (e) {
      print('❌ Bildirim zamanlama hatası: $e');
    }
  }

  // SİSTEM HATIRLATICILARI YÖNETİMİ
  Future<void> toggleReminderType(String type, bool isEnabled) async {
    try {
      if (isEnabled) {
        await _scheduleSystemReminder(type);
        print('✅ $type hatırlatması etkinleştirildi');
      } else {
        await _cancelSystemReminder(type);
        print('❌ $type hatırlatması devre dışı bırakıldı');
      }
    } catch (e) {
      print('❌ Hatırlatma ayar hatası: $e');
    }
  }

  Future<void> _scheduleSystemReminder(String type) async {
    final now = DateTime.now();
    
    switch (type) {
      case 'step':
        await _cancelSystemReminder('step'); // Önce eskiyi iptal et
        
        final stepHour = _prefs.getInt('step_reminder_hour') ?? 20;
        final stepMinute = _prefs.getInt('step_reminder_minute') ?? 0;
        var reminderTime = DateTime(now.year, now.month, now.day, stepHour, stepMinute);
        
        if (reminderTime.isBefore(now)) {
          reminderTime = reminderTime.add(const Duration(days: 1));
        }

        await scheduleNotification(
          id: _stepReminderID,
          title: '🦶 Adım Hedefin Nasıl?',
          body: 'Bugün henüz hedefe ulaşmadın. Biraz yürüyüş yapmaya ne dersin?',
          scheduledTime: reminderTime,
          payload: 'step_reminder',
        );
        break;

      case 'workout':
        await _cancelSystemReminder('workout'); // Önce eskiyi iptal et
        
        final workoutHour = _prefs.getInt('workout_reminder_hour') ?? 19;
        final workoutMinute = _prefs.getInt('workout_reminder_minute') ?? 0;
        var reminderTime = DateTime(now.year, now.month, now.day, workoutHour, workoutMinute);
        
        if (reminderTime.isBefore(now)) {
          reminderTime = reminderTime.add(const Duration(days: 1));
        }

        await scheduleNotification(
          id: _workoutReminderID,
          title: '💪 Spor Zamanı!',
          body: 'Bugün egzersiz yapmayı unutma. Formda kalmak için harekete geç!',
          scheduledTime: reminderTime,
          payload: 'workout_reminder',
        );
        break;

      case 'water':
        await _scheduleWaterReminders();
        break;
    }
  }

  Future<void> _scheduleWaterReminders() async {
    // Önce mevcut su hatırlatmalarını iptal et
    await _cancelSystemReminder('water');
    
    final startHour = _prefs.getInt('water_start_hour') ?? 8;
    final startMinute = _prefs.getInt('water_start_minute') ?? 0;
    final endHour = _prefs.getInt('water_end_hour') ?? 22;
    final endMinute = _prefs.getInt('water_end_minute') ?? 0;
    final intervalMinutes = _prefs.getInt('water_reminder_interval') ?? 120;

    final waterMessages = [
      '💧 Su içme zamanı! Vücudunu susuz bırakma.',
      '🥤 Hidrasyon önemli! Biraz su iç.',
      '💦 Su içmeyi unutma! Sağlığın için önemli.',
      '🚰 Su bardağını doldur ve iç!',
    ];

    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, startHour, startMinute);
    final endTime = DateTime(now.year, now.month, now.day, endHour, endMinute);

    var currentTime = startTime;
    int reminderCount = 0;

    while (currentTime.isBefore(endTime) && reminderCount < 20) { // Maksimum 20 hatırlatma
      if (currentTime.isAfter(now)) { // Sadece gelecekteki saatler için planla
        final randomMessage = waterMessages[Random().nextInt(waterMessages.length)];
        
        await scheduleNotification(
          id: _waterReminderBaseID + reminderCount,
          title: 'Su İçme Hatırlatması',
          body: randomMessage,
          scheduledTime: currentTime,
          payload: 'water_reminder',
        );
      } else if (currentTime.isBefore(now)) {
        // Bugün geçmiş saatler için yarına planla
        final tomorrowTime = currentTime.add(const Duration(days: 1));
        final randomMessage = waterMessages[Random().nextInt(waterMessages.length)];
        
        await scheduleNotification(
          id: _waterReminderBaseID + reminderCount,
          title: 'Su İçme Hatırlatması',
          body: randomMessage,
          scheduledTime: tomorrowTime,
          payload: 'water_reminder',
        );
      }

      currentTime = currentTime.add(Duration(minutes: intervalMinutes));
      reminderCount++;
    }

    print('✅ $reminderCount su içme hatırlatması zamanlandı (${intervalMinutes}dk aralıklarla)');
  }

  Future<void> _cancelSystemReminder(String type) async {
    try {
      switch (type) {
        case 'step':
          await cancelNotification(_stepReminderID);
          break;
        case 'workout':
          await cancelNotification(_workoutReminderID);
          break;
        case 'water':
          // Su hatırlatmaları için 20 ID'yi iptal et
          for (int i = 0; i < 20; i++) {
            await cancelNotification(_waterReminderBaseID + i);
          }
          break;
      }
    } catch (e) {
      print('❌ Hatırlatma iptal hatası: $e');
    }
  }

  // ANINDA BİLDİRİM
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      print('⚠️ Bildirim servisi başlatılmamış');
      return;
    }

    final vibrationPattern = <int>[0, 1000, 500, 1000];

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'formdakal_instant',
      'FormdaKal Anında Bildirimler',
      channelDescription: 'Anında bildirimler ve motivasyon mesajları',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      vibrationPattern: Int64List.fromList(vibrationPattern),
      icon: '@mipmap/ic_launcher',
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      
      print('✅ Anında bildirim gönderildi: $title');
    } catch (e) {
      print('❌ Anında bildirim hatası: $e');
    }
  }

  // TEST FONKSİYONLARI
  Future<void> sendTestReminderNotification() async {
    await showInstantNotification(
      id: 8888,
      title: '🧪 Test Hatırlatıcısı',
      body: 'Bu bir test hatırlatıcısıdır. Ses ve titreşim çalışıyor mu?',
      payload: 'test_reminder',
    );
  }

  Future<void> sendTestNotification() async {
    await showInstantNotification(
      id: 9999,
      title: '🧪 Test Bildirimi',
      body: 'FormdaKal bildirimleri çalışıyor! ✅',
      payload: 'test',
    );
  }

  // MOTİVASYON BİLDİRİMLERİ
  Future<void> sendMotivationNotification(String type) async {
    if (!_isInitialized) return;

    String title, body;
    
    switch (type) {
      case 'step_milestone':
        title = '🎉 Harika! Adım Hedefine Ulaştın!';
        body = 'Bugün 8000 adım attın! Muhteşem bir performans!';
        break;
      case 'workout_completed':
        title = '💪 Egzersiz Tamamlandı!';
        body = 'Harika bir antrenman geçirdin! Kendini ödüllendirmeyi unutma.';
        break;
      case 'weekly_progress':
        title = '📊 Haftalık Rapor Hazır!';
        body = 'Bu haftaki ilerlemen muhteşem! Raporunu kontrol et.';
        break;
      default:
        title = '🎯 Motivasyon';
        body = 'Hedeflerine ulaşmak için bir adım daha!';
    }

    await showInstantNotification(
      id: Random().nextInt(1000) + 3000,
      title: title,
      body: body,
      payload: type,
    );
  }

  // GENEL YÖNETİM FONKSİYONLARI
  Future<void> cancelNotification(int id) async {
    if (!_isInitialized) return;
    
    try {
      await _notifications.cancel(id);
      print('🗑️ Bildirim iptal edildi: ID $id');
    } catch (e) {
      print('❌ Bildirim iptal hatası: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    
    try {
      await _notifications.cancelAll();
      print('🗑️ Tüm bildirimler iptal edildi');
    } catch (e) {
      print('❌ Tüm bildirim iptal hatası: $e');
    }
  }

  bool get isInitialized => _isInitialized;
}