// lib/services/friend_service.dart - Online Arkadaş Sistemi Temel Yapısı
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class FriendService {
  // Gelecekte API endpoint'leri kullanılacak: https://api.formdakal.com
  
  // Local cache keys
  static const String _friendsKey = 'friends_cache';
  static const String _requestsKey = 'friend_requests_cache';
  static const String _registeredUsersKey = 'registered_users';

  // TAG DOĞRULAMA VE KAYIT SİSTEMİ
  static bool isValidTag(String tag) {
    // Tag kuralları: 2-8 karakter, sadece harf ve rakam
    final regex = RegExp(r'^[A-Z0-9]{2,8}$');
    return regex.hasMatch(tag.toUpperCase());
  }

  static Future<bool> isTagAvailable(String tag) async {
    // Gelecekte: API'ye sorgu gönderilecek
    // Şimdilik: Local kontrol
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_registeredUsersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);
    
    return !users.any((userJson) => 
      userJson['userTag']?.toString().toLowerCase() == tag.toLowerCase()
    );
  }

  static Future<List<String>> generateTagSuggestions(String baseName) async {
    final suggestions = <String>[];
    final cleanName = baseName.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    
    // İsimden prefix oluştur
    if (cleanName.length >= 2) {
      for (int i = 2; i <= 4 && i <= cleanName.length; i++) {
        final prefix = cleanName.substring(0, i);
        
        // Rastgele sayılar ekle
        for (int j = 0; j < 3; j++) {
          final random = DateTime.now().millisecondsSinceEpoch % 10000;
          final suggestion = '$prefix${random.toString().padLeft(4, '0')}';
          
          if (await isTagAvailable(suggestion) && !suggestions.contains(suggestion)) {
            suggestions.add(suggestion);
          }
          
          if (suggestions.length >= 5) break;
        }
        
        if (suggestions.length >= 5) break;
      }
    }
    
    // Yeterli öneri yoksa tamamen rastgele oluştur
    while (suggestions.length < 5) {
      final random = DateTime.now().millisecondsSinceEpoch % 100000;
      final suggestion = 'USR${random.toString().padLeft(4, '0')}';
      
      if (await isTagAvailable(suggestion) && !suggestions.contains(suggestion)) {
        suggestions.add(suggestion);
      }
    }
    
    return suggestions;
  }

  static Future<bool> registerUser(UserModel user) async {
    try {
      // Tag müsaitlik kontrolü
      if (!await isTagAvailable(user.userTag)) {
        return false;
      }
      
      // Gelecekte: API'ye POST request atılacak
      // Şimdilik: Local kayıt
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_registeredUsersKey) ?? '[]';
      final List<dynamic> users = jsonDecode(usersJson);
      
      users.add(user.toJson());
      
      await prefs.setString(_registeredUsersKey, jsonEncode(users));
      return true;
      
    } catch (e) {
      return false;
    }
  }

  // ARKADAŞ ARAMA SİSTEMİ (Gelecekte API ile çalışacak)
  static Future<UserModel?> findUserByTag(String tag) async {
    // Gelecekte: GET /api/users/search?tag={tag}
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_registeredUsersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);
    
    try {
      final userJson = users.firstWhere(
        (u) => u['userTag']?.toString().toLowerCase() == tag.toLowerCase(),
      );
      return UserModel.fromJson(userJson);
    } catch (e) {
      return null;
    }
  }

  static Future<List<UserModel>> searchUsersByName(String name) async {
    // Gelecekte: GET /api/users/search?name={name}
    if (name.trim().isEmpty) return [];
    
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_registeredUsersKey) ?? '[]';
    final List<dynamic> users = jsonDecode(usersJson);
    
    return users
        .where((userJson) => userJson['name']
            ?.toString()
            .toLowerCase()
            .contains(name.toLowerCase()) ?? false)
        .map((userJson) => UserModel.fromJson(userJson))
        .toList();
  }

  // ARKADAŞLIK İSTEKLERİ (Gelecekte API ile çalışacak)
  static Future<bool> sendFriendRequest(String fromUserTag, String toUserTag) async {
    // Gelecekte: POST /api/friend-requests
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getString(_requestsKey) ?? '{}';
      final Map<String, dynamic> requests = jsonDecode(requestsJson);
      
      if (!requests.containsKey(toUserTag)) {
        requests[toUserTag] = [];
      }
      
      final List<dynamic> userRequests = requests[toUserTag];
      if (!userRequests.contains(fromUserTag)) {
        userRequests.add(fromUserTag);
        await prefs.setString(_requestsKey, jsonEncode(requests));
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> acceptFriendRequest(String userTag, String fromUserTag) async {
    // Gelecekte: PUT /api/friend-requests/{id}/accept
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // İsteği sil
      final requestsJson = prefs.getString(_requestsKey) ?? '{}';
      final Map<String, dynamic> requests = jsonDecode(requestsJson);
      
      if (requests.containsKey(userTag)) {
        final List<dynamic> userRequests = requests[userTag];
        userRequests.remove(fromUserTag);
        await prefs.setString(_requestsKey, jsonEncode(requests));
      }
      
      // Arkadaş listesine ekle
      final friendsJson = prefs.getString(_friendsKey) ?? '{}';
      final Map<String, dynamic> friends = jsonDecode(friendsJson);
      
      // Her iki kullanıcı için de arkadaş listesini güncelle
      if (!friends.containsKey(userTag)) friends[userTag] = [];
      if (!friends.containsKey(fromUserTag)) friends[fromUserTag] = [];
      
      final List<dynamic> userFriends = friends[userTag];
      final List<dynamic> fromUserFriends = friends[fromUserTag];
      
      if (!userFriends.contains(fromUserTag)) userFriends.add(fromUserTag);
      if (!fromUserFriends.contains(userTag)) fromUserFriends.add(userTag);
      
      await prefs.setString(_friendsKey, jsonEncode(friends));
      return true;
      
    } catch (e) {
      return false;
    }
  }

  static Future<bool> rejectFriendRequest(String userTag, String fromUserTag) async {
    // Gelecekte: DELETE /api/friend-requests/{id}
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getString(_requestsKey) ?? '{}';
      final Map<String, dynamic> requests = jsonDecode(requestsJson);
      
      if (requests.containsKey(userTag)) {
        final List<dynamic> userRequests = requests[userTag];
        userRequests.remove(fromUserTag);
        await prefs.setString(_requestsKey, jsonEncode(requests));
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> cancelFriendRequest(String fromUserTag, String toUserTag) async {
    // Gelecekte: DELETE /api/friend-requests/{id}
    return await rejectFriendRequest(toUserTag, fromUserTag);
  }

  // ARKADAŞ LİSTESİ YÖNETİMİ
  static Future<List<UserModel>> getFriendsList(String userTag) async {
    // Gelecekte: GET /api/users/{userTag}/friends
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString(_friendsKey) ?? '{}';
      final Map<String, dynamic> friends = jsonDecode(friendsJson);
      
      final List<dynamic> userFriends = friends[userTag] ?? [];
      
      // Arkadaş tag'lerini UserModel'lere çevir
      final usersJson = prefs.getString(_registeredUsersKey) ?? '[]';
      final List<dynamic> allUsers = jsonDecode(usersJson);
      
      return allUsers
          .where((userJson) => userFriends.contains(userJson['userTag']))
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();
          
    } catch (e) {
      return [];
    }
  }

  static Future<List<UserModel>> getFriendRequests(String userTag) async {
    // Gelecekte: GET /api/users/{userTag}/friend-requests
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getString(_requestsKey) ?? '{}';
      final Map<String, dynamic> requests = jsonDecode(requestsJson);
      
      final List<dynamic> userRequests = requests[userTag] ?? [];
      
      final usersJson = prefs.getString(_registeredUsersKey) ?? '[]';
      final List<dynamic> allUsers = jsonDecode(usersJson);
      
      return allUsers
          .where((userJson) => userRequests.contains(userJson['userTag']))
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();
          
    } catch (e) {
      return [];
    }
  }

  static Future<List<UserModel>> getSentRequests(String userTag) async {
    // Gelecekte: GET /api/users/{userTag}/sent-requests
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getString(_requestsKey) ?? '{}';
      final Map<String, dynamic> requests = jsonDecode(requestsJson);
      
      List<String> sentTags = [];
      requests.forEach((key, value) {
        if (value is List && value.contains(userTag)) {
          sentTags.add(key);
        }
      });
      
      final usersJson = prefs.getString(_registeredUsersKey) ?? '[]';
      final List<dynamic> allUsers = jsonDecode(usersJson);
      
      return allUsers
          .where((userJson) => sentTags.contains(userJson['userTag']))
          .map((userJson) => UserModel.fromJson(userJson))
          .toList();
          
    } catch (e) {
      return [];
    }
  }

  static Future<bool> removeFriend(String userTag, String friendTag) async {
    // Gelecekte: DELETE /api/users/{userTag}/friends/{friendTag}
    try {
      final prefs = await SharedPreferences.getInstance();
      final friendsJson = prefs.getString(_friendsKey) ?? '{}';
      final Map<String, dynamic> friends = jsonDecode(friendsJson);
      
      // Her iki kullanıcının arkadaş listesinden sil
      if (friends.containsKey(userTag)) {
        final List<dynamic> userFriends = friends[userTag];
        userFriends.remove(friendTag);
      }
      
      if (friends.containsKey(friendTag)) {
        final List<dynamic> friendFriends = friends[friendTag];
        friendFriends.remove(userTag);
      }
      
      await prefs.setString(_friendsKey, jsonEncode(friends));
      return true;
      
    } catch (e) {
      return false;
    }
  }

  static Future<bool> blockUser(String userTag, String targetTag) async {
    // Gelecekte: POST /api/users/{userTag}/blocked-users
    try {
      // Önce arkadaş listesinden sil
      await removeFriend(userTag, targetTag);
      
      // Engelli listesine ekle (gelecekte kullanılabilir)
      final prefs = await SharedPreferences.getInstance();
      final blockedJson = prefs.getString('blocked_users') ?? '{}';
      final Map<String, dynamic> blocked = jsonDecode(blockedJson);
      
      if (!blocked.containsKey(userTag)) {
        blocked[userTag] = [];
      }
      
      final List<dynamic> userBlocked = blocked[userTag];
      if (!userBlocked.contains(targetTag)) {
        userBlocked.add(targetTag);
        await prefs.setString('blocked_users', jsonEncode(blocked));
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Gelecekte popüler kullanıcılar API'den gelecek
  static Future<List<UserModel>> getPopularUsers() async {
    // Gelecekte: GET /api/users/popular
    return []; // Şimdilik boş döndür
  }
}