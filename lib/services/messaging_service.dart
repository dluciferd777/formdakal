import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessagingService {
  static const String _conversationsKey = 'user_conversations';
  static const String _messageRequestsKey = 'message_requests';
  
  final SharedPreferences _prefs;
  
  MessagingService(this._prefs);

  // Tüm sohbetleri getir
  Future<List<ConversationModel>> getUserConversations(String currentUserTag) async {
    try {
      final String? conversationsJson = _prefs.getString(_conversationsKey);
      if (conversationsJson == null) return [];

      final List<dynamic> conversationsList = jsonDecode(conversationsJson);
      final conversations = conversationsList
          .map((json) => ConversationModel.fromJson(json))
          .where((conversation) => conversation.isParticipant(currentUserTag))
          .toList();

      // Son aktiviteye göre sırala
      conversations.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
      
      return conversations;
    } catch (e) {
      debugPrint('Sohbetler yüklenirken hata: $e');
      return [];
    }
  }

  // Mesaj isteklerini getir (arkadaş olmayan kişilerden gelen mesajlar)
  Future<List<ConversationModel>> getMessageRequests(String currentUserTag) async {
    try {
      final String? requestsJson = _prefs.getString(_messageRequestsKey);
      if (requestsJson == null) return [];

      final List<dynamic> requestsList = jsonDecode(requestsJson);
      return requestsList
          .map((json) => ConversationModel.fromJson(json))
          .where((conversation) => conversation.isParticipant(currentUserTag))
          .toList();
    } catch (e) {
      debugPrint('Mesaj istekleri yüklenirken hata: $e');
      return [];
    }
  }

  // Belirli bir kullanıcı ile sohbet bul veya oluştur
  Future<ConversationModel> getOrCreateConversation(
    String currentUserTag, 
    String otherUserTag,
    {bool isMessageRequest = false}
  ) async {
    // Önce mevcut sohbeti ara
    final conversations = await getUserConversations(currentUserTag);
    final existingConversation = conversations
        .where((conv) => 
            conv.type == ConversationType.direct &&
            conv.participantUserTags.contains(otherUserTag))
        .firstOrNull;

    if (existingConversation != null) {
      return existingConversation;
    }

    // Mesaj isteklerinde de ara
    final messageRequests = await getMessageRequests(currentUserTag);
    final existingRequest = messageRequests
        .where((conv) => 
            conv.type == ConversationType.direct &&
            conv.participantUserTags.contains(otherUserTag))
        .firstOrNull;

    if (existingRequest != null) {
      return existingRequest;
    }

    // Yeni sohbet oluştur
    final newConversation = ConversationModel(
      id: _generateConversationId(currentUserTag, otherUserTag),
      participantUserTags: [currentUserTag, otherUserTag],
      messages: [],
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
      type: ConversationType.direct,
    );

    if (isMessageRequest) {
      await _saveMessageRequest(newConversation);
    } else {
      await _saveConversation(newConversation);
    }

    return newConversation;
  }

  // Mesaj gönder
  Future<bool> sendMessage(
    String conversationId,
    String senderUserTag,
    String receiverUserTag,
    String content,
    {MessageType type = MessageType.text}
  ) async {
    try {
      final message = MessageModel(
        id: _generateMessageId(),
        senderUserTag: senderUserTag,
        receiverUserTag: receiverUserTag,
        content: content,
        timestamp: DateTime.now(),
        type: type,
      );

      // Sohbeti bul
      final conversations = await getUserConversations(senderUserTag);
      final conversationIndex = conversations
          .indexWhere((conv) => conv.id == conversationId);

      if (conversationIndex != -1) {
        // Mevcut sohbete mesaj ekle
        final updatedConversation = conversations[conversationIndex]
            .addMessage(message);
        conversations[conversationIndex] = updatedConversation;
        
        await _saveAllConversations(conversations);
        return true;
      } else {
        // Mesaj isteği olarak kaydet
        final messageRequests = await getMessageRequests(receiverUserTag);
        final requestIndex = messageRequests
            .indexWhere((conv) => conv.id == conversationId);

        if (requestIndex != -1) {
          final updatedRequest = messageRequests[requestIndex]
              .addMessage(message);
          messageRequests[requestIndex] = updatedRequest;
          
          await _saveAllMessageRequests(messageRequests);
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Mesaj gönderilirken hata: $e');
      return false;
    }
  }

  // Mesaj isteğini kabul et (normal sohbete taşı)
  Future<bool> acceptMessageRequest(String conversationId, String currentUserTag) async {
    try {
      final messageRequests = await getMessageRequests(currentUserTag);
      final requestIndex = messageRequests
          .indexWhere((conv) => conv.id == conversationId);

      if (requestIndex == -1) return false;

      final conversation = messageRequests[requestIndex];
      
      // İsteklerden çıkar
      messageRequests.removeAt(requestIndex);
      await _saveAllMessageRequests(messageRequests);

      // Normal sohbetlere ekle
      await _saveConversation(conversation);
      
      return true;
    } catch (e) {
      debugPrint('Mesaj isteği kabul edilirken hata: $e');
      return false;
    }
  }

  // Mesaj isteğini reddet
  Future<bool> rejectMessageRequest(String conversationId, String currentUserTag) async {
    try {
      final messageRequests = await getMessageRequests(currentUserTag);
      final requestIndex = messageRequests
          .indexWhere((conv) => conv.id == conversationId);

      if (requestIndex == -1) return false;

      messageRequests.removeAt(requestIndex);
      await _saveAllMessageRequests(messageRequests);
      
      return true;
    } catch (e) {
      debugPrint('Mesaj isteği reddedilirken hata: $e');
      return false;
    }
  }

  // Sohbetteki tüm mesajları okundu olarak işaretle
  Future<bool> markConversationAsRead(String conversationId, String currentUserTag) async {
    try {
      final conversations = await getUserConversations(currentUserTag);
      final conversationIndex = conversations
          .indexWhere((conv) => conv.id == conversationId);

      if (conversationIndex == -1) return false;

      final updatedConversation = conversations[conversationIndex]
          .markAllAsRead(currentUserTag);
      conversations[conversationIndex] = updatedConversation;
      
      await _saveAllConversations(conversations);
      return true;
    } catch (e) {
      debugPrint('Mesajlar okundu işaretlenirken hata: $e');
      return false;
    }
  }

  // Toplam okunmamış mesaj sayısı
  Future<int> getTotalUnreadCount(String currentUserTag) async {
    try {
      final conversations = await getUserConversations(currentUserTag);
      int totalUnread = 0;
      
      for (final conversation in conversations) {
        totalUnread += conversation.getUnreadCount(currentUserTag);
      }
      
      return totalUnread;
    } catch (e) {
      debugPrint('Okunmamış mesaj sayısı hesaplanırken hata: $e');
      return 0;
    }
  }

  // Sohbeti sil
  Future<bool> deleteConversation(String conversationId, String currentUserTag) async {
    try {
      final conversations = await getUserConversations(currentUserTag);
      conversations.removeWhere((conv) => conv.id == conversationId);
      
      await _saveAllConversations(conversations);
      return true;
    } catch (e) {
      debugPrint('Sohbet silinirken hata: $e');
      return false;
    }
  }

  // Private helper methods

  Future<void> _saveConversation(ConversationModel conversation) async {
    final conversations = await getUserConversations(''); // Tüm sohbetleri al
    final existingIndex = conversations
        .indexWhere((conv) => conv.id == conversation.id);

    if (existingIndex != -1) {
      conversations[existingIndex] = conversation;
    } else {
      conversations.add(conversation);
    }

    await _saveAllConversations(conversations);
  }

  Future<void> _saveMessageRequest(ConversationModel request) async {
    final requests = await getMessageRequests(''); // Tüm istekleri al
    requests.add(request);
    await _saveAllMessageRequests(requests);
  }

  Future<void> _saveAllConversations(List<ConversationModel> conversations) async {
    final conversationsJson = jsonEncode(
      conversations.map((conv) => conv.toJson()).toList()
    );
    await _prefs.setString(_conversationsKey, conversationsJson);
  }

  Future<void> _saveAllMessageRequests(List<ConversationModel> requests) async {
    final requestsJson = jsonEncode(
      requests.map((req) => req.toJson()).toList()
    );
    await _prefs.setString(_messageRequestsKey, requestsJson);
  }

  String _generateConversationId(String userTag1, String userTag2) {
    // İki kullanıcının tag'lerini alfabetik sırayla birleştir
    final sortedTags = [userTag1, userTag2]..sort();
    return 'conv_${sortedTags[0]}_${sortedTags[1]}';
  }

  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  // Test/Demo verisi oluştur
  Future<void> createDemoData(String currentUserTag) async {
    final demoConversation = ConversationModel(
      id: _generateConversationId(currentUserTag, 'demo_user'),
      participantUserTags: [currentUserTag, 'demo_user'],
      messages: [
        MessageModel(
          id: _generateMessageId(),
          senderUserTag: 'demo_user',
          receiverUserTag: currentUserTag,
          content: 'Merhaba! FormdaKal uygulamasını nasıl buluyorsun?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        MessageModel(
          id: _generateMessageId(),
          senderUserTag: currentUserTag,
          receiverUserTag: 'demo_user',
          content: 'Harika bir uygulama! Fitness takibim çok kolaylaştı.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      lastActivityAt: DateTime.now().subtract(const Duration(hours: 1)),
    );

    await _saveConversation(demoConversation);
  }
}