// lib/models/user_model.dart - GOAL DEĞERLERİ DÜZELTİLDİ
import '../services/calorie_service.dart';

class UserModel {
  String name;
  String userTag;
  int age;
  String gender;
  double height;
  double weight;
  String activityLevel;
  String goal;
  int weeklyWorkoutDays;
  String? profileImagePath;
  String? coverImageUrl; // YENİ: Kapak resmi URL'si eklendi
  
  // Ek vücut ölçümleri
  double? bodyFatPercentage;
  double? musclePercentage;
  double? waterPercentage;
  int? metabolicAge;
  
  // Su tüketimi verileri
  Map<String, double> dailyWaterIntake;
  
  // Arkadaş listesi
  List<String> friendsList;
  List<String> friendRequests;
  List<String> sentRequests;
  
  // Profil ayarları
  bool isProfilePublic;
  bool allowFriendRequests;
  String? bio;

  // YENİ EKLENEN ALANLAR (hata1.txt'den gelen eksik alanlar)
  String? favoriteTeam;
  String? country;
  String? instagram;
  String? twitter;
  String? favoriteMeal; 
  String? favoriteSport; 
  String? facebook; 
  String? tiktok; 
  String? kick; 
  String? twitch; 
  String? discord; 
  String? whatsapp; 
  String? spotify; 
  
  // Sosyal profildeki isFollowing özelliği (UserService ve UserListTile için)
  bool isFollowing; 


  UserModel({
    required this.name,
    required this.userTag,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.goal,
    required this.weeklyWorkoutDays,
    this.profileImagePath,
    this.coverImageUrl, // YENİ: Constructor'a eklendi
    this.bodyFatPercentage,
    this.musclePercentage,
    this.waterPercentage,
    this.metabolicAge,
    Map<String, double>? dailyWaterIntake,
    List<String>? friendsList,
    List<String>? friendRequests,
    List<String>? sentRequests,
    this.isProfilePublic = true,
    this.allowFriendRequests = true,
    this.bio,
    // YENİ EKLENEN ALANLAR
    this.favoriteTeam,
    this.country,
    this.instagram,
    this.twitter,
    this.favoriteMeal, 
    this.favoriteSport, 
    this.facebook, 
    this.tiktok, 
    this.kick, 
    this.twitch, 
    this.discord, 
    this.whatsapp, 
    this.spotify, 
    this.isFollowing = false, 
  }) : 
    dailyWaterIntake = dailyWaterIntake ?? {},
    friendsList = friendsList ?? [],
    friendRequests = friendRequests ?? [],
    sentRequests = sentRequests ?? [];

  // Günlük kalori ihtiyacı hesaplama
  double get dailyCalorieNeeds {
    return CalorieService.calculateDailyCalorieNeeds(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
    );
  }

  // BMI hesaplama
  double get bmi {
    return weight / ((height / 100) * (height / 100));
  }
  
  // BMR hesaplama (Basal Metabolic Rate)
  double get bmr {
    if (gender == 'male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }
  
  // Günlük adım hedefi
  int get dailyStepGoal {
    switch (activityLevel) {
      case 'sedentary': return 6000;
      case 'lightly_active': return 8000;
      case 'moderately_active': return 10000;
      case 'very_active': return 12000;
      case 'extremely_active': return 15000;
      default: return 8000;
    }
  }
  
  // Günlük dakika hedefi
  int get dailyMinuteGoal {
    switch (activityLevel) {
      case 'sedentary': return 20;
      case 'lightly_active': return 30;
      case 'moderately_active': return 45;
      case 'very_active': return 60;
      case 'extremely_active': return 90;
      default: return 30;
    }
  }
  
  // BMI kategorisi
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Zayıf';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Kilolu';
    return 'Obez';
  }

  // Tam kullanıcı adı (İsim#Tag)
  String get fullUserTag => '$name#$userTag';
  
  // Arkadaş sayısı
  int get friendsCount => friendsList.length;
  
  // Bekleyen istek sayısı
  int get pendingRequestsCount => friendRequests.length;

  // Su tüketimi metodları
  void addWaterIntake(DateTime date, double liters) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    dailyWaterIntake[dateKey] = (dailyWaterIntake[dateKey] ?? 0) + liters;
  }

