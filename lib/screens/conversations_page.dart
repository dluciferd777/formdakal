import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../providers/messaging_provider.dart';
import '../providers/user_provider.dart';
import '../utils/color_themes.dart';
import 'chat_page.dart';
import 'search_users_page.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Kullanıcı bilgilerini al ve mesajlaşma provider'ını başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
      
      if (userProvider.user != null) {
        messagingProvider.setCurrentUser(userProvider.user!.userTag);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToNewChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchUsersPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlar'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: primaryColor),
            onPressed: _navigateToNewChat,
            tooltip: 'Yeni Sohbet',
          ),
          Consumer<MessagingProvider>(
            builder: (context, messagingProvider, child) {
              return IconButton(
                icon: Icon(Icons.refresh, color: primaryColor),
                onPressed: () => messagingProvider.loadConversations(),
                tooltip: 'Yenile',
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Consumer<MessagingProvider>(
              builder: (context, messagingProvider, child) {
                final unreadCount = messagingProvider.conversations
                    .fold<int>(0, (sum, conv) => sum + conv.getUnreadCount(
                        Provider.of<UserProvider>(context, listen: false).user?.userTag ?? ''));
                
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sohbetler'),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            Consumer<MessagingProvider>(
              builder: (context, messagingProvider, child) {
                final requestCount = messagingProvider.messageRequests.length;
                
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('İstekler'),
                      if (requestCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$requestCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<MessagingProvider>(
        builder: (context, messagingProvider, child) {
          if (messagingProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (messagingProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Bir hata oluştu',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    messagingProvider.error!,
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => messagingProvider.loadConversations(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildConversationsList(messagingProvider.conversations),
              _buildMessageRequestsList(messagingProvider.messageRequests),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNewChat,
        backgroundColor: primaryColor,
        child: const Icon(Icons.message, color: Colors.white),
        tooltip: 'Yeni Mesaj',
      ),
    );
  }

  Widget _buildConversationsList(List<ConversationModel> conversations) {
    if (conversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Henüz sohbet yok',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Arkadaşlarınla sohbet etmeye başla!',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _navigateToNewChat,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Sohbet Başlat'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationTile(conversation);
      },
    );
  }

  Widget _buildMessageRequestsList(List<ConversationModel> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Mesaj isteği yok',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni insanlardan mesaj geldiğinde burada görünür',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildMessageRequestTile(request);
      },
    );
  }

  Widget _buildConversationTile(ConversationModel conversation) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserTag = userProvider.user?.userTag ?? '';
    final otherUserTag = conversation.getOtherParticipant(currentUserTag);
    final lastMessage = conversation.lastMessage;
    final unreadCount = conversation.getUnreadCount(currentUserTag);

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[300],
        backgroundImage: otherUserTag != null 
          ? CachedNetworkImageProvider('https://i.pravatar.cc/150?u=$otherUserTag')
          : null,
        child: otherUserTag == null 
          ? Icon(Icons.person, color: Colors.grey[600])
          : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              _getDisplayName(otherUserTag ?? 'Bilinmeyen'),
              style: TextStyle(
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DynamicColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: lastMessage != null
        ? Text(
            _getMessagePreview(lastMessage, currentUserTag),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              color: unreadCount > 0 ? null : Colors.grey[600],
            ),
          )
        : Text(
            'Sohbeti başlat...',
            style: TextStyle(color: Colors.grey[500]),
          ),
      trailing: lastMessage != null
        ? Text(
            lastMessage.shortTime,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          )
        : null,
      onTap: () => _openChat(conversation),
    );
  }

  Widget _buildMessageRequestTile(ConversationModel request) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserTag = userProvider.user?.userTag ?? '';
    final otherUserTag = request.getOtherParticipant(currentUserTag);
    final lastMessage = request.lastMessage;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey[300],
          backgroundImage: otherUserTag != null 
            ? CachedNetworkImageProvider('https://i.pravatar.cc/150?u=$otherUserTag')
            : null,
          child: otherUserTag == null 
            ? Icon(Icons.person, color: Colors.grey[600])
            : null,
        ),
        title: Text(_getDisplayName(otherUserTag ?? 'Bilinmeyen')),
        subtitle: lastMessage != null
          ? Text(
              lastMessage.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : const Text('Mesaj isteği'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => _acceptRequest(request.id),
              tooltip: 'Kabul Et',
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => _rejectRequest(request.id),
              tooltip: 'Reddet',
            ),
          ],
        ),
        onTap: () => _openChat(request),
      ),
    );
  }

  void _openChat(ConversationModel conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(conversation: conversation),
      ),
    );
  }

  void _acceptRequest(String conversationId) async {
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
    final success = await messagingProvider.acceptMessageRequest(conversationId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesaj isteği kabul edildi')),
      );
    }
  }

  void _rejectRequest(String conversationId) async {
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
    final success = await messagingProvider.rejectMessageRequest(conversationId);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesaj isteği reddedildi')),
      );
    }
  }

  String _getDisplayName(String userTag) {
    // TODO: Gerçek isim mapping'i UserProvider'dan alınacak
    return userTag.replaceAll('@', '').toUpperCase();
  }

  String _getMessagePreview(MessageModel message, String currentUserTag) {
    final isMyMessage = message.isMyMessage(currentUserTag);
    final prefix = isMyMessage ? 'Sen: ' : '';
    
    switch (message.type) {
      case MessageType.text:
        return '$prefix${message.content}';
      case MessageType.image:
        return '${prefix}📷 Fotoğraf';
      case MessageType.workoutShare:
        return '${prefix}💪 Antrenman paylaştı';
      case MessageType.achievement:
        return '${prefix}🏆 Başarım paylaştı';
    }
  }
}