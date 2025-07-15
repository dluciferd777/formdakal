// lib/screens/friend_search_screen.dart - Arkadaş Arama ve Ekleme (DÜZELTİLMİŞ)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/friend_service.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/dynamic_app_bar.dart';

class FriendSearchScreen extends StatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  State<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  List<UserModel> _searchResults = [];
  List<UserModel> _friendRequests = [];
  List<UserModel> _sentRequests = [];
  List<UserModel> _popularUsers = [];
  
  bool _isSearching = false;
  String _currentUserTag = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final currentUser = context.read<UserProvider>().user;
    if (currentUser == null) return;
    
    setState(() {
      _currentUserTag = currentUser.userTag;
    });
    
    // Gelen istekleri yükle
    final requests = await FriendService.getFriendRequests(_currentUserTag);
    final sent = await FriendService.getSentRequests(_currentUserTag);
    final popular = await FriendService.getPopularUsers();
    
    setState(() {
      _friendRequests = requests;
      _sentRequests = sent;
      _popularUsers = popular.where((u) => u.userTag != _currentUserTag).toList();
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    List<UserModel> results = [];
    
    // Önce tam tag eşleşmesi ara
    if (query.contains('#')) {
      final tag = query.split('#').last;
      final user = await FriendService.findUserByTag(tag);
      if (user != null && user.userTag != _currentUserTag) {
        results.add(user);
      }
    } else {
      // İsim ile arama
      final users = await FriendService.searchUsersByName(query);
      results = users.where((u) => u.userTag != _currentUserTag).toList();
    }

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleDynamicAppBar(title: 'Arkadaş Ara'),
      body: Column(
        children: [
          // Arama Çubuğu
          _buildSearchBar(),
          
          // Tab Bar
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: context.watch<ThemeProvider>().currentColorPalette.primary,
              labelColor: context.watch<ThemeProvider>().currentColorPalette.primary,
              unselectedLabelColor: Colors.grey,
              isScrollable: true,
              tabs: [
                Tab(text: 'Arama (${_searchResults.length})'),
                Tab(text: 'İstekler (${_friendRequests.length})'),
                Tab(text: 'Gönderilen (${_sentRequests.length})'),
                Tab(text: 'Popüler (${_popularUsers.length})'),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(),
                _buildRequestsTab(),
                _buildSentRequestsTab(),
                _buildPopularTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Kullanıcı adı veya tag ara (örn: LUCCI#2536)',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _search('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
        ),
        onChanged: _search,
      ),
    );
  }

  Widget _buildSearchTab() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        title: 'Arkadaş Ara',
        subtitle: 'Kullanıcı adı veya tag ile arkadaş arayın\nÖrnek: LUCCI#2536',
      );
    }
    
    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_search,
        title: 'Kullanıcı Bulunamadı',
        subtitle: 'Aradığınız kullanıcı bulunamadı.\nTag\'in doğru olduğundan emin olun.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildUserCard(_searchResults[index], UserCardType.search);
      },
    );
  }

  Widget _buildRequestsTab() {
    if (_friendRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.inbox,
        title: 'Arkadaşlık İsteği Yok',
        subtitle: 'Henüz arkadaşlık isteğiniz bulunmuyor.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _friendRequests.length,
      itemBuilder: (context, index) {
        return _buildUserCard(_friendRequests[index], UserCardType.request);
      },
    );
  }

  Widget _buildSentRequestsTab() {
    if (_sentRequests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.send,
        title: 'Gönderilen İstek Yok',
        subtitle: 'Henüz arkadaşlık isteği göndermemişsiniz.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sentRequests.length,
      itemBuilder: (context, index) {
        return _buildUserCard(_sentRequests[index], UserCardType.sent);
      },
    );
  }

  Widget _buildPopularTab() {
    if (_popularUsers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.trending_up,
        title: 'Popüler Kullanıcı Yok',
        subtitle: 'Henüz popüler kullanıcı bulunmuyor.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _popularUsers.length,
      itemBuilder: (context, index) {
        return _buildUserCard(_popularUsers[index], UserCardType.popular);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, UserCardType type) {
    final palette = context.watch<ThemeProvider>().currentColorPalette;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 25,
              backgroundColor: palette.primary,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.fullUserTag,
                    style: TextStyle(
                      color: palette.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.friendsCount} arkadaş • ${user.age} yaş',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Button
            _buildActionButton(user, type, palette),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(UserModel user, UserCardType type, palette) {
    switch (type) {
      case UserCardType.search:
      case UserCardType.popular:
        return ElevatedButton(
          onPressed: () => _sendFriendRequest(user),
          style: ElevatedButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Ekle', style: TextStyle(fontSize: 12)),
        );
        
      case UserCardType.request:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _acceptRequest(user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(60, 32),
              ),
              child: const Text('Kabul', style: TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _rejectRequest(user),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(60, 32),
              ),
              child: const Text('Reddet', style: TextStyle(fontSize: 11)),
            ),
          ],
        );
        
      case UserCardType.sent:
        return OutlinedButton(
          onPressed: () => _cancelRequest(user),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('İptal', style: TextStyle(fontSize: 12)),
        );
    }
  }

  // Action Methods
  Future<void> _sendFriendRequest(UserModel user) async {
    final success = await FriendService.sendFriendRequest(_currentUserTag, user.userTag);
    
    if (success) {
      _showSnackBar('${user.name}\'e arkadaşlık isteği gönderildi!', Colors.green);
      _loadData(); // Verileri yenile
    } else {
      _showSnackBar('Arkadaşlık isteği gönderilemedi!', Colors.red);
    }
  }

  Future<void> _acceptRequest(UserModel user) async {
    final success = await FriendService.acceptFriendRequest(_currentUserTag, user.userTag);
    
    if (success) {
      _showSnackBar('${user.name} arkadaş listenize eklendi!', Colors.green);
      _loadData();
    } else {
      _showSnackBar('İstek kabul edilemedi!', Colors.red);
    }
  }

  Future<void> _rejectRequest(UserModel user) async {
    final success = await FriendService.rejectFriendRequest(_currentUserTag, user.userTag);
    
    if (success) {
      _showSnackBar('${user.name}\'in isteği reddedildi.', Colors.orange);
      _loadData();
    } else {
      _showSnackBar('İstek reddedilemedi!', Colors.red);
    }
  }

  Future<void> _cancelRequest(UserModel user) async {
    final success = await FriendService.cancelFriendRequest(_currentUserTag, user.userTag);
    
    if (success) {
      _showSnackBar('${user.name}\'e gönderilen istek iptal edildi.', Colors.orange);
      _loadData();
    } else {
      _showSnackBar('İstek iptal edilemedi!', Colors.red);
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

enum UserCardType {
  search,
  request,
  sent,
  popular,
}