  double getWaterIntake(DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return dailyWaterIntake[dateKey] ?? 0.0;
  }

  // Arkadaş yönetimi metodları
  bool isFriend(String userTag) => friendsList.contains(userTag);
  bool hasSentRequestTo(String userTag) => sentRequests.contains(userTag);
  bool hasRequestFrom(String userTag) => friendRequests.contains(userTag);
  
  void sendFriendRequest(String userTag) {
    if (!sentRequests.contains(userTag) && !isFriend(userTag)) sentRequests.add(userTag);
  }
  
  void receiveFriendRequest(String userTag) {
    if (!friendRequests.contains(userTag) && !isFriend(userTag)) friendRequests.add(userTag);
  }
  
  void acceptFriendRequest(String userTag) {
    if (friendRequests.contains(userTag)) {
      friendRequests.remove(userTag);
      friendsList.add(userTag);
    }
  }
  
  void rejectFriendRequest(String userTag) => friendRequests.remove(userTag);
  void removeFriend(String userTag) => friendsList.remove(userTag);
  void cancelFriendRequest(String userTag) => sentRequests.remove(userTag);

  // JSON serializasyon
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'userTag': userTag,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'goal': goal,
      'weeklyWorkoutDays': weeklyWorkoutDays,
      'profileImagePath': profileImagePath,
      'coverImageUrl': coverImageUrl, // YENİ: JSON'a eklendi
      'bodyFatPercentage': bodyFatPercentage,
      'musclePercentage': musclePercentage,
      'waterPercentage': waterPercentage,
      'metabolicAge': metabolicAge,
      'dailyWaterIntake': dailyWaterIntake,
      'friendsList': friendsList,
      'friendRequests': friendRequests,
      'sentRequests': sentRequests,
      'isProfilePublic': isProfilePublic,
      'allowFriendRequests': allowFriendRequests,
      'bio': bio,
      // YENİ EKLENEN ALANLAR
      'favoriteTeam': favoriteTeam,
      'country': country,
      'instagram': instagram,
      'twitter': twitter,
      'favoriteMeal': favoriteMeal, 
      'favoriteSport': favoriteSport, 
      'facebook': facebook, 
      'tiktok': tiktok, 
      'kick': kick, 
      'twitch': twitch, 
      'discord': discord, 
      'whatsapp': whatsapp, 
      'spotify': spotify, 
      'isFollowing': isFollowing, 
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // HATA DÜZELTİLDİ: Eski goal değerlerini yeni sisteme çevir
    String goalValue = json['goal'] ?? 'maintain';
    if (goalValue == 'lose_weight_gain_muscle') {
      goalValue = 'muscle_gain';
    } else if (goalValue == 'lose') { 
      goalValue = 'lose_weight';
    } else if (goalValue == 'gain') { 
      goalValue = 'gain_weight';
    }


