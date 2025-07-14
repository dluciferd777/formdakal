import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/conversation_model.dart';
import '../providers/messaging_provider.dart';
import '../providers/user_provider.dart';
import '../utils/color_themes.dart';
import 'chat_page.dart';

class SearchUsersPage extends StatefulWidget {
  const SearchUsersPage({super.key});

  @override
  State<SearchUsersPage> createState() => _SearchUsersPageState();
}

class _SearchUsersPageState extends State<SearchUsersPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  
  List<MockUser> _searchResults = [];
  List<MockUser> _recentChats = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
    
    // Arama alanına odaklan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Arama dinleyicisi
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRecentChats() {
    // Son sohbet ettiğimiz kişileri yükle
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
    final conversations = messagingProvider.conversations;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserTag = userProvider.user?.userTag ?? '';

    _recentChats = conversations
        .where((conv) => conv.type == ConversationType.direct)
        .take(5)
        .map((conv) {
          final otherUserTag = conv.getOtherParticipant(currentUserTag) ?? '';
          return MockUser(
            userTag: otherUserTag,
            name: _getDisplayName(otherUserTag),
            isOnline: true, // Mock data
            lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
            isFollowing: true,
          );
        })
        .toList();

    setState(() {});
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Mock arama sonuçları (gerçek uygulamada API'den gelecek)
    _searchResults = _getMockSearchResults(query);
    setState(() {});
  }

  List<MockUser> _getMockSearchResults(String query) {
    final allUsers = [
      MockUser(
        userTag: 'ahmet_fit',
        name: 'Ahmet Yılmaz',
        isOnline: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
        isFollowing: false,
        bio: 'Fitness tutkunu, 5 yıldır spor yapıyorum',
        mutualFriends: 3,
      ),
      MockUser(
        userTag: 'elif_runner',
        name: 'Elif Demir',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
        isFollowing: true,
        bio: 'Koşu ve yoga sevdalısı',
        mutualFriends: 8,
      ),
      MockUser(
        userTag: 'murat_gym',
        name: 'Murat Kaya',
        isOnline: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 10)),
        isFollowing: false,
        bio: 'Vücut geliştirme sporcusu',
        mutualFriends: 1,
      ),
      MockUser(
        userTag: 'zeynep_pilates',
        name: 'Zeynep Özkan',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(days: 1)),
        isFollowing: false,
        bio: 'Pilates eğitmeni ve beslenme uzmanı',
        mutualFriends: 0,
      ),
      MockUser(
        userTag: 'can_cyclist',
        name: 'Can Aktaş',
        isOnline: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 1)),
        isFollowing: true,
        bio: 'Bisiklet tutkunu, dağ bisikletçisi',
        mutualFriends: 5,
      ),
    ];

    return allUsers.where((user) {
      final searchQuery = query.toLowerCase();
      return user.name.toLowerCase().contains(searchQuery) ||
             user.userTag.toLowerCase().contains(searchQuery) ||
             (user.bio?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  void _startChat(MockUser user) async {
    final messagingProvider = Provider.of<MessagingProvider>(context, listen: false);
    
    // Sohbet oluştur veya mevcut sohbeti bul
    final conversation = await messagingProvider.startConversation(user.userTag);
    
    if (conversation != null && mounted) {
      // Chat sayfasına git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(conversation: conversation),
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sohbet başlatılamadı')),
        );
      }
    }
  }

  void _followUser(MockUser user) {
    // TODO: Takip etme özelliği UserProvider'dan yapılacak
    setState(() {
      user.isFollowing = !user.isFollowing;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(user.isFollowing ? '${user.name} takip edildi' : '${user.name} takipten çıkarıldı'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = DynamicColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Kullanıcı adı veya isim ara...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[600]),
            prefixIcon: Icon(Icons.search, color: primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _focusNode.requestFocus();
                    },
                  )
                : null,
          ),
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isSearching && _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildRecentChats(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sonuç bulunamadı',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Farklı anahtar kelimeler deneyin',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserTile(user, isSearchResult: true);
      },
    );
  }

  Widget _buildRecentChats() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentChats.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Son Sohbetler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DynamicColors.primary,
                ),
              ),
            ),
            ...(_recentChats.map((user) => _buildUserTile(user))),
            const Divider(height: 32),
          ],
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Önerilen Kullanıcılar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DynamicColors.primary,
              ),
            ),
          ),
          ...(_getSuggestedUsers().map((user) => _buildUserTile(user))),
        ],
      ),
    );
  }

  Widget _buildUserTile(MockUser user, {bool isSearchResult = false}) {
    final primaryColor = DynamicColors.primary;

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[300],
            backgroundImage: CachedNetworkImageProvider(
              'https://i.pravatar.cc/150?u=${user.userTag}'
            ),
          ),
          if (user.isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (user.isFollowing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Takip ediliyor',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('@${user.userTag}', style: TextStyle(color: Colors.grey[600])),
          if (user.bio != null) ...[
            const SizedBox(height: 2),
            Text(
              user.bio!,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (user.mutualFriends > 0) ...[
            const SizedBox(height: 2),
            Text(
              '${user.mutualFriends} ortak arkadaş',
              style: TextStyle(color: primaryColor, fontSize: 12),
            ),
          ],
          if (!user.isOnline) ...[
            const SizedBox(height: 2),
            Text(
              _getLastSeenText(user.lastSeen),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSearchResult && !user.isFollowing)
            IconButton(
              icon: Icon(Icons.person_add, color: primaryColor),
              onPressed: () => _followUser(user),
              tooltip: 'Takip Et',
            ),
          IconButton(
            icon: Icon(Icons.message, color: primaryColor),
            onPressed: () => _startChat(user),
            tooltip: 'Mesaj Gönder',
          ),
        ],
      ),
      onTap: () => _startChat(user),
    );
  }

  List<MockUser> _getSuggestedUsers() {
    return [
      MockUser(
        userTag: 'demo_user',
        name: 'Demo Kullanıcı',
        isOnline: true,
        lastSeen: DateTime.now(),
        isFollowing: false,
        bio: 'FormdaKal demo hesabı',
        mutualFriends: 0,
      ),
    ];
  }

  String _getDisplayName(String userTag) {
    return userTag.replaceAll('@', '').split('_').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
    ).join(' ');
  }

  String _getLastSeenText(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce aktifti';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce aktifti';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce aktifti';
    } else {
      return 'Az önce aktifti';
    }
  }
}

// Mock User Model (gerçek uygulamada ayrı bir dosyada olacak)
class MockUser {
  final String userTag;
  final String name;
  final bool isOnline;
  final DateTime lastSeen;
  bool isFollowing;
  final String? bio;
  final int mutualFriends;

  MockUser({
    required this.userTag,
    required this.name,
    required this.isOnline,
    required this.lastSeen,
    required this.isFollowing,
    this.bio,
    this.mutualFriends = 0,
  });
}