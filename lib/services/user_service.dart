// lib/services/user_service.dart
import '../models/user_model.dart';

// Bu sınıf, kullanıcı verilerini ve takip işlemlerini simüle eder.
class UserService {
  // --- SOSYAL UYGULAMADAN ALINAN KULLANICI LİSTESİ ---
  final List<UserModel> _allUsers = [
    UserModel(
      name: 'Onur Yıldız',
      userTag: 'ozyxgen',
      age: 26,
      gender: 'male',
      height: 165,
      weight: 80,
      activityLevel: 'very_active',
      goal: 'gain_muscle',
      weeklyWorkoutDays: 5,
      country: 'İstanbul',
      favoriteTeam: 'Galatasaray',
      instagram: 'ozyxgen',
      bio: 'Fitness tutkunu, 5 yıldır spor yapıyorum',
      isFollowing: true, // Eklendi
      favoriteMeal: 'Tavuklu Pilav', // Eklendi
      favoriteSport: 'Fitness', // Eklendi
      facebook: 'onur.yildiz', // Eklendi
      tiktok: 'onurstar_tiktok', // Eklendi
      kick: 'onurstar_kick', // Eklendi
      twitch: 'ozyxgen_twitch', // Eklendi
      discord: 'onurstar#1234', // Eklendi
      whatsapp: '905551234567', // Eklendi
      spotify: 'onurstar_spotify', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=1',
    ),
    UserModel(
      name: 'Altuğ Götten.',
      userTag: 'altug',
      age: 28,
      gender: 'male',
      height: 175,
      weight: 75,
      activityLevel: 'moderately_active',
      goal: 'maintain',
      weeklyWorkoutDays: 3,
      country: 'Ankara',
      favoriteTeam: 'Beşiktaş',
      bio: 'Müzisyen',
      isFollowing: false, // Eklendi
      favoriteMeal: 'Mantı', // Eklendi
      favoriteSport: 'Basketbol', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=2',
    ),
    UserModel(
      name: 'Oğuz İbine.',
      userTag: 'oguz',
      age: 29,
      gender: 'male',
      height: 190,
      weight: 95,
      activityLevel: 'extremely_active',
      goal: 'gain_muscle',
      weeklyWorkoutDays: 7,
      country: 'İzmir',
      favoriteTeam: 'Fenerbahçe',
      bio: 'Sporcu',
      isFollowing: true, // Eklendi
      favoriteMeal: 'Köfte', // Eklendi
      favoriteSport: 'Vücut Geliştirme', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=3',
    ),
    UserModel(
      name: 'Busechan',
      userTag: 'busechan',
      age: 24,
      gender: 'female',
      height: 168,
      weight: 55,
      activityLevel: 'lightly_active',
      goal: 'maintain',
      weeklyWorkoutDays: 3,
      country: 'Bursa',
      favoriteTeam: 'Bursaspor',
      instagram: 'busechan',
      bio: 'Influencer',
      isFollowing: false, // Eklendi
      favoriteMeal: 'Salata', // Eklendi
      favoriteSport: 'Yoga', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=4',
    ),
    UserModel(
      name: 'Jahrein',
      userTag: 'jahrein',
      age: 34,
      gender: 'male',
      height: 185,
      weight: 90,
      activityLevel: 'sedentary',
      goal: 'lose_weight',
      weeklyWorkoutDays: 1,
      country: 'Antalya',
      favoriteTeam: 'Antalyaspor',
      twitter: 'jahrein',
      bio: 'Yayıncı',
      isFollowing: true, // Eklendi
      favoriteMeal: 'Hamburger', // Eklendi
      favoriteSport: 'E-Spor', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=5',
    ),
    UserModel(
      name: 'Gojo Satoru',
      userTag: 'gojo',
      age: 28,
      gender: 'male',
      height: 190,
      weight: 80,
      activityLevel: 'very_active',
      goal: 'maintain',
      weeklyWorkoutDays: 5,
      country: 'Tokyo',
      favoriteTeam: 'Kendisi',
      bio: 'Jujutsu Büyücüsü',
      isFollowing: false, // Eklendi
      favoriteMeal: 'Mochi', // Eklendi
      favoriteSport: 'Jujutsu', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=6',
    ),
    UserModel(
      name: 'Yuji Itadori',
      userTag: 'itadori',
      age: 16,
      gender: 'male',
      height: 173,
      weight: 80,
      activityLevel: 'extremely_active',
      goal: 'gain_muscle',
      weeklyWorkoutDays: 7,
      country: 'Tokyo',
      favoriteTeam: 'Toudou',
      bio: 'Öğrenci',
      isFollowing: true, // Eklendi
      favoriteMeal: 'Ramen', // Eklendi
      favoriteSport: 'Dövüş Sanatları', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=7',
    ),
    UserModel(
      name: 'Naruto Uzumaki',
      userTag: 'naruto',
      age: 32,
      gender: 'male',
      height: 180,
      weight: 70,
      activityLevel: 'extremely_active',
      goal: 'maintain',
      weeklyWorkoutDays: 7,
      country: 'Konoha',
      favoriteTeam: 'Takım 7',
      bio: 'Hokage',
      isFollowing: false, // Eklendi
      favoriteMeal: 'Ramen', // Eklendi
      favoriteSport: 'Ninja Eğitimi', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=8',
    ),
    UserModel(
      name: 'Sasuke Uchiha',
      userTag: 'sasuke',
      age: 32,
      gender: 'male',
      height: 182,
      weight: 72,
      activityLevel: 'very_active',
      goal: 'maintain',
      weeklyWorkoutDays: 6,
      country: 'Konoha',
      favoriteTeam: 'Taka',
      bio: 'Gölge Hokage',
      isFollowing: false, // Eklendi
      favoriteMeal: 'Onigiri', // Eklendi
      favoriteSport: 'Kılıç Kullanımı', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=9',
    ),
    UserModel(
      name: 'Mashle Burndead',
      userTag: 'mashle',
      age: 16,
      gender: 'male',
      height: 171,
      weight: 70,
      activityLevel: 'extremely_active',
      goal: 'gain_muscle',
      weeklyWorkoutDays: 7,
      country: 'Büyü Dünyası',
      favoriteTeam: 'Adler Yurdu',
      bio: 'İlahi Görücü',
      isFollowing: true, // Eklendi
      favoriteMeal: 'Krem Puf', // Eklendi
      favoriteSport: 'Ağırlık Kaldırma', // Eklendi
      profileImagePath: 'https://i.pravatar.cc/150?img=10',
    ),
  ];

