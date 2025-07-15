// lib/models/user_model.dart - YENİ PROFİL ALANLARI EKLENMİŞ
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

  // MEVCUT SOSYAL MEDYA ALANLARI
  String? favoriteTeam;
  String? country;
  String? instagram;
  String? twitter;
  
  // YENİ EKLENEN SOSYAL MEDYA ALANLARI
  String? youtube;
  String? facebook;
  String? tiktok;
  String? linkedin;
  String? github;
  String? discord;
  String? twitch;
  String? snapchat;
  String? telegram;
  String? whatsapp;
  String? spotify;
  String? pinterest;
  String? reddit;
  String? website;
  String? email;
  
  // YENİ FAVORİ ALANLAR
  String? favoriteSport;
  String? favoriteMeal;
  
  // TAKİP SİSTEMİ İÇİN EKLENDİ
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
    // MEVCUT SOSYAL MEDYA ALANLARI
    this.favoriteTeam,
    this.country,
    this.instagram,
    this.twitter,
    // YENİ EKLENEN SOSYAL MEDYA ALANLARI
    this.youtube,
    this.facebook,
    this.tiktok,
    this.linkedin,
    this.github,
    this.discord,
    this.twitch,
    this.snapchat,
    this.telegram,
    this.whatsapp,
    this.spotify,
    this.pinterest,
    this.reddit,
    this.website,
    this.email,
    // YENİ FAVORİ ALANLAR
    this.favoriteSport,
    this.favoriteMeal,
    // TAKİP SİSTEMİ İÇİN EKLENDİ
    this.isFollowing = false,
  }) : 
    dailyWaterIntake = dailyWaterIntake ?? {},
    friendsList = friendsList ?? [],
    friendRequests = friendRequests ?? [],
    sentRequests = sentRequests ?? [];

  // Tüm sosyal medya linklerini Map olarak döndürür
  Map<String, String> get allSocialLinks {
    final Map<String, String> links = {};
    
    if (instagram != null && instagram!.isNotEmpty) links['instagram'] = instagram!;
    if (twitter != null && twitter!.isNotEmpty) links['twitter'] = twitter!;
    if (youtube != null && youtube!.isNotEmpty) links['youtube'] = youtube!;
    if (facebook != null && facebook!.isNotEmpty) links['facebook'] = facebook!;
    if (tiktok != null && tiktok!.isNotEmpty) links['tiktok'] = tiktok!;
    if (linkedin != null && linkedin!.isNotEmpty) links['linkedin'] = linkedin!;
    if (github != null && github!.isNotEmpty) links['github'] = github!;
    if (discord != null && discord!.isNotEmpty) links['discord'] = discord!;
    if (twitch != null && twitch!.isNotEmpty) links['twitch'] = twitch!;
    if (snapchat != null && snapchat!.isNotEmpty) links['snapchat'] = snapchat!;
    if (telegram != null && telegram!.isNotEmpty) links['telegram'] = telegram!;
    if (whatsapp != null && whatsapp!.isNotEmpty) links['whatsapp'] = whatsapp!;
    if (spotify != null && spotify!.isNotEmpty) links['spotify'] = spotify!;
    if (pinterest != null && pinterest!.isNotEmpty) links['pinterest'] = pinterest!;
    if (reddit != null && reddit!.isNotEmpty) links['reddit'] = reddit!;
    if (website != null && website!.isNotEmpty) links['website'] = website!;
    if (email != null && email!.isNotEmpty) links['email'] = email!;
    
    return links;
  }

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
      // MEVCUT SOSYAL MEDYA ALANLARI
      'favoriteTeam': favoriteTeam,
      'country': country,
      'instagram': instagram,
      'twitter': twitter,
      // YENİ EKLENEN SOSYAL MEDYA ALANLARI
      'youtube': youtube,
      'facebook': facebook,
      'tiktok': tiktok,
      'linkedin': linkedin,
      'github': github,
      'discord': discord,
      'twitch': twitch,
      'snapchat': snapchat,
      'telegram': telegram,
      'whatsapp': whatsapp,
      'spotify': spotify,
      'pinterest': pinterest,
      'reddit': reddit,
      'website': website,
      'email': email,
      // YENİ FAVORİ ALANLAR
      'favoriteSport': favoriteSport,
      'favoriteMeal': favoriteMeal,
      // TAKİP SİSTEMİ İÇİN EKLENDİ
      'isFollowing': isFollowing,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      userTag: json['userTag'] ?? _generateRandomTag(),
      age: json['age'] ?? 25,
      gender: json['gender'] ?? 'male',
      height: (json['height'] ?? 170).toDouble(),
      weight: (json['weight'] ?? 70).toDouble(),
      activityLevel: json['activityLevel'] ?? 'moderately_active',
      goal: json['goal'] ?? 'maintain',
      weeklyWorkoutDays: json['weeklyWorkoutDays'] ?? 3,
      profileImagePath: json['profileImagePath'],
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
      // MEVCUT SOSYAL MEDYA ALANLARI
      favoriteTeam: json['favoriteTeam'],
      country: json['country'],
      instagram: json['instagram'],
      twitter: json['twitter'],
      // YENİ EKLENEN SOSYAL MEDYA ALANLARI
      youtube: json['youtube'],
      facebook: json['facebook'],
      tiktok: json['tiktok'],
      linkedin: json['linkedin'],
      github: json['github'],
      discord: json['discord'],
      twitch: json['twitch'],
      snapchat: json['snapchat'],
      telegram: json['telegram'],
      whatsapp: json['whatsapp'],
      spotify: json['spotify'],
      pinterest: json['pinterest'],
      reddit: json['reddit'],
      website: json['website'],
      email: json['email'],
      // YENİ FAVORİ ALANLAR
      favoriteSport: json['favoriteSport'],
      favoriteMeal: json['favoriteMeal'],
      // TAKİP SİSTEMİ İÇİN EKLENDİ
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
    // MEVCUT SOSYAL MEDYA ALANLARI
    String? favoriteTeam,
    String? country,
    String? instagram,
    String? twitter,
    // YENİ EKLENEN SOSYAL MEDYA ALANLARI
    String? youtube,
    String? facebook,
    String? tiktok,
    String? linkedin,
    String? github,
    String? discord,
    String? twitch,
    String? snapchat,
    String? telegram,
    String? whatsapp,
    String? spotify,
    String? pinterest,
    String? reddit,
    String? website,
    String? email,
    // YENİ FAVORİ ALANLAR
    String? favoriteSport,
    String? favoriteMeal,
    // TAKİP SİSTEMİ İÇİN EKLENDİ
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
      // MEVCUT SOSYAL MEDYA ALANLARI
      favoriteTeam: favoriteTeam ?? this.favoriteTeam,
      country: country ?? this.country,
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      // YENİ EKLENEN SOSYAL MEDYA ALANLARI
      youtube: youtube ?? this.youtube,
      facebook: facebook ?? this.facebook,
      tiktok: tiktok ?? this.tiktok,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      discord: discord ?? this.discord,
      twitch: twitch ?? this.twitch,
      snapchat: snapchat ?? this.snapchat,
      telegram: telegram ?? this.telegram,
      whatsapp: whatsapp ?? this.whatsapp,
      spotify: spotify ?? this.spotify,
      pinterest: pinterest ?? this.pinterest,
      reddit: reddit ?? this.reddit,
      website: website ?? this.website,
      email: email ?? this.email,
      // YENİ FAVORİ ALANLAR
      favoriteSport: favoriteSport ?? this.favoriteSport,
      favoriteMeal: favoriteMeal ?? this.favoriteMeal,
      // TAKİP SİSTEMİ İÇİN EKLENDİ
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}