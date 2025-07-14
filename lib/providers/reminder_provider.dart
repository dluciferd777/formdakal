// lib/providers/reminder_provider.dart - SİSTEM HATIRLATICILAR EKLENDİ
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';
import '../services/notification_service.dart';

class ReminderProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  List<Reminder> _reminders = [];

  // SİSTEM HATIRLATICI AYARLARI
  bool _isStepReminderEnabled = true;
  bool _isWorkoutReminderEnabled = true;
  bool _isWaterReminderEnabled = true;
  
  TimeOfDay _stepReminderTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _workoutReminderTime = const TimeOfDay(hour: 19, minute: 0);
  TimeOfDay _waterReminderStartTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _waterReminderEndTime = const TimeOfDay(hour: 22, minute: 0);
  int _waterReminderInterval = 120; // dakika

  ReminderProvider(this._prefs) {
    _loadReminders();
    _loadSystemReminderSettings();
  }

  // GETTER'LAR
  List<Reminder> get reminders => _reminders;
  
  bool get isStepReminderEnabled => _isStepReminderEnabled;
  bool get isWorkoutReminderEnabled => _isWorkoutReminderEnabled;
  bool get isWaterReminderEnabled => _isWaterReminderEnabled;
  
  TimeOfDay get stepReminderTime => _stepReminderTime;
  TimeOfDay get workoutReminderTime => _workoutReminderTime;
  TimeOfDay get waterReminderStartTime => _waterReminderStartTime;
  TimeOfDay get waterReminderEndTime => _waterReminderEndTime;
  int get waterReminderInterval => _waterReminderInterval;

  // SİSTEM HATIRLATICI AYARLARINI YÜKLE
  Future<void> _loadSystemReminderSettings() async {
    try {
      _isStepReminderEnabled = _prefs.getBool('step_reminder_enabled') ?? true;
      _isWorkoutReminderEnabled = _prefs.getBool('workout_reminder_enabled') ?? true;
      _isWaterReminderEnabled = _prefs.getBool('water_reminder_enabled') ?? true;
      
      // Saatleri yükle
      final stepHour = _prefs.getInt('step_reminder_hour') ?? 20;
      final stepMinute = _prefs.getInt('step_reminder_minute') ?? 0;
      _stepReminderTime = TimeOfDay(hour: stepHour, minute: stepMinute);
      
      final workoutHour = _prefs.getInt('workout_reminder_hour') ?? 19;
      final workoutMinute = _prefs.getInt('workout_reminder_minute') ?? 0;
      _workoutReminderTime = TimeOfDay(hour: workoutHour, minute: workoutMinute);
      
      final waterStartHour = _prefs.getInt('water_start_hour') ?? 8;
      final waterStartMinute = _prefs.getInt('water_start_minute') ?? 0;
      _waterReminderStartTime = TimeOfDay(hour: waterStartHour, minute: waterStartMinute);
      
      final waterEndHour = _prefs.getInt('water_end_hour') ?? 22;
      final waterEndMinute = _prefs.getInt('water_end_minute') ?? 0;
      _waterReminderEndTime = TimeOfDay(hour: waterEndHour, minute: waterEndMinute);
      
      _waterReminderInterval = _prefs.getInt('water_reminder_interval') ?? 120;
      
      notifyListeners();
    } catch (e) {
      print('Sistem hatırlatıcı ayarları yükleme hatası: $e');
    }
  }

  // ADIM HATIRLATICI AYARLARI
  Future<void> setStepReminderEnabled(bool enabled) async {
    _isStepReminderEnabled = enabled;
    await _prefs.setBool('step_reminder_enabled', enabled);
    notifyListeners();
  }

  Future<void> setStepReminderTime(TimeOfDay time) async {
    _stepReminderTime = time;
    await _prefs.setInt('step_reminder_hour', time.hour);
    await _prefs.setInt('step_reminder_minute', time.minute);
    notifyListeners();
  }

  // EGZERSİZ HATIRLATICI AYARLARI
  Future<void> setWorkoutReminderEnabled(bool enabled) async {
    _isWorkoutReminderEnabled = enabled;
    await _prefs.setBool('workout_reminder_enabled', enabled);
    notifyListeners();
  }

  Future<void> setWorkoutReminderTime(TimeOfDay time) async {
    _workoutReminderTime = time;
    await _prefs.setInt('workout_reminder_hour', time.hour);
    await _prefs.setInt('workout_reminder_minute', time.minute);
    notifyListeners();
  }

  // SU İÇME HATIRLATICI AYARLARI
  Future<void> setWaterReminderEnabled(bool enabled) async {
    _isWaterReminderEnabled = enabled;
    await _prefs.setBool('water_reminder_enabled', enabled);
    notifyListeners();
  }

  Future<void> setWaterReminderStartTime(TimeOfDay time) async {
    _waterReminderStartTime = time;
    await _prefs.setInt('water_start_hour', time.hour);
    await _prefs.setInt('water_start_minute', time.minute);
    notifyListeners();
  }

  Future<void> setWaterReminderEndTime(TimeOfDay time) async {
    _waterReminderEndTime = time;
    await _prefs.setInt('water_end_hour', time.hour);
    await _prefs.setInt('water_end_minute', time.minute);
    notifyListeners();
  }

  Future<void> setWaterReminderInterval(int intervalMinutes) async {
    _waterReminderInterval = intervalMinutes;
    await _prefs.setInt('water_reminder_interval', intervalMinutes);
    notifyListeners();
  }

  // MEVCUT FONKSİYONLAR (CUSTOM HATIRLATMALAR İÇİN)
  Future<void> _loadReminders() async {
    try {
      final remindersJson = _prefs.getString('reminders');
      if (remindersJson != null) {
        final List<dynamic> decoded = jsonDecode(remindersJson);
        _reminders = decoded.map((item) => Reminder.fromJson(item)).toList();
        await _rescheduleActiveReminders();
      }
      notifyListeners();
    } catch (e) {
      print('Hatırlatıcı yükleme hatası: $e');
    }
  }

  Future<void> _saveReminders() async {
    try {
      final jsonList = _reminders.map((reminder) => reminder.toJson()).toList();
      await _prefs.setString('reminders', jsonEncode(jsonList));
    } catch (e) {
      print('Hatırlatıcı kaydetme hatası: $e');
    }
  }

  Future<void> _rescheduleActiveReminders() async {
    try {
      for (final reminder in _reminders) {
        await NotificationService().cancelNotification(reminder.id.hashCode);
      }

      for (final reminder in _reminders) {
        if (reminder.isActive && reminder.reminderDateTime.isAfter(DateTime.now())) {
          await _scheduleNotification(reminder);
        }
      }
    } catch (e) {
      print('Hatırlatma yeniden planlama hatası: $e');
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      _reminders.add(reminder);
      await _saveReminders();
      
      if (reminder.isActive && reminder.reminderDateTime.isAfter(DateTime.now())) {
        await _scheduleNotification(reminder);
      }
      
      notifyListeners();
    } catch (e) {
      print('Hatırlatıcı ekleme hatası: $e');
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder updatedReminder) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == updatedReminder.id);
      if (index != -1) {
        await NotificationService().cancelNotification(updatedReminder.id.hashCode);
        
        _reminders[index] = updatedReminder;
        await _saveReminders();
        
        if (updatedReminder.isActive && updatedReminder.reminderDateTime.isAfter(DateTime.now())) {
          await _scheduleNotification(updatedReminder);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Hatırlatıcı güncelleme hatası: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      final reminder = _reminders.firstWhere((r) => r.id == reminderId);
      
      await NotificationService().cancelNotification(reminder.id.hashCode);
      
      _reminders.removeWhere((r) => r.id == reminderId);
      await _saveReminders();
      notifyListeners();
    } catch (e) {
      print('Hatırlatıcı silme hatası: $e');
      rethrow;
    }
  }

  Future<void> toggleReminderStatus(String reminderId, bool isActive) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index != -1) {
        _reminders[index].isActive = isActive;
        await _saveReminders();
        
        if (isActive && _reminders[index].reminderDateTime.isAfter(DateTime.now())) {
          await _scheduleNotification(_reminders[index]);
        } else {
          await NotificationService().cancelNotification(_reminders[index].id.hashCode);
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Hatırlatıcı durumu değiştirme hatası: $e');
      rethrow;
    }
  }

  Future<void> _scheduleNotification(Reminder reminder) async {
    try {
      await NotificationService().scheduleNotification(
        id: reminder.id.hashCode,
        title: _getNotificationTitle(reminder.type),
        body: reminder.title,
        scheduledTime: reminder.reminderDateTime,
        payload: 'reminder_${reminder.id}',
      );
      print('✅ Bildirim planlandı: ${reminder.title} - ${reminder.reminderDateTime}');
    } catch (e) {
      print('❌ Bildirim planlama hatası: $e');
    }
  }

  String _getNotificationTitle(ReminderType type) {
    switch (type) {
      case ReminderType.sport:
        return '🏃‍♂️ Spor Zamanı!';
      case ReminderType.water:
        return '💧 Su İçme Hatırlatması';
      case ReminderType.medication:
        return '💊 İlaç Zamanı';
      case ReminderType.vitamin:
        return '🍊 Vitamin Zamanı';
      case ReminderType.general:
        return '📋 Hatırlatma';
    }
  }

  // Belirli bir güne ait hatırlatmaları getiren yardımcı metod
  List<Reminder> getRemindersForDay(DateTime date) {
    return _reminders.where((reminder) {
      if (!reminder.isActive) return false;

      // Tek seferlik hatırlatmalar
      if (reminder.repeatInterval == RepeatInterval.none) {
        return reminder.reminderDateTime.year == date.year &&
               reminder.reminderDateTime.month == date.month &&
               reminder.reminderDateTime.day == date.day;
      }
      // Günlük hatırlatmalar
      else if (reminder.repeatInterval == RepeatInterval.daily) {
        return true; // Her gün geçerli
      }
      // Haftalık hatırlatmalar (belirli günlerde)
      else if (reminder.repeatInterval == RepeatInterval.weekly && reminder.customRepeatDays != null) {
        return reminder.customRepeatDays!.contains(date.weekday);
      }
      // Aylık hatırlatmalar (ayın belirli günü)
      else if (reminder.repeatInterval == RepeatInterval.monthly) {
        return reminder.reminderDateTime.day == date.day;
      }
      // Yıllık hatırlatmalar
      else if (reminder.repeatInterval == RepeatInterval.yearly) {
        return reminder.reminderDateTime.month == date.month &&
               reminder.reminderDateTime.day == date.day;
      }
      return false;
    }).toList();
  }

  // Bugünkü hatırlatmaları getir
  List<Reminder> getTodaysReminders() {
    return getRemindersForDay(DateTime.now());
  }

  // Aktif hatırlatıcı sayısı
  int get activeReminderCount => _reminders.where((r) => r.isActive).length;

  // Pasif hatırlatıcı sayısı
  int get inactiveReminderCount => _reminders.where((r) => !r.isActive).length;

  // Yaklaşan hatırlatmaları getir (sonraki 24 saat)
  List<Reminder> getUpcomingReminders() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    return _reminders.where((reminder) {
      if (!reminder.isActive) return false;
      return reminder.reminderDateTime.isAfter(now) && 
             reminder.reminderDateTime.isBefore(tomorrow);
    }).toList()..sort((a, b) => a.reminderDateTime.compareTo(b.reminderDateTime));
  }

  // Geçmiş hatırlatmaları getir
  List<Reminder> getPastReminders() {
    final now = DateTime.now();
    
    return _reminders.where((reminder) {
      return reminder.reminderDateTime.isBefore(now);
    }).toList()..sort((a, b) => b.reminderDateTime.compareTo(a.reminderDateTime));
  }

  // Test bildirimi gönder
  Future<void> sendTestNotification() async {
    try {
      await NotificationService().sendTestNotification();
    } catch (e) {
      print('Test bildirimi gönderme hatası: $e');
      rethrow;
    }
  }

  // Tüm bildirimleri yeniden planla (ayarlar değiştiğinde kullanılabilir)
  Future<void> rescheduleAllNotifications() async {
    await _rescheduleActiveReminders();
  }

  // Tüm verileri temizleme metodu (geliştirme için faydalı olabilir)
  Future<void> clearAllReminders() async {
    try {
      // Tüm bildirimleri iptal et
      for (final reminder in _reminders) {
        await NotificationService().cancelNotification(reminder.id.hashCode);
      }
      
      _reminders.clear();
      await _prefs.remove('reminders');
      notifyListeners();
    } catch (e) {
      print('Tüm hatırlatıcıları temizleme hatası: $e');
      rethrow;
    }
  }

  // Bildirim ayarlarını kontrol et
  Future<bool> checkNotificationPermissions() async {
    return true; // Varsayılan olarak true döndür
  }

  // SİSTEM HATIRLATICI DURUM BİLGİLERİ
  String getSystemReminderSummary() {
    int activeCount = 0;
    if (_isStepReminderEnabled) activeCount++;
    if (_isWorkoutReminderEnabled) activeCount++;
    if (_isWaterReminderEnabled) activeCount++;
    
    return '$activeCount/3 sistem hatırlatıcısı aktif';
  }

  // HIZLI AYAR YÖNTEMLERİ
  Future<void> enableAllSystemReminders() async {
    await setStepReminderEnabled(true);
    await setWorkoutReminderEnabled(true);
    await setWaterReminderEnabled(true);
  }

  Future<void> disableAllSystemReminders() async {
    await setStepReminderEnabled(false);
    await setWorkoutReminderEnabled(false);
    await setWaterReminderEnabled(false);
  }
}