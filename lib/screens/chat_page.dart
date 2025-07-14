import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../providers/messaging_provider.dart';
import '../providers/user_provider.dart';
import '../providers/step_counter_provider.dart';
import '../utils/color_themes.dart';

class ChatPage extends StatefulWidget {
  final ConversationModel conversation;

  const ChatPage({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late String _currentUserTag;
  late String _otherUserTag;
  late ConversationModel _conversation;

  @override
  void initState() {
    super.initState();
    _conversation = widget.conversation;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _currentUserTag = userProvider.user?.userTag ?? '';
    _otherUserTag = _conversation.getOtherParticipant(_currentUserTag) ?? '';

    // Sohbeti okundu olarak işaretle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAsRead();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markAsRead() {
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
    messagingProvider.markConversationAsRead(_conversation.id);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
    
    // UI'yi hemen güncelle
    _messageController.clear();
    
    final success = await messagingProvider.sendMessage(
      _conversation.id,
      _otherUserTag,
      text,
    );

    if (success) {
      // Yerel conversation'ı güncelle
      final updatedConversation = messagingProvider.getConversation(_conversation.id);
      if (updatedConversation != null) {
        setState(() {
          _conversation = updatedConversation;
        });
        _scrollToBottom();
      }
    } else {
      // Hata durumunda kullanıcıyı bilgilendir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mesaj gönderilemedi')),
        );
      }
    }
  }

  void _shareWorkout() async {
    final stepProvider = Provider.of<StepCounterProvider>(context, listen: false);
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);

    final workoutData = {
      'steps': stepProvider.dailySteps,
      'burnedCalories': stepProvider.dailySteps * 0.045, // Adım başına ~0.045 kalori
      'duration': 30, // Sabit 30 dakika olarak ayarla
    };

    final success = await messagingProvider.shareWorkout(
      _conversation.id,
      _otherUserTag,
      workoutData,
    );

    if (success && mounted) {
      final updatedConversation = messagingProvider.getConversation(_conversation.id);
      if (updatedConversation != null) {
        setState(() {
          _conversation = updatedConversation;
        });
        _scrollToBottom();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Antrenman paylaşıldı!')),
      );
    }
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.orange),
                title: const Text('Antrenman Paylaş'),
                onTap: () {
                  Navigator.pop(context);
                  _shareWorkout();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blue),
                title: const Text('Fotoğraf Paylaş'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Fotoğraf paylaşma özelliği
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fotoğraf paylaşma yakında eklenecek!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Engelle'),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Kullanıcıyı Engelle'),
          content: Text('$_otherUserTag kullanıcısını engellemek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Engelleme özelliği
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Engelleme özelliği yakında eklenecek!')),
                );
              },
              child: const Text('Engelle', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[300],
              backgroundImage: CachedNetworkImageProvider(
                'https://i.pravatar.cc/150?u=$_otherUserTag'
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDisplayName(_otherUserTag),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Aktif', // TODO: Online durumu
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: primaryColor),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MessagingProvider>(
              builder: (context, messagingProvider, child) {
                // En güncel conversation'ı al
                final currentConversation = messagingProvider.getConversation(_conversation.id) ?? _conversation;
                
                if (currentConversation.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Sohbet başlıyor...',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'İlk mesajı sen gönder!',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: currentConversation.messages.length,
                  itemBuilder: (context, index) {
                    final message = currentConversation.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isMyMessage = message.isMyMessage(_currentUserTag);
    final primaryColor = DynamicColors.primary;

    return Container(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMyMessage ? primaryColor : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isMyMessage ? const Radius.circular(20) : const Radius.circular(4),
                bottomRight: isMyMessage ? const Radius.circular(4) : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildMessageContent(message, isMyMessage),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.shortTime,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              if (isMyMessage) ...[
                const SizedBox(width: 4),
                Icon(
                  message.isRead ? Icons.done_all : Icons.done,
                  size: 16,
                  color: message.isRead ? primaryColor : Colors.grey[500],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(MessageModel message, bool isMyMessage) {
    final textColor = isMyMessage ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color;

    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(color: textColor, fontSize: 16),
        );
      
      case MessageType.workoutShare:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: textColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Antrenman Paylaşımı',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.content,
              style: TextStyle(color: textColor, fontSize: 14),
            ),
          ],
        );
      
      case MessageType.achievement:
        return Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.content,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ),
          ],
        );
      
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
              ),
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ],
          ],
        );
    }
  }

  Widget _buildMessageInputField() {
    final primaryColor = DynamicColors.primary;

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 5,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add, color: primaryColor),
              onPressed: _showMoreOptions,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                maxLines: null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(String userTag) {
    // TODO: Gerçek isim mapping'i UserProvider'dan alınacak
    return userTag.replaceAll('@', '').toUpperCase();
  }
}