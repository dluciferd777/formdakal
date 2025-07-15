class MessageModel {
  final String id;
  final String senderUserTag;
  final String receiverUserTag;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;

  MessageModel({
    required this.id,
    required this.senderUserTag,
    required this.receiverUserTag,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
  });

  // JSON'dan model oluşturma
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderUserTag: json['senderUserTag'] ?? '',
      receiverUserTag: json['receiverUserTag'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
    );
  }

  // Model'i JSON'a çevirme
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUserTag': senderUserTag,
      'receiverUserTag': receiverUserTag,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.toString().split('.').last,
    };
  }

  // Mesajı okundu olarak işaretle
  MessageModel markAsRead() {
    return MessageModel(
      id: id,
      senderUserTag: senderUserTag,
      receiverUserTag: receiverUserTag,
      content: content,
      timestamp: timestamp,
      isRead: true,
      type: type,
    );
  }

  // Mesajın kendi mesajımız olup olmadığını kontrol et
  bool isMyMessage(String currentUserTag) {
    return senderUserTag == currentUserTag;
  }

  // Zaman damgasını okunabilir formata çevir
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  // Kısa zaman formatı (saat:dakika)
  String get shortTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, sender: $senderUserTag, content: $content, time: $formattedTime)';
  }
}

// Mesaj tipleri
enum MessageType {
  text,           // Metin mesajı
  image,          // Resim
  workoutShare,   // Antrenman paylaşımı
  achievement,    // Başarım paylaşımı
}

// Mesaj türü için yardımcı metodlar
extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Metin';
      case MessageType.image:
        return 'Resim';
      case MessageType.workoutShare:
        return 'Antrenman Paylaşımı';
      case MessageType.achievement:
        return 'Başarım';
    }
  }

  bool get isMediaMessage {
    return this == MessageType.image;
  }

  bool get isSpecialMessage {
    return this == MessageType.workoutShare || this == MessageType.achievement;
  }
}