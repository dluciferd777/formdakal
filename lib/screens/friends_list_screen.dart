// lib/screens/friends_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/friend_service.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../widgets/dynamic_app_bar.dart';

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<UserModel> _friends = [];
  List<UserModel> _onlineFriends = [];
  List<UserModel> _recentlyActive = [];
  
  bool _isLoading = true;
  String _currentUserTag = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFriends();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    final currentUser = context.read<UserProvider>().user;
    if (currentUser == null) return;
    
    setState(() {
      _currentUserTag = currentUser.userTag;
      _isLoading = true;
    });
    
    try {
      final friends = await FriendService.getFriendsList(_currentUserTag);
      final online = friends.where((f) => f.isOnline).toList();
      final recent = friends.where((f) => _wasRecentlyActive(f.lastSeen)).toList();
      
      setState(() {
        _friends = friends;
        _onlineFriends = online;
        _recentlyActive = recent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _wasRecentlyActive(DateTime? lastSeen) {
    if (lastSeen == null) return false;
    final difference = DateTime.now().difference(lastSeen);
    return difference.inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SimpleDynamicAppBar(
        title: 'Arkadaşlarım (${_friends.length})',
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.pushNamed(context, '/friend_search'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFriends,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Stats Bar
              _buildStatsBar(),
              
              // Tab Bar
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryGreen,
                  labelColor: AppColors.primaryGreen,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Tümü (${_friends.length})'),
                    Tab(text: 'Çevrimiçi (${_onlineFriends.length})'),
                    Tab(text: 'Son Aktif (${_recentlyActive.length})'),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFriendsList(_friends),
                    _buildFriendsList(_onlineFriends),
                    _buildFriendsList(_recentlyActive),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Toplam Arkadaş', _friends.length.toString(), Icons.people),
          _buildStatItem('Çevrimiçi', _onlineFriends.length.toString(), Icons.circle, color: Colors.green),
          _buildStatItem('Son 24 Saat', _recentlyActive.length.toString(), Icons.access_time),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.primaryGreen, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsList(List<UserModel> friends) {
    if (friends.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadFriends,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          return _buildFriendCard(friends[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Bu kategoride arkadaş yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yeni arkadaşlar eklemek için + butonuna basın',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(UserModel friend) {
    final isOnline = friend.isOnline;
    final lastSeen = friend.lastSeen;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewFriendProfile(friend),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with Online Status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primaryGreen,
                    backgroundImage: friend.profileImagePath != null 
                      ? NetworkImage(friend.profileImagePath!)
                      : null,
                    child: friend.profileImagePath == null
                      ? Text(
                          friend.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 12),
              
              // Friend Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      friend.fullUserTag,
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isOnline ? Icons.circle : Icons.access_time,
                          size: 12,
                          color: isOnline ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Çevrimiçi' : _getLastSeenText(lastSeen),
                          style: TextStyle(
                            color: isOnline ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Friend Actions
              PopupMenuButton<String>(
                onSelected: (value) => _handleFriendAction(friend, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Profili Görüntüle'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'message',
                    child: Row(
                      children: [
                        Icon(Icons.message),
                        SizedBox(width: 8),
                        Text('Mesaj Gönder'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Engelle', style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.remove_circle, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Arkadaşlıktan Çıkar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLastSeenText(DateTime? lastSeen) {
    if (lastSeen == null) return 'Bilinmiyor';
    
    final difference = DateTime.now().difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} sa önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }

  void _viewFriendProfile(UserModel friend) {
    // Arkadaş profil sayfasına git
    Navigator.pushNamed(
      context,
      '/friend_profile',
      arguments: friend.userTag,
    );
  }

  void _handleFriendAction(UserModel friend, String action) {
    switch (action) {
      case 'profile':
        _viewFriendProfile(friend);
        break;
      case 'message':
        _sendMessage(friend);
        break;
      case 'block':
        _blockFriend(friend);
        break;
      case 'remove':
        _removeFriend(friend);
        break;
    }
  }

  void _sendMessage(UserModel friend) {
    // Mesaj gönderme özelliği (gelecekte eklenecek)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${friend.name} ile mesajlaşma özelliği yakında!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  Future<void> _blockFriend(UserModel friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${friend.name}\'i Engelle'),
        content: Text('${friend.name} adlı kullanıcıyı engellemek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Engelle', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await FriendService.blockUser(_currentUserTag, friend.userTag);
      
      if (success) {
        _showSnackBar('${friend.name} engellendi.', Colors.orange);
        _loadFriends();
      } else {
        _showSnackBar('Kullanıcı engellenemedi!', Colors.red);
      }
    }
  }

  Future<void> _removeFriend(UserModel friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${friend.name}\'i Arkadaşlıktan Çıkar'),
        content: Text('${friend.name} ile arkadaşlığı sonlandırmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Çıkar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await FriendService.removeFriend(_currentUserTag, friend.userTag);
      
      if (success) {
        _showSnackBar('${friend.name} arkadaş listesinden çıkarıldı.', Colors.red);
        _loadFriends();
      } else {
        _showSnackBar('Arkadaşlık sonlandırılamadı!', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// UserModel'e eklenmesi gereken extension
extension UserModelExtension on UserModel {
  bool get isOnline => DateTime.now().difference(lastSeen).inMinutes < 5;
  DateTime get lastSeen => DateTime.now().subtract(Duration(minutes: (DateTime.now().millisecondsSinceEpoch % 1440))); // Mock data
}