// lib/services/calorie_service.dart - GELİŞTİRİLMİŞ ADIM KALORİ HESAPLAMASI
import 'dart:math';

class CalorieService {
  
  static double calculateBMR({
    required String gender,
    required double weight,
    required double height,
    required int age,
    double? bodyFatPercentage,
  }) {
    if (bodyFatPercentage != null && bodyFatPercentage > 0) {
      double leanBodyMass = weight * (1 - (bodyFatPercentage / 100));
      return 370 + (21.6 * leanBodyMass);
    } else {
      if (gender == 'male') {
        return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
      } else {
        return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
      }
    }
  }
  
  static const Map<String, double> activityFactors = {
    'sedentary': 1.2, 'lightly_active': 1.375, 'moderately_active': 1.55,
    'very_active': 1.725, 'extremely_active': 1.9,
  };

  static double calculateTDEE({
    required String gender,
    required double weight,
    required double height,
    required int age,
    required String activityLevel,
    double? bodyFatPercentage,
  }) {
    final bmr = calculateBMR(
        gender: gender, weight: weight, height: height, age: age, bodyFatPercentage: bodyFatPercentage);
    return bmr * (activityFactors[activityLevel] ?? 1.55);
  }

  static double calculateDailyCalorieNeeds({
    required String gender,
    required double weight,
    required double height,
    required int age,
    required String activityLevel,
    required String goal,
    double? bodyFatPercentage,
  }) {
    final tdee = calculateTDEE(
        gender: gender, weight: weight, height: height, age: age, 
        activityLevel: activityLevel, bodyFatPercentage: bodyFatPercentage);
    switch (goal) {
      case 'lose_weight': return tdee - 500;
      case 'gain_muscle': return tdee + 300;
      case 'lose_weight_gain_muscle': return tdee - 200;
      case 'maintain':
      default: return tdee;
    }
  }

  // Treadmill MET değerini hesaplar. Hıza göre yürüme veya koşma formülü kullanılır.
  // Bu formüller, ACSM (American College of Sports Medicine) kılavuzlarından türetilmiştir.
  static double _calculateTreadmillMET(double speedKmh, double inclinePercent) {
    final speedMetersPerMin = speedKmh * 1000 / 60; // km/saat'i metre/dakika'ya çevir
    final grade = inclinePercent / 100; // Yüzde eğimi ondalık değere çevir
    double vo2; // ml/kg/dk cinsinden oksijen tüketimi

    // Hıza göre yürüme veya koşma formülünü seç
    // Genellikle 6.5 km/saat (yaklaşık 4 mil/saat) ve üzeri koşu olarak kabul edilir.
    if (speedKmh >= 6.5) { // Koşma formülü (ACSM)
      // VO2 = (0.2 * hız) + (0.9 * hız * eğim) + 3.5 (dinlenme MET'i)
      vo2 = (0.2 * speedMetersPerMin) + (0.9 * speedMetersPerMin * grade) + 3.5;
    } else { // Yürüme formülü (ACSM)
      // VO2 = (0.1 * hız) + (1.8 * hız * eğim) + 3.5 (dinlenme MET'i)
      vo2 = (0.1 * speedMetersPerMin) + (1.8 * speedMetersPerMin * grade) + 3.5;
    }
    
    final metValue = vo2 / 3.5; // VO2'yi MET'e çevir (1 MET = 3.5 ml/kg/dk)
    return metValue;
  }
static double calculateUserMET({
  required double weight,
  required double height,
  required int age,
  required String gender,
  required String activityLevel,
}) {
  final bmr = calculateBMR(
    gender: gender, 
    weight: weight, 
    height: height, 
    age: age
  );
  final activityFactor = activityFactors[activityLevel] ?? 1.55;
  return (bmr * activityFactor) / (24 * 3.5);
}
  static double calculateCardioCalories({
    required String exerciseType,
    required double userWeight,
    required int durationMinutes,
    double? speed,
    double? incline,
  }) {
    double metValue;
    if (exerciseType.contains('treadmill') && speed != null) {
      // Treadmill için özel MET hesaplaması
      metValue = _calculateTreadmillMET(speed, incline ?? 0.0);
    } else {
      // Diğer kardiyo türleri için sabit MET değerleri (yaklaşık değerler)
      switch (exerciseType) {
        case 'cycling': metValue = 7.0; break;
        case 'elliptical': metValue = 8.0; break;
        case 'rowing': metValue = 9.0; break;
        case 'swimming': metValue = 6.0; break;
        case 'jumping_jack': metValue = 5.0; break;
        case 'burpees': metValue = 8.0; break;
        case 'jump_rope': metValue = 8.0; break;
        case 'stair_climber': metValue = 9.0; break; 
        case 'boxing_training': metValue = 7.0; break; 
        default: metValue = 5.0; // Varsayılan MET değeri
      }
    }
    double hours = durationMinutes / 60.0; // Süreyi saate çevir
    // Kalori = MET * Vücut Ağırlığı (kg) * Süre (saat)
    return metValue * userWeight * hours;
  }

