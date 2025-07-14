// lib/providers/exercise_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:formdakal/providers/step_counter_provider.dart'; // YENİ: Yeni provider import edildi
import 'package:formdakal/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_model.dart';
import '../services/calorie_service.dart';
import 'achievement_provider.dart';

class ExerciseProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  late AchievementProvider _achievementProvider;
  late UserProvider _userProvider;
  late StepCounterProvider _stepCounterProvider; // DEĞİŞTİ: Eski servis yerine yeni provider

  List<CompletedExercise> _completedExercises = [];

  static const _exercisesKey = 'completed_exercises';

  // Constructor güncellendi
  ExerciseProvider(this._prefs, this._achievementProvider, this._userProvider, this._stepCounterProvider) {
    loadData();
  }

  // updateDependencies güncellendi
  void updateDependencies(AchievementProvider achProvider, UserProvider usrProvider, StepCounterProvider stepProvider) {
    _achievementProvider = achProvider;
    _userProvider = usrProvider;
    _stepCounterProvider = stepProvider;
  }

  List<CompletedExercise> get completedExercises => _completedExercises;

  Future<void> loadData() async {
    try {
      final exerciseJson = _prefs.getString(_exercisesKey);
      if (exerciseJson != null) {
        final List<dynamic> decoded = jsonDecode(exerciseJson);
        _completedExercises =
            decoded.map((item) => CompletedExercise.fromJson(item)).toList();
      }
      debugPrint("📂 Exercise verileri yüklendi");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Exercise veri yükleme hatası: $e");
    }
  }

  Future<void> _saveCompletedExercises() async {
    try {
      final jsonList = _completedExercises.map((exercise) => exercise.toJson()).toList();
      await _prefs.setString(_exercisesKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint("❌ Exercise kaydetme hatası: $e");
    }
  }

  Future<void> addCompletedExercise(CompletedExercise exercise) async {
    _completedExercises.add(exercise);
    await _saveCompletedExercises();
    _checkWorkoutAchievements();
    notifyListeners();
  }
  
  Future<void> removeCompletedExerciseById(String id) async {
    _completedExercises.removeWhere((exercise) => exercise.id == id);
    await _saveCompletedExercises();
    notifyListeners();
  }

  void _checkWorkoutAchievements() {
    if (_completedExercises.length == 1) {
      _achievementProvider.unlockAchievement('first_workout');
    }
  }

  double getDailyBurnedCalories(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    double exerciseCalories = _completedExercises
        .where((exercise) =>
            exercise.completedAt.isAfter(startOfDay) &&
            exercise.completedAt.isBefore(endOfDay))
        .fold(0.0, (total, exercise) => total + exercise.burnedCalories);

    final userWeight = _userProvider.user?.weight ?? 70.0;
    double stepCalories = 0.0;
    
    // Adım verisini YENİ StepCounterProvider'dan al ✅
    final int dailySteps = _stepCounterProvider.dailySteps;
    
    if (dailySteps > 0 && userWeight > 0) {
      stepCalories = CalorieService.calculateStepCalories(dailySteps, userWeight);
    }
    
    return exerciseCalories + stepCalories;
  }

  int getDailyExerciseMinutes(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _completedExercises
        .where((exercise) =>
            exercise.completedAt.isAfter(startOfDay) &&
            exercise.completedAt.isBefore(endOfDay))
        .fold(0, (total, exercise) => total + exercise.durationMinutes);
  }
}