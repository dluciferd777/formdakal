import 'message_model.dart';

class ConversationModel {
  final String id;
  final List<String> participantUserTags; // Katılımcıların userTag'leri
  final List<MessageModel> messages;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final ConversationType type;
  final String? conversationName; // Grup sohbetleri için
  final String? conversationImageUrl; // Grup sohbetleri için

  ConversationModel({
    required this.id,
    required this.participantUserTags,
    required this.messages,
    required this.createdAt,
    required this.lastActivityAt,
    this.type = ConversationType.direct,
    this.conversationName,
    this.conversationImageUrl,
  });

  // JSON'dan model oluşturma
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      participantUserTags: List<String>.from(json['participantUserTags'] ?? []),
      messages: (json['messages'] as List<dynamic>?)
          ?.map((messageJson) => MessageModel.fromJson(messageJson))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      lastActivityAt: DateTime.parse(json['lastActivityAt']),
      type: ConversationType.values.firstWhere(
        (e) => e.toString() == 'ConversationType.${json['type']}',
        orElse: () => ConversationType.direct,
      ),
      conversationName: json['conversationName'],
      conversationImageUrl: json['conversationImageUrl'],
    );
  }

  // Model'i JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participantUserTags': participantUserTags,
      'messages': messages.map((message) => message.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastActivityAt': lastActivityAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'conversationName': conversationName,
      'conversationImageUrl': conversationImageUrl,
    };
  }

  // Yeni mesaj ekle
  ConversationModel addMessage(MessageModel message) {
    final updatedMessages = List<MessageModel>.from(messages)..add(message);
    
    return ConversationModel(
      id: id,
      participantUserTags: participantUserTags,
      messages: updatedMessages,
      createdAt: createdAt,
      lastActivityAt: message.timestamp,
      type: type,
      conversationName: conversationName,
      conversationImageUrl: conversationImageUrl,
    );
  }

  // Son mesajı al
  MessageModel? get lastMessage {
    return messages.isNotEmpty ? messages.last : null;
  }

  // Okunmamış mesaj sayısı (belirli kullanıcı için)
  int getUnreadCount(String currentUserTag) {
    return messages
        .where((message) => 
            !message.isRead && 
            message.receiverUserTag == currentUserTag)
        .length;
  }

  // Diğer katılımcının userTag'ini al (direkt sohbet için)
  String? getOtherParticipant(String currentUserTag) {
    if (type == ConversationType.direct && participantUserTags.length == 2) {
      return participantUserTags
          .firstWhere((tag) => tag != currentUserTag, orElse: () => '');
    }
    return null;
  }

  // Sohbetin aktif olup olmadığını kontrol et (son 30 gün içinde mesaj)
  bool get isActive {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastActivityAt.isAfter(thirtyDaysAgo);
  }

  // Tüm mesajları okundu olarak işaretle (belirli kullanıcı için)
  ConversationModel markAllAsRead(String currentUserTag) {
    final updatedMessages = messages.map((message) {
      if (message.receiverUserTag == currentUserTag && !message.isRead) {
        return message.markAsRead();
      }
      return message;
    }).toList();

    return ConversationModel(
      id: id,
      participantUserTags: participantUserTags,
      messages: updatedMessages,
      createdAt: createdAt,
      lastActivityAt: lastActivityAt,
      type: type,
      conversationName: conversationName,
      conversationImageUrl: conversationImageUrl,
    );
  }

  // Kullanıcının sohbette olup olmadığını kontrol et
  bool isParticipant(String userTag) {
    return participantUserTags.contains(userTag);
  }

  // Sohbet başlığını al
  String getDisplayName(String currentUserTag, Map<String, String> userNames) {
    if (type == ConversationType.group && conversationName != null) {
      return conversationName!;
    }
    
    if (type == ConversationType.direct) {
      final otherUser = getOtherParticipant(currentUserTag);
      return otherUser != null ? (userNames[otherUser] ?? otherUser) : 'Bilinmeyen Kullanıcı';
    }
    
    return 'Sohbet';
  }

  // Son aktivite zamanını okunabilir formatta al
  String get formattedLastActivity {
    final now = DateTime.now();
    final difference = now.difference(lastActivityAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Şimdi';
    }
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, participants: $participantUserTags, messageCount: ${messages.length})';
  }
}

// Sohbet türleri
enum ConversationType {
  direct,    // Direkt (1-1) sohbet
  group,     // Grup sohbeti
}

// Sohbet türü için yardımcı metodlar
extension ConversationTypeExtension on ConversationType {
  String get displayName {
    switch (this) {
      case ConversationType.direct:
        return 'Direkt Sohbet';
      case ConversationType.group:
        return 'Grup Sohbeti';
    }
  }

  bool get isGroup {
    return this == ConversationType.group;
  }
}