  static double calculateEnhancedExerciseCalories({ 
    required double metValue, 
    required double userWeight, 
    required int sets, 
    required int reps, 
    required double? weightKg, 
    int restBetweenSets = 60 
  }) {
    // Kuvvet antrenmanları için daha detaylı kalori hesaplaması
    double totalSeconds = (sets * reps * 2.5) + (max(0, sets - 1) * restBetweenSets);
    double hours = totalSeconds / 3600; // Saniyeyi saate çevir
    // Kalori = MET * Vücut Ağırlığı (kg) * Süre (saat)
    return metValue * userWeight * hours;
  }

  // ESKİ VERSİYON: Basit hesaplama
  static double calculateStepCalories(int steps, double weightKg) {
    // Basit formül - geriye dönük uyumluluk için korundu
    return steps * 0.045 * (weightKg / 70.0); // 70 kg referans alındı
  }

  // YENİ VERSİYON: Gelişmiş adım kalori hesaplaması
  static double calculateAdvancedStepCalories({
    required int steps,
    required double weight, // kg
    required double height, // cm
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    // 1. ADIM UZUNLUĞU HESAPLAMASI (Cinsiyete göre)
    double strideLength;
    if (gender == 'male') {
      strideLength = height * 0.415; // Erkekler için
    } else {
      strideLength = height * 0.413; // Kadınlar için
    }
    
    // 2. MESAFE VE HIZ HESAPLAMASI
    final double distanceMeters = (steps * strideLength) / 100;
    final double timeHours = (steps / 1000.0) * (10.0 / 60.0); // 1000 adım = 10 dakika
    final double speedKmh = timeHours > 0 ? (distanceMeters / 1000) / timeHours : 3.0;
    
    // 3. YAŞA GÖRE DÜZELTME
    double ageAdjustment = 1.0;
    if (age < 20) {
      ageAdjustment = 1.1; // Gençler daha aktif
    } else if (age > 60) {
      ageAdjustment = 0.9; // Yaşlılar daha az kalori yakar
    } else if (age > 40) {
      ageAdjustment = 0.95; // Orta yaş
    }
    
    // 4. BMI'YE GÖRE DÜZELTME
    final double bmi = weight / pow(height / 100, 2);
    double bmiAdjustment = 1.0;
    if (bmi < 18.5) {
      bmiAdjustment = 0.9; // Zayıf kişiler daha az kalori yakar
    } else if (bmi > 30) {
      bmiAdjustment = 1.15; // Obez kişiler daha fazla kalori yakar
    } else if (bmi > 25) {
      bmiAdjustment = 1.05; // Kilolu kişiler biraz daha fazla
    }
    
    // 5. CİNSİYETE GÖRE DÜZELTME
    double genderAdjustment = gender == 'male' ? 1.0 : 0.85; // Kadınlar %15 daha az
    
    // 6. AKTİVİTE SEVİYESİNE GÖRE DÜZELTME
    double activityAdjustment = 1.0;
    switch (activityLevel) {
      case 'sedentary':
        activityAdjustment = 0.9;
        break;
      case 'lightly_active':
        activityAdjustment = 0.95;
        break;
      case 'moderately_active':
        activityAdjustment = 1.0; // Standart
        break;
      case 'very_active':
        activityAdjustment = 1.05;
        break;
      case 'extremely_active':
        activityAdjustment = 1.1;
        break;
    }
    
    // 7. HIZA GÖRE MET DEĞERİ
    double baseMET;
    if (speedKmh < 2.5) {
      baseMET = 2.0; // Çok yavaş yürüyüş
    } else if (speedKmh < 4.0) {
      baseMET = 3.5; // Yavaş yürüyüş
    } else if (speedKmh < 5.5) {
      baseMET = 4.3; // Normal yürüyüş
    } else if (speedKmh < 6.5) {
      baseMET = 5.0; // Hızlı yürüyüş
    } else {
      baseMET = 6.0; // Çok hızlı yürüyüş/hafif koşu
    }
    
    // 8. TÜM DÜZELTME FAKTÖRLERINI UYGULA
    final double adjustedMET = baseMET * 
        ageAdjustment * 
        bmiAdjustment * 
        genderAdjustment * 
        activityAdjustment;
    
    // 9. KALORI HESAPLAMASI
    return adjustedMET * weight * timeHours;
  }

  // YENİ: Adım kalori hesaplama detayları
  static Map<String, dynamic> getStepCalorieDetails({
    required int steps,
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    // Hesaplama adımları
    final double strideLength = gender == 'male' ? height * 0.415 : height * 0.413;
    final double distanceKm = (steps * strideLength / 100) / 1000;
    final double timeHours = (steps / 1000.0) * (10.0 / 60.0);
    final double speedKmh = timeHours > 0 ? distanceKm / timeHours : 3.0;
    final double bmi = weight / pow(height / 100, 2);
    
    // Düzeltme faktörleri
    double ageAdjustment = 1.0;
    if (age < 20) ageAdjustment = 1.1;
    else if (age > 60) ageAdjustment = 0.9;
    else if (age > 40) ageAdjustment = 0.95;
    
    double bmiAdjustment = 1.0;
    if (bmi < 18.5) bmiAdjustment = 0.9;
    else if (bmi > 30) bmiAdjustment = 1.15;
    else if (bmi > 25) bmiAdjustment = 1.05;
    
    double genderAdjustment = gender == 'male' ? 1.0 : 0.85;
    
    double activityAdjustment = 1.0;
    switch (activityLevel) {
      case 'sedentary': activityAdjustment = 0.9; break;
      case 'lightly_active': activityAdjustment = 0.95; break;
      case 'very_active': activityAdjustment = 1.05; break;
      case 'extremely_active': activityAdjustment = 1.1; break;
    }
    
    // Base MET
    double baseMET;
    if (speedKmh < 2.5) baseMET = 2.0;
    else if (speedKmh < 4.0) baseMET = 3.5;
    else if (speedKmh < 5.5) baseMET = 4.3;
    else if (speedKmh < 6.5) baseMET = 5.0;
    else baseMET = 6.0;
    
    final double adjustedMET = baseMET * ageAdjustment * bmiAdjustment * genderAdjustment * activityAdjustment;
    final double calories = adjustedMET * weight * timeHours;
    
    return {
      'steps': steps,
      'strideLength': '${strideLength.toStringAsFixed(1)} cm',
      'distance': '${distanceKm.toStringAsFixed(2)} km',
      'time': '${(timeHours * 60).toStringAsFixed(0)} dakika',
      'speed': '${speedKmh.toStringAsFixed(1)} km/h',
      'bmi': bmi.toStringAsFixed(1),
      'baseMET': baseMET.toStringAsFixed(1),
      'ageAdjustment': 'x${ageAdjustment.toStringAsFixed(2)}',
      'bmiAdjustment': 'x${bmiAdjustment.toStringAsFixed(2)}',
      'genderAdjustment': 'x${genderAdjustment.toStringAsFixed(2)}',
      'activityAdjustment': 'x${activityAdjustment.toStringAsFixed(2)}',
      'finalMET': adjustedMET.toStringAsFixed(2),
      'calories': calories.toStringAsFixed(0),
    };
  }

  static double calculateBMI(double weightKg, double heightCm) {
    if (heightCm <= 0) return 0;
    double heightM = heightCm / 100; // Boyu metreye çevir
    return weightKg / (heightM * heightM); // BMI formülü: kilo (kg) / (boy (m) * boy (m))
  }
  
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla Kilolu';
    return 'Obez';
  }
  
  static Map<String, double> getIdealWeightRange(double heightCm) {
    double heightM = heightCm / 100; // Boyu metreye çevir
    // İdeal kilo aralığı BMI 18.5 - 24.9 aralığına göre hesaplanır.
    return {'min': 18.5 * pow(heightM, 2), 'max': 24.9 * pow(heightM, 2)};
  }
  
  static int estimateExerciseDuration(int sets, int reps) {
    // Basit bir yaklaşımla egzersiz süresi tahmini (dakika)
    double totalSeconds = (sets * reps * 2.5) + (max(0, sets - 1) * 30);
    return (totalSeconds / 60).ceil(); // Saniyeyi dakikaya çevir ve yukarı yuvarla
  }
  
  static double calculateDailyProteinNeeds({ 
    required double weight, 
    required String activityLevel, 
    required String goal,
  }) {
    double proteinPerKg; // Kilo başına protein ihtiyacı (gram)
    if (goal == 'gain_muscle' || goal == 'lose_weight_gain_muscle' || activityLevel == 'very_active' || activityLevel == 'extremely_active') {
      proteinPerKg = 1.8; // Kas yapımı veya yüksek aktivite için daha yüksek protein
    } else if (goal == 'lose_weight') {
      proteinPerKg = 1.4; // Kilo kaybı için orta protein
    } else {
      proteinPerKg = 1.0; // Bakım için temel protein
    }
    return weight * proteinPerKg;
  }

  static double calculateDailyFatNeeds({required double dailyCalorieNeeds}) {
    // Günlük kalorinin %25'i yağdan gelsin (yaklaşık değer)
    return (dailyCalorieNeeds * 0.25) / 9; // 1g yağ = 9 kalori
  }

  static double calculateDailyCarbNeeds({
    required double dailyCalorieNeeds, 
    required double proteinGrams, 
    required double fatGrams
  }) {
    // Kalan kaloriler karbonhidrattan gelsin
    double caloriesFromProtein = proteinGrams * 4; // 1g protein = 4 kalori
    double caloriesFromFat = fatGrams * 9;     // 1g yağ = 9 kalori
    double remainingCalories = dailyCalorieNeeds - caloriesFromProtein - caloriesFromFat;
    return remainingCalories / 4; // 1g karbonhidrat = 4 kalori
  }

  static double calculateDailyWaterNeeds({ 
    required double weight, 
    required String activityLevel, 
  }) {
    // Kilo başına 33ml su temel alınır.
    double baseWater = weight * 0.033; // Litre cinsinden
    // Aktivite seviyesine göre ek su ihtiyacı eklenir.
    if (activityLevel == 'very_active' || activityLevel == 'extremely_active') { 
      return baseWater + 1.0; // Litre (ekstra 1 litre)
    } else if (activityLevel == 'moderately_active') { 
      return baseWater + 0.5; // Litre (ekstra 0.5 litre)
    }
    return baseWater; // Litre
  }
}