    return UserModel(
      name: json['name'] ?? '',
      userTag: json['userTag'] ?? _generateRandomTag(),
      age: json['age'] ?? 25,
      gender: json['gender'] ?? 'male',
      height: (json['height'] ?? 170).toDouble(),
      weight: (json['weight'] ?? 70).toDouble(),
      activityLevel: json['activityLevel'] ?? 'moderately_active',
      goal: goalValue, 
      weeklyWorkoutDays: json['weeklyWorkoutDays'] ?? 3,
      profileImagePath: json['profileImagePath'],
      coverImageUrl: json['coverImageUrl'], // YENİ: fromJson'a eklendi
      bodyFatPercentage: json['bodyFatPercentage']?.toDouble(),
      musclePercentage: json['musclePercentage']?.toDouble(),
      waterPercentage: json['waterPercentage']?.toDouble(),
      metabolicAge: json['metabolicAge'],
      dailyWaterIntake: Map<String, double>.from(json['dailyWaterIntake'] ?? {}),
      friendsList: List<String>.from(json['friendsList'] ?? []),
      friendRequests: List<String>.from(json['friendRequests'] ?? []),
      sentRequests: List<String>.from(json['sentRequests'] ?? []),
      isProfilePublic: json['isProfilePublic'] ?? true,
      allowFriendRequests: json['allowFriendRequests'] ?? true,
      bio: json['bio'],
      // YENİ EKLENEN ALANLAR
      favoriteTeam: json['favoriteTeam'],
      country: json['country'],
      instagram: json['instagram'],
      twitter: json['twitter'],
      favoriteMeal: json['favoriteMeal'], 
      favoriteSport: json['favoriteSport'], 
      facebook: json['facebook'], 
      tiktok: json['tiktok'], 
      kick: json['kick'], 
      twitch: json['twitch'], 
      discord: json['discord'], 
      whatsapp: json['whatsapp'], 
      spotify: json['spotify'], 
      isFollowing: json['isFollowing'] ?? false, 
    );
  }

  static String _generateRandomTag() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 10000).toString().padLeft(4, '0');
  }
  
  static String generateCustomTag(String preference) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp % 100;
    return '$preference$random';
  }

  // Kopyalama metodu
  UserModel copyWith({
    String? name,
    String? userTag,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? activityLevel,
    String? goal,
    int? weeklyWorkoutDays,
    String? profileImagePath,
    String? coverImageUrl, // YENİ: copyWith'e eklendi
    double? bodyFatPercentage,
    double? musclePercentage,
    double? waterPercentage,
    int? metabolicAge,
    Map<String, double>? dailyWaterIntake,
    List<String>? friendsList,
    List<String>? friendRequests,
    List<String>? sentRequests,
    bool? isProfilePublic,
    bool? allowFriendRequests,
    String? bio,
    // YENİ EKLENEN ALANLAR
    String? favoriteTeam,
    String? country,
    String? instagram,
    String? twitter,
    String? favoriteMeal, 
    String? favoriteSport, 
    String? facebook, 
    String? tiktok, 
    String? kick, 
    String? twitch, 
    String? discord, 
    String? whatsapp, 
    String? spotify, 
    bool? isFollowing, 
  }) {
    return UserModel(
      name: name ?? this.name,
      userTag: userTag ?? this.userTag,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      weeklyWorkoutDays: weeklyWorkoutDays ?? this.weeklyWorkoutDays,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl, // YENİ: copyWith'e eklendi
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      musclePercentage: musclePercentage ?? this.musclePercentage,
      waterPercentage: waterPercentage ?? this.waterPercentage,
      metabolicAge: metabolicAge ?? this.metabolicAge,
      dailyWaterIntake: dailyWaterIntake ?? Map.from(this.dailyWaterIntake),
      friendsList: friendsList ?? List.from(this.friendsList),
      friendRequests: friendRequests ?? List.from(this.friendRequests),
      sentRequests: sentRequests ?? List.from(this.sentRequests),
      isProfilePublic: isProfilePublic ?? this.isProfilePublic,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      bio: bio ?? this.bio,
      // YENİ EKLENEN ALANLAR
      favoriteTeam: favoriteTeam ?? this.favoriteTeam,
      country: country ?? this.country,
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      favoriteMeal: favoriteMeal ?? this.favoriteMeal, 
      favoriteSport: favoriteSport ?? this.favoriteSport, 
      facebook: facebook ?? this.facebook, 
      tiktok: tiktok ?? this.tiktok, 
      kick: kick ?? this.kick, 
      twitch: twitch ?? this.twitch, 
      discord: discord ?? this.discord, 
      whatsapp: whatsapp ?? this.whatsapp, 
      spotify: spotify ?? this.spotify, 
      isFollowing: isFollowing ?? this.isFollowing, 
    );
  }
}
