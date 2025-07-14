// lib/screens/reminder_settings_screen.dart - YENİ EKRAN
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../services/notification_service.dart';
import '../utils/colors.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hatırlatıcı Ayarları'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {
              // Test bildirimi gönder
              NotificationService().sendTestReminderNotification();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test bildirimi gönderildi!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            tooltip: 'Test Bildirimi',
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ADIM HATIRLATMASI BÖLÜMÜ
                _buildReminderSection(
                  context: context,
                  title: '🦶 Adım Hatırlatması',
                  subtitle: 'Günlük adım hedefin için hatırlatma',
                  isEnabled: reminderProvider.isStepReminderEnabled,
                  selectedTime: reminderProvider.stepReminderTime,
                  onToggle: (value) async {
                    await reminderProvider.setStepReminderEnabled(value);
                    if (value) {
                      await NotificationService().toggleReminderType('step', true);
                    } else {
                      await NotificationService().toggleReminderType('step', false);
                    }
                  },
                  onTimeChanged: (time) async {
                    await reminderProvider.setStepReminderTime(time);
                    // Yeni saatle hatırlatmayı yeniden planla
                    if (reminderProvider.isStepReminderEnabled) {
                      await NotificationService().toggleReminderType('step', true);
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                
                // EGZERSİZ HATIRLATMASI BÖLÜMÜ
                _buildReminderSection(
                  context: context,
                  title: '💪 Egzersiz Hatırlatması',
                  subtitle: 'Günlük spor aktivitesi için hatırlatma',
                  isEnabled: reminderProvider.isWorkoutReminderEnabled,
                  selectedTime: reminderProvider.workoutReminderTime,
                  onToggle: (value) async {
                    await reminderProvider.setWorkoutReminderEnabled(value);
                    if (value) {
                      await NotificationService().toggleReminderType('workout', true);
                    } else {
                      await NotificationService().toggleReminderType('workout', false);
                    }
                  },
                  onTimeChanged: (time) async {
                    await reminderProvider.setWorkoutReminderTime(time);
                    if (reminderProvider.isWorkoutReminderEnabled) {
                      await NotificationService().toggleReminderType('workout', true);
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                
                // SU İÇME HATIRLATMASI BÖLÜMÜ
                _buildWaterReminderSection(context, reminderProvider),
                
                const SizedBox(height: 32),
                
                // GENEL AYARLAR BÖLÜMÜ
                _buildGeneralSettings(context, isDarkMode),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required TimeOfDay selectedTime,
    required Function(bool) onToggle,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: onToggle,
                  activeColor: AppColors.primaryGreen,
                ),
              ],
            ),
            
            if (isEnabled) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hatırlatma Saati:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                primary: AppColors.primaryGreen,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        onTimeChanged(time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWaterReminderSection(BuildContext context, ReminderProvider reminderProvider) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💧 Su İçme Hatırlatması',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Düzenli su içme için hatırlatma',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminderProvider.isWaterReminderEnabled,
                  onChanged: (value) async {
                    await reminderProvider.setWaterReminderEnabled(value);
                    if (value) {
                      await NotificationService().toggleReminderType('water', true);
                    } else {
                      await NotificationService().toggleReminderType('water', false);
                    }
                  },
                  activeColor: AppColors.primaryGreen,
                ),
              ],
            ),
            
            if (reminderProvider.isWaterReminderEnabled) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Başlangıç saati
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Başlangıç Saati:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  _buildTimeButton(
                    context,
                    reminderProvider.waterReminderStartTime,
                    (time) async {
                      await reminderProvider.setWaterReminderStartTime(time);
                      if (reminderProvider.isWaterReminderEnabled) {
                        await NotificationService().toggleReminderType('water', true);
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Bitiş saati
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bitiş Saati:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  _buildTimeButton(
                    context,
                    reminderProvider.waterReminderEndTime,
                    (time) async {
                      await reminderProvider.setWaterReminderEndTime(time);
                      if (reminderProvider.isWaterReminderEnabled) {
                        await NotificationService().toggleReminderType('water', true);
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Aralık
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hatırlatma Aralığı:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  DropdownButton<int>(
                    value: reminderProvider.waterReminderInterval,
                    onChanged: (value) async {
                      if (value != null) {
                        await reminderProvider.setWaterReminderInterval(value);
                        if (reminderProvider.isWaterReminderEnabled) {
                          await NotificationService().toggleReminderType('water', true);
                        }
                      }
                    },
                    items: [30, 60, 90, 120, 180].map((minutes) {
                      return DropdownMenuItem<int>(
                        value: minutes,
                        child: Text(
                          minutes < 60 ? '$minutes dk' : '${minutes ~/ 60} saat',
                          style: const TextStyle(color: AppColors.primaryGreen),
                        ),
                      );
                    }).toList(),
                    dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                    underline: Container(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primaryGreen,
                ),
              ),
              child: child!,
            );
          },
        );
        if (newTime != null) {
          onChanged(newTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
        ),
        child: Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSettings(BuildContext context, bool isDarkMode) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚙️ Genel Ayarlar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Test bildirimi butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  NotificationService().sendTestReminderNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test bildirimi gönderildi! Ses ve titreşim kontrol edin.'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('Test Bildirimi Gönder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Tüm hatırlatmaları iptal et butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await NotificationService().cancelAllNotifications();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tüm hatırlatmalar iptal edildi.'),
                        backgroundColor: AppColors.error,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Tüm Hatırlatmaları İptal Et'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}