  List<UserModel> getAllUsers(String currentUserTag) {
    return _allUsers.where((user) => user.userTag != currentUserTag).toList();
  }

  // --- ARAMA MANTIĞI ---
  List<UserModel> searchUsers(String query, String currentUserTag) {
    if (query.isEmpty) {
      return [];
    }
    final lowerCaseQuery = query.toLowerCase();
    
    // Etiketteki '@' işaretini temizle
    final cleanTagQuery = lowerCaseQuery.startsWith('@') 
        ? lowerCaseQuery.substring(1) 
        : lowerCaseQuery;

    return _allUsers.where((user) {
      // Mevcut kullanıcıyı sonuçlardan çıkar
      if (user.userTag == currentUserTag) return false;

      // İsimdeki kelimelerden herhangi biri arama terimiyle başlıyor mu?
      final nameMatches = user.name.toLowerCase().split(' ').any((word) => word.startsWith(lowerCaseQuery));
      
      // Etiket, arama terimiyle başlıyor mu?
      final tagMatches = user.userTag.toLowerCase().startsWith(cleanTagQuery);

      return nameMatches || tagMatches;
    }).toList();
  }

  List<UserModel> getFollowingUsers() {
    return _allUsers.where((user) => user.isFollowing).toList();
  }

  List<UserModel> getFollowerUsers() {
    return _allUsers.where((user) => !user.isFollowing).toList();
  }
  
  void toggleFollowStatus(String userTag) {
    try {
      final user = _allUsers.firstWhere((u) => u.userTag == userTag);
      user.isFollowing = !user.isFollowing;
    } catch (e) {
      // Kullanıcı bulunamadı
    }
  }
}
