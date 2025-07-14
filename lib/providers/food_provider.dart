// lib/providers/food_provider.dart - TAM SÜRÜM
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_model.dart';
import 'achievement_provider.dart';

class FoodProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  late AchievementProvider _achievementProvider;

  List<ConsumedFood> _consumedFoods = [];
  List<String> _searchHistory = [];

  static const _consumedFoodsKey = 'consumed_foods';
  static const _searchHistoryKey = 'search_history';

  // Constructor
  FoodProvider(this._prefs, this._achievementProvider) {
    loadData();
  }

  // Bağımlılıkları güncelleyen metod
  void updateDependencies(AchievementProvider achievementProvider) {
    _achievementProvider = achievementProvider;
  }

  // Getters
  List<ConsumedFood> get consumedFoods => _consumedFoods;
  List<String> get searchHistory => _searchHistory;

  // Veri yükleme
  Future<void> loadData() async {
    try {
      final consumedJson = _prefs.getString(_consumedFoodsKey);
      if (consumedJson != null) {
        _consumedFoods = (jsonDecode(consumedJson) as List)
            .map((item) => ConsumedFood.fromJson(item))
            .toList();
      }
      _searchHistory = _prefs.getStringList(_searchHistoryKey) ?? [];
      notifyListeners();
    } catch (e) {
      print('❌ Food Provider veri yükleme hatası: $e');
    }
  }

  // Tüketilen yiyecekleri kaydetme
  Future<void> _saveConsumedFoods() async {
    try {
      final jsonList = _consumedFoods.map((food) => food.toJson()).toList();
      await _prefs.setString(_consumedFoodsKey, jsonEncode(jsonList));
    } catch (e) {
      print('❌ Food Provider kaydetme hatası: $e');
    }
  }

  // Yeni tüketilen yiyecek ekleme
  Future<void> addConsumedFood(ConsumedFood food) async {
    _consumedFoods.add(food);
    await _saveConsumedFoods();
    _checkFoodAchievements();
    notifyListeners();
  }

  // Tüketilen yiyecek silme
  Future<void> removeConsumedFood(String consumedFoodId) async {
    _consumedFoods.removeWhere((food) => food.id == consumedFoodId);
    await _saveConsumedFoods();
    notifyListeners();
  }

  // Arama geçmişine ekleme
  Future<void> addToSearchHistory(String query) async {
    _searchHistory.remove(query); // Varsa eskisini sil
    _searchHistory.insert(0, query); // Başa ekle
    if (_searchHistory.length > 10) {
      // Son arama listesini 10 ile sınırla
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    await _prefs.setStringList(_searchHistoryKey, _searchHistory);
    notifyListeners();
  }

  // Başarımları kontrol etme
  void _checkFoodAchievements() {
    if (_consumedFoods.length == 1) {
      _achievementProvider.unlockAchievement('first_meal');
    }
    
    // Günlük protein hedefini kontrol et
    final todayProtein = getDailyProtein(DateTime.now());
    if (todayProtein >= 100) { // 100g protein hedefi
      _achievementProvider.unlockAchievement('protein_master');
    }
    
    // Günlük kalori hedefini kontrol et
    final todayCalories = getDailyCalories(DateTime.now());
    if (todayCalories >= 2000) { // 2000 kcal hedefi
      _achievementProvider.unlockAchievement('calorie_tracker');
    }
  }

  // Belirtilen tarihe göre filtreleme yapan yardımcı fonksiyon
  Iterable<ConsumedFood> _getFoodsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return _consumedFoods.where((food) =>
        food.consumedAt.isAfter(startOfDay) &&
        food.consumedAt.isBefore(endOfDay));
  }

  // GÜNLÜK BESIN DEĞERLERİ HESAPLAMA METODLARİ

  // Günlük kalori hesaplama
  double getDailyCalories(DateTime date) {
    return _getFoodsForDate(date)
        .fold(0.0, (sum, item) => sum + item.totalCalories);
  }

  // Günlük protein hesaplama
  double getDailyProtein(DateTime date) {
    return _getFoodsForDate(date)
        .fold(0.0, (sum, item) => sum + item.totalProtein);
  }

  // Günlük karbonhidrat hesaplama
  double getDailyCarbs(DateTime date) {
    return _getFoodsForDate(date)
        .fold(0.0, (sum, item) => sum + item.totalCarbs);
  }

  // Günlük yağ hesaplama
  double getDailyFat(DateTime date) {
    return _getFoodsForDate(date)
        .fold(0.0, (sum, item) => sum + item.totalFat);
  }

  // Günlük şeker hesaplama
  double getDailySugar(DateTime date) {
    return _getFoodsForDate(date)
        .fold(0.0, (sum, item) => sum + (item.totalSugar ?? 0.0));
  }

  // Günlük lif hesaplama
  double getDailyFiber(DateTime date) {
    return _getFoodsForDate(date)
        .fold(0.0, (sum, item) => sum + (item.totalFiber ?? 0.0));
  }

  // Günlük sodyum hesaplama
  double getDailySodium(DateTime date) {
    return _getFoodsForDate(date)
        .fold(0.0, (sum, item) => sum + (item.totalSodium ?? 0.0));
  }

  // ÖĞÜN BAZLI METODLAR

  // Belirli öğündeki yiyecekleri getirme
  List<ConsumedFood> getMealFoods(DateTime date, String mealType) {
    return _getFoodsForDate(date)
        .where((food) => food.mealType == mealType)
        .toList();
  }

  // Öğün bazında kalori hesaplama
  double getMealCalories(DateTime date, String mealType) {
    return getMealFoods(date, mealType)
        .fold(0.0, (sum, item) => sum + item.totalCalories);
  }

  // Öğün bazında protein hesaplama
  double getMealProtein(DateTime date, String mealType) {
    return getMealFoods(date, mealType)
        .fold(0.0, (sum, item) => sum + item.totalProtein);
  }

  // HAFTALIK VE AYLIK İSTATİSTİKLER

  // Haftalık kalori ortalaması
  double getWeeklyAverageCalories(DateTime date) {
    double totalCalories = 0;
    for (int i = 0; i < 7; i++) {
      final dayDate = date.subtract(Duration(days: i));
      totalCalories += getDailyCalories(dayDate);
    }
    return totalCalories / 7;
  }

  // Haftalık protein ortalaması
  double getWeeklyAverageProtein(DateTime date) {
    double totalProtein = 0;
    for (int i = 0; i < 7; i++) {
      final dayDate = date.subtract(Duration(days: i));
      totalProtein += getDailyProtein(dayDate);
    }
    return totalProtein / 7;
  }

  // En çok tüketilen yiyecekler (son 30 gün)
  Map<String, int> getMostConsumedFoods({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentFoods = _consumedFoods
        .where((food) => food.consumedAt.isAfter(cutoffDate))
        .toList();

    final foodCounts = <String, int>{};
    for (final food in recentFoods) {
      foodCounts[food.foodName] = (foodCounts[food.foodName] ?? 0) + 1;
    }

    // En çok tüketilenler sıralaması
    final sortedEntries = foodCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(10)); // İlk 10'u döndür
  }

  // ÖZEL RAPORLAMA METODLARİ

  // Kalori dengesi hesaplama (alınan vs hedef)
  Map<String, double> getCalorieBalance(DateTime date, double targetCalories) {
    final consumed = getDailyCalories(date);
    final remaining = targetCalories - consumed;
    final percentage = (consumed / targetCalories) * 100;

    return {
      'consumed': consumed,
      'target': targetCalories,
      'remaining': remaining,
      'percentage': percentage.clamp(0, 100),
    };
  }

  // Makro besin dağılımı (yüzde olarak)
  Map<String, double> getMacroDistribution(DateTime date) {
    final protein = getDailyProtein(date);
    final carbs = getDailyCarbs(date);
    final fat = getDailyFat(date);

    final totalMacros = protein + carbs + fat;
    if (totalMacros == 0) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }

    return {
      'protein': (protein / totalMacros) * 100,
      'carbs': (carbs / totalMacros) * 100,
      'fat': (fat / totalMacros) * 100,
    };
  }

  // Besin kalitesi skoru (basit hesaplama)
  double getNutritionQualityScore(DateTime date) {
    final fiber = getDailyFiber(date);
    final protein = getDailyProtein(date);
    final sugar = getDailySugar(date);
    final sodium = getDailySodium(date);

    // Basit puanlama sistemi (0-100)
    double score = 50; // Başlangıç puanı

    // Lif fazlaysa +puan
    if (fiber >= 25) score += 20;
    else if (fiber >= 15) score += 10;

    // Protein yeterliyse +puan
    if (protein >= 60) score += 15;
    else if (protein >= 40) score += 8;

    // Şeker az ise +puan
    if (sugar <= 25) score += 10;
    else if (sugar <= 50) score += 5;
    else score -= 10;

    // Sodyum az ise +puan
    if (sodium <= 2000) score += 5;
    else score -= 5;

    return score.clamp(0, 100);
  }

  // VERİ TEMİZLİĞİ

  // Eski verileri temizle (30 günden eski)
  Future<void> cleanOldData({int daysToKeep = 30}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    final initialCount = _consumedFoods.length;
    
    _consumedFoods.removeWhere((food) => food.consumedAt.isBefore(cutoffDate));
    
    if (_consumedFoods.length != initialCount) {
      await _saveConsumedFoods();
      notifyListeners();
      print('🧹 ${initialCount - _consumedFoods.length} eski yemek verisi temizlendi');
    }
  }

  // Tüm verileri sıfırla
  Future<void> clearAllData() async {
    _consumedFoods.clear();
    _searchHistory.clear();
    await _prefs.remove(_consumedFoodsKey);
    await _prefs.remove(_searchHistoryKey);
    notifyListeners();
    print('🗑️ Tüm yemek verileri temizlendi');
  }

  // Debug bilgileri
  Map<String, dynamic> getDebugInfo() {
    return {
      'totalConsumedFoods': _consumedFoods.length,
      'searchHistoryCount': _searchHistory.length,
      'oldestRecord': _consumedFoods.isNotEmpty 
          ? _consumedFoods.map((f) => f.consumedAt).reduce((a, b) => a.isBefore(b) ? a : b)
          : null,
      'newestRecord': _consumedFoods.isNotEmpty
          ? _consumedFoods.map((f) => f.consumedAt).reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
      'todayCalories': getDailyCalories(DateTime.now()),
      'todayProtein': getDailyProtein(DateTime.now()),
    };
  }
}