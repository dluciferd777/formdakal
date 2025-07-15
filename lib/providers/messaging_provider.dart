import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/messaging_service.dart';

class MessagingProvider with ChangeNotifier {
  final MessagingService _messagingService;
  
  List<ConversationModel> _conversations = [];
  List<ConversationModel> _messageRequests = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUserTag;

  MessagingProvider(SharedPreferences prefs) 
      : _messagingService = MessagingService(prefs);

  // Getters
  List<ConversationModel> get conversations => _conversations;
  List<ConversationModel> get messageRequests => _messageRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalUnreadCount => _calculateTotalUnreadCount();

  // Kullanıcı tag'ini ayarla
  void setCurrentUser(String userTag) {
    _currentUserTag = userTag;
    loadConversations();
  }

  // Sohbetleri yükle
  Future<void> loadConversations() async {
    if (_currentUserTag == null) return;

    _setLoading(true);
    _clearError();

    try {
      final conversations = await _messagingService.getUserConversations(_currentUserTag!);
      final requests = await _messagingService.getMessageRequests(_currentUserTag!);
      
      _conversations = conversations;
      _messageRequests = requests;
      
      notifyListeners();
    } catch (e) {
      _setError('Sohbetler yüklenirken hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Mesaj gönder
  Future<bool> sendMessage(
    String conversationId,
    String receiverUserTag,
    String content,
    {MessageType type = MessageType.text}
  ) async {
    if (_currentUserTag == null) return false;

    try {
      final success = await _messagingService.sendMessage(
        conversationId,
        _currentUserTag!,
        receiverUserTag,
        content,
        type: type,
      );

      if (success) {
        // Yerel listeyi güncelle
        await _updateLocalConversation(conversationId);
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Mesaj gönderilirken hata oluştu: $e');
      return false;
    }
  }

  // Yeni sohbet başlat
  Future<ConversationModel?> startConversation(String otherUserTag) async {
    if (_currentUserTag == null) return null;

    try {
      // Arkadaş olup olmadığını kontrol et (şimdilik herkesle sohbet izni var)
      const bool areFriends = true; // TODO: UserProvider'dan arkadaş kontrolü yapılacak
      
      final conversation = await _messagingService.getOrCreateConversation(
        _currentUserTag!,
        otherUserTag,
        isMessageRequest: !areFriends,
      );

      // Arkadaşlar arası sohbet - her zaman normal sohbete ekle
      if (!_conversations.any((conv) => conv.id == conversation.id)) {
        _conversations.insert(0, conversation);
        notifyListeners();
      }

      return conversation;
    } catch (e) {
      _setError('Sohbet başlatılırken hata oluştu: $e');
      return null;
    }
  }

  // Mesaj isteğini kabul et
  Future<bool> acceptMessageRequest(String conversationId) async {
    if (_currentUserTag == null) return false;

    try {
      final success = await _messagingService.acceptMessageRequest(
        conversationId,
        _currentUserTag!,
      );

      if (success) {
        // Yerel listelerden taşı
        final requestIndex = _messageRequests.indexWhere((conv) => conv.id == conversationId);
        if (requestIndex != -1) {
          final conversation = _messageRequests.removeAt(requestIndex);
          _conversations.insert(0, conversation);
          notifyListeners();
        }
        return true;
      }

      return false;
    } catch (e) {
      _setError('Mesaj isteği kabul edilirken hata oluştu: $e');
      return false;
    }
  }

  // Mesaj isteğini reddet
  Future<bool> rejectMessageRequest(String conversationId) async {
    if (_currentUserTag == null) return false;

    try {
      final success = await _messagingService.rejectMessageRequest(
        conversationId,
        _currentUserTag!,
      );

      if (success) {
        _messageRequests.removeWhere((conv) => conv.id == conversationId);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _setError('Mesaj isteği reddedilirken hata oluştu: $e');
      return false;
    }
  }

  // Sohbeti okundu olarak işaretle
  Future<bool> markConversationAsRead(String conversationId) async {
    if (_currentUserTag == null) return false;

    try {
      final success = await _messagingService.markConversationAsRead(
        conversationId,
        _currentUserTag!,
      );

      if (success) {
        // Yerel listeyi güncelle
        await _updateLocalConversation(conversationId);
        return true;
      }

      return false;
    } catch (e) {
      _setError('Mesajlar okundu işaretlenirken hata oluştu: $e');
      return false;
    }
  }

  // Sohbeti sil
  Future<bool> deleteConversation(String conversationId) async {
    if (_currentUserTag == null) return false;

    try {
      final success = await _messagingService.deleteConversation(
        conversationId,
        _currentUserTag!,
      );

      if (success) {
        _conversations.removeWhere((conv) => conv.id == conversationId);
        _messageRequests.removeWhere((conv) => conv.id == conversationId);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _setError('Sohbet silinirken hata oluştu: $e');
      return false;
    }
  }

  // Belirli bir sohbeti al
  ConversationModel? getConversation(String conversationId) {
    // Önce normal sohbetlerde ara
    try {
      return _conversations.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      // Mesaj isteklerinde ara
      try {
        return _messageRequests.firstWhere((conv) => conv.id == conversationId);
      } catch (e) {
        return null;
      }
    }
  }

  // Belirli kullanıcı ile sohbet var mı kontrol et
  ConversationModel? getConversationWithUser(String otherUserTag) {
    // Normal sohbetlerde ara
    try {
      return _conversations.firstWhere((conv) => 
          conv.type == ConversationType.direct &&
          conv.participantUserTags.contains(otherUserTag));
    } catch (e) {
      // Mesaj isteklerinde ara
      try {
        return _messageRequests.firstWhere((conv) => 
            conv.type == ConversationType.direct &&
            conv.participantUserTags.contains(otherUserTag));
      } catch (e) {
        return null;
      }
    }
  }

  // Demo veri oluştur (test için)
  Future<void> createDemoData() async {
    if (_currentUserTag == null) return;

    try {
      await _messagingService.createDemoData(_currentUserTag!);
      await loadConversations();
    } catch (e) {
      _setError('Demo veri oluşturulurken hata oluştu: $e');
    }
  }

  // Antrenman paylaşımı gönder
  Future<bool> shareWorkout(String conversationId, String receiverUserTag, Map<String, dynamic> workoutData) async {
    final workoutMessage = _formatWorkoutMessage(workoutData);
    return await sendMessage(
      conversationId,
      receiverUserTag,
      workoutMessage,
      type: MessageType.workoutShare,
    );
  }

  // Başarım paylaşımı gönder
  Future<bool> shareAchievement(String conversationId, String receiverUserTag, String achievementTitle) async {
    final achievementMessage = '🏆 Yeni başarım kazandım: $achievementTitle';
    return await sendMessage(
      conversationId,
      receiverUserTag,
      achievementMessage,
      type: MessageType.achievement,
    );
  }

  // Private helper methods

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  int _calculateTotalUnreadCount() {
    if (_currentUserTag == null) return 0;
    
    int total = 0;
    for (final conversation in _conversations) {
      total += conversation.getUnreadCount(_currentUserTag!);
    }
    for (final request in _messageRequests) {
      total += request.getUnreadCount(_currentUserTag!);
    }
    return total;
  }

  Future<void> _updateLocalConversation(String conversationId) async {
    if (_currentUserTag == null) return;

    // Normal sohbetlerde güncelle
    final convIndex = _conversations.indexWhere((conv) => conv.id == conversationId);
    if (convIndex != -1) {
      final updatedConversations = await _messagingService.getUserConversations(_currentUserTag!);
      final updatedConv = updatedConversations.where((conv) => conv.id == conversationId).firstOrNull;
      if (updatedConv != null) {
        _conversations[convIndex] = updatedConv;
        // Son aktiviteye göre yeniden sırala
        _conversations.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
        notifyListeners();
      }
    }

    // Mesaj isteklerinde güncelle
    final reqIndex = _messageRequests.indexWhere((conv) => conv.id == conversationId);
    if (reqIndex != -1) {
      final updatedRequests = await _messagingService.getMessageRequests(_currentUserTag!);
      final updatedReq = updatedRequests.where((conv) => conv.id == conversationId).firstOrNull;
      if (updatedReq != null) {
        _messageRequests[reqIndex] = updatedReq;
        notifyListeners();
      }
    }
  }

  String _formatWorkoutMessage(Map<String, dynamic> workoutData) {
    final steps = workoutData['steps'] ?? 0;
    final calories = workoutData['burnedCalories'] ?? 0;
    final duration = workoutData['duration'] ?? 0;

    return '💪 Bugünkü antrenmanım:\n'
           '👟 $steps adım\n'
           '🔥 ${calories.toInt()} kalori yakıldı\n'
           '⏱️ $duration dakika';
  }

  // Provider'ı temizle
  void dispose() {
    _conversations.clear();
    _messageRequests.clear();
    _currentUserTag = null;
    super.dispose();
